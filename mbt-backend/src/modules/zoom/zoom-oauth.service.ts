import { Injectable, Logger, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SupabaseService } from '../supabase/supabase.service';
import * as crypto from 'crypto';

export interface ProviderAccount {
  id: string;
  provider: string;
  provider_user_id: string | null;
  email: string | null;
  access_token: string;
  refresh_token: string;
  expires_at: string | null;
  connected_at: string;
  status: string;
}

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 16;
const TAG_LENGTH = 16;

@Injectable()
export class ZoomOAuthService {
  private readonly logger = new Logger(ZoomOAuthService.name);
  private readonly clientId: string;
  private readonly clientSecret: string;
  private readonly redirectUri: string;
  private readonly encryptionKey: Buffer;

  constructor(
    private readonly configService: ConfigService,
    private readonly supabaseService: SupabaseService,
  ) {
    this.clientId = this.configService.get<string>('zoom.clientId')!;
    this.clientSecret = this.configService.get<string>('zoom.clientSecret')!;
    this.redirectUri = this.configService.get<string>('zoom.redirectUri')!;
    const keyHex = this.configService.get<string>('zoom.tokenEncryptionKey')!;
    this.encryptionKey = Buffer.from(keyHex, 'hex');
  }

  private get db() {
    return this.supabaseService.getClient();
  }

  getAuthorizationUrl(instructorId: string, state: string): string {
    const params = new URLSearchParams({
      response_type: 'code',
      client_id: this.clientId,
      redirect_uri: this.redirectUri,
      state,
    });
    return `https://zoom.us/oauth/authorize?${params.toString()}`;
  }

  async handleCallback(code: string, instructorId: string): Promise<void> {
    this.logger.log(`Exchanging authorization code for system-wide Zoom account`);

    const tokenResponse = await this.exchangeCodeForTokens(code);

    const encryptedAccess = this.encrypt(tokenResponse.access_token);
    const encryptedRefresh = this.encrypt(tokenResponse.refresh_token);

    const expiresAt = new Date(
      Date.now() + tokenResponse.expires_in * 1000,
    ).toISOString();

    const zoomUser = await this.getZoomUser(tokenResponse.access_token);

    const { data: existing } = await (this.db.from('meeting_provider_accounts') as any)
      .select('id')
      .eq('provider', 'zoom')
      .maybeSingle();

    let query;
    if (existing) {
      query = (this.db.from('meeting_provider_accounts') as any)
        .update({
          access_token: encryptedAccess,
          refresh_token: encryptedRefresh,
          expires_at: expiresAt,
          status: 'connected',
          provider_user_id: zoomUser.id,
          email: zoomUser.email,
        })
        .eq('id', existing.id);
    } else {
      query = (this.db.from('meeting_provider_accounts') as any)
        .insert({
          provider: 'zoom',
          access_token: encryptedAccess,
          refresh_token: encryptedRefresh,
          expires_at: expiresAt,
          status: 'connected',
          provider_user_id: zoomUser.id,
          email: zoomUser.email,
        });
    }

    const { error } = await query;

    if (error) {
      this.logger.error(`Failed to store Zoom tokens: ${error.message}`);
      throw new InternalServerErrorException('Failed to store Zoom connection');
    }

    this.logger.log(`System-wide Zoom account connected (user: ${zoomUser.email})`);
  }

  async disconnect(instructorId: string): Promise<void> {
    await (this.db.from('meeting_provider_accounts') as any)
      .update({ status: 'disconnected' })
      .eq('provider', 'zoom');
  }

  async getConnection(instructorId?: string): Promise<ProviderAccount | null> {
    const { data } = await (this.db.from('meeting_provider_accounts') as any)
      .select('*')
      .eq('provider', 'zoom')
      .eq('status', 'connected')
      .maybeSingle();

    if (!data) return null;

    return {
      ...data,
      access_token: this.decrypt(data.access_token),
      refresh_token: this.decrypt(data.refresh_token),
    } as ProviderAccount;
  }

  async refreshAccessToken(account: ProviderAccount): Promise<string> {
    this.logger.log(`Refreshing Zoom token`);

    const credentials = Buffer.from(`${this.clientId}:${this.clientSecret}`).toString('base64');

    const response = await fetch('https://zoom.us/oauth/token', {
      method: 'POST',
      headers: {
        Authorization: `Basic ${credentials}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'refresh_token',
        refresh_token: account.refresh_token,
      }),
    });

    if (!response.ok) {
      const text = await response.text();
      this.logger.error(`Failed to refresh Zoom token: ${response.status} ${text}`);

      await (this.db.from('meeting_provider_accounts') as any)
        .update({ status: 'expired' })
        .eq('id', account.id);

      throw new InternalServerErrorException('Zoom token expired. Please reconnect your Zoom account.');
    }

    const data = (await response.json()) as {
      access_token: string;
      refresh_token: string;
      expires_in: number;
    };

    const encryptedAccess = this.encrypt(data.access_token);
    const encryptedRefresh = this.encrypt(data.refresh_token);
    const expiresAt = new Date(Date.now() + data.expires_in * 1000).toISOString();

    await (this.db.from('meeting_provider_accounts') as any)
      .update({
        access_token: encryptedAccess,
        refresh_token: encryptedRefresh,
        expires_at: expiresAt,
        status: 'connected',
      })
      .eq('id', account.id);

    this.logger.log(`Zoom token refreshed`);
    return data.access_token;
  }

  private async exchangeCodeForTokens(code: string): Promise<{
    access_token: string;
    refresh_token: string;
    expires_in: number;
  }> {
    const credentials = Buffer.from(`${this.clientId}:${this.clientSecret}`).toString('base64');

    const response = await fetch('https://zoom.us/oauth/token', {
      method: 'POST',
      headers: {
        Authorization: `Basic ${credentials}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        code,
        redirect_uri: this.redirectUri,
      }),
    });

    if (!response.ok) {
      const text = await response.text();
      this.logger.error(`Zoom OAuth token exchange failed: ${response.status} ${text}`);
      throw new InternalServerErrorException('Failed to exchange authorization code');
    }

    return response.json() as Promise<{
      access_token: string;
      refresh_token: string;
      expires_in: number;
    }>;
  }

  private async getZoomUser(accessToken: string): Promise<{ id: string; email: string }> {
    const response = await fetch('https://api.zoom.us/v2/users/me', {
      headers: { Authorization: `Bearer ${accessToken}` },
    });

    if (!response.ok) {
      const text = await response.text();
      this.logger.error(`Failed to fetch Zoom user info: ${response.status} ${text}`);
      throw new InternalServerErrorException('Failed to fetch Zoom user details');
    }

    const data = (await response.json()) as { id: string; email: string };
    return { id: data.id, email: data.email };
  }

  private encrypt(text: string): string {
    const iv = crypto.randomBytes(IV_LENGTH);
    const cipher = crypto.createCipheriv(ALGORITHM, this.encryptionKey, iv);
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    const tag = cipher.getAuthTag().toString('hex');
    return `${iv.toString('hex')}:${tag}:${encrypted}`;
  }

  private decrypt(encryptedText: string): string {
    const parts = encryptedText.split(':');
    const iv = Buffer.from(parts[0], 'hex');
    const tag = Buffer.from(parts[1], 'hex');
    const encrypted = parts[2];
    const decipher = crypto.createDecipheriv(ALGORITHM, this.encryptionKey, iv);
    decipher.setAuthTag(tag);
    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
  }
}
