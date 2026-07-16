import {
  Injectable,
  Logger,
  InternalServerErrorException,
} from '@nestjs/common';
import { ZoomOAuthService, ProviderAccount } from './zoom-oauth.service';

@Injectable()
export class ZoomAuthService {
  private readonly logger = new Logger(ZoomAuthService.name);

  constructor(private readonly zoomOAuthService: ZoomOAuthService) {}

  async getAccessToken(): Promise<string> {
    const account = await this.zoomOAuthService.getConnection();
    if (!account) {
      throw new InternalServerErrorException(
        'Zoom account not connected. Please connect your Zoom account first.',
      );
    }

    if (this.isTokenExpired(account)) {
      return this.zoomOAuthService.refreshAccessToken(account);
    }

    return account.access_token;
  }

  async getProviderAccount(): Promise<ProviderAccount | null> {
    return this.zoomOAuthService.getConnection();
  }

  private isTokenExpired(account: ProviderAccount): boolean {
    if (!account.expires_at) return false;
    const expiresAt = new Date(account.expires_at).getTime();
    const bufferMs = 5 * 60 * 1000;
    return Date.now() + bufferMs >= expiresAt;
  }
}
