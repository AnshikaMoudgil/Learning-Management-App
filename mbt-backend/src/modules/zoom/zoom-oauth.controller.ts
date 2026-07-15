import {
  Controller,
  Get,
  Query,
  Redirect,
  Request,
  UseGuards,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { ZoomOAuthService } from './zoom-oauth.service';
import { randomBytes } from 'crypto';

@Controller('zoom')
export class ZoomOAuthController {
  private readonly logger = new Logger(ZoomOAuthController.name);

  constructor(private readonly zoomOAuthService: ZoomOAuthService) {}

  @Get('connect')
  @UseGuards(AuthGuard)
  async connect(@Request() req: any) {
    const instructorId = req.user?.id;
    if (!instructorId) {
      throw new UnauthorizedException('Authentication required');
    }

    const state = `${instructorId}:${randomBytes(16).toString('hex')}`;
    const url = this.zoomOAuthService.getAuthorizationUrl(instructorId, state);

    return { url };
  }

  @Get('callback')
  async callback(
    @Query('code') code: string,
    @Query('state') state: string,
  ) {
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

    await this.zoomOAuthService.handleCallback(code, instructorId);

    return {
      connected: true,
      message: 'Zoom account connected successfully. You can close this tab.',
    };
  }

  @Get('oauth-status')
  @UseGuards(AuthGuard)
  async oauthStatus(@Request() req: any) {
    const instructorId = req.user?.id;
    if (!instructorId) {
      throw new UnauthorizedException('Authentication required');
    }

    const account = await this.zoomOAuthService.getConnection(instructorId);
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
