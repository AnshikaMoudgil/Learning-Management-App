import {
  Controller,
  Get,
  Query,
  Request,
  UseGuards,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';
import { ZoomOAuthService } from './zoom-oauth.service';
import { randomBytes } from 'crypto';
import { SupabaseService } from '../supabase/supabase.service';

@Controller('zoom')
export class ZoomOAuthController {
  private readonly logger = new Logger(ZoomOAuthController.name);

  constructor(
    private readonly zoomOAuthService: ZoomOAuthService,
    private readonly supabaseService: SupabaseService,
  ) {}

  @Get('connect')
  @UseGuards(AuthGuard, RolesGuard)
  @Roles('superadmin')
  connect(@Request() req: AuthenticatedRequest) {
    const instructorId = req.user?.id;
    if (!instructorId) {
      throw new UnauthorizedException('Authentication required');
    }

    const state = `${instructorId}:${randomBytes(16).toString('hex')}`;
    const url = this.zoomOAuthService.getAuthorizationUrl(state);

    return { url };
  }

  @Get('callback')
  async callback(@Query('code') code: string, @Query('state') state: string) {
    if (!code || !state) {
      return {
        error: 'missing_params',
        message: 'Missing authorization code or state',
      };
    }

    const instructorId = state.split(':')[0];
    if (!instructorId) {
      return {
        error: 'invalid_state',
        message: 'Invalid state parameter',
      };
    }

    const { data: profile } = await this.supabaseService
      .getClient()
      .from('profiles')
      .select('role')
      .eq('id', instructorId)
      .single();

    if (!profile || (profile as Record<string, unknown>).role !== 'superadmin') {
      return {
        error: 'unauthorized',
        message: 'Only superadmins can connect the system Zoom account',
      };
    }

    await this.zoomOAuthService.handleCallback(code);

    return {
      connected: true,
      message: 'Zoom account connected successfully. You can close this tab.',
    };
  }

  @Get('disconnect')
  @UseGuards(AuthGuard, RolesGuard)
  @Roles('superadmin')
  async disconnect(@Request() req: AuthenticatedRequest) {
    const instructorId = req.user?.id;
    if (!instructorId) {
      throw new UnauthorizedException('Authentication required');
    }

    await this.zoomOAuthService.disconnect();
    return { success: true, message: 'Zoom account disconnected' };
  }

  @Get('oauth-status')
  @UseGuards(AuthGuard)
  async oauthStatus(@Request() req: AuthenticatedRequest) {
    const instructorId = req.user?.id;
    if (!instructorId) {
      throw new UnauthorizedException('Authentication required');
    }

    const account = await this.zoomOAuthService.getConnection();
    if (!account) {
      return { connected: false };
    }

    return {
      connected: true,
      email: account.email,
      provider_user_id: account.provider_user_id,
      connected_at: account.connected_at,
    };
  }
}
