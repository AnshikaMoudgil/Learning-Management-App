import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Request } from 'express';
import { SupabaseService } from '../../modules/supabase/supabase.service';
import { SKIP_DEVICE_CHECK_KEY } from '../decorators/skip-device-check.decorator';

@Injectable()
export class DeviceGuard implements CanActivate {
  constructor(
    private supabaseService: SupabaseService,
    private reflector: Reflector,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const skipDeviceCheck = this.reflector.getAllAndOverride<boolean>(
      SKIP_DEVICE_CHECK_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (skipDeviceCheck) {
      return true;
    }

    const request = context
      .switchToHttp()
      .getRequest<Request & { user?: { id: string } }>();

    const deviceFingerprint = request.headers['x-device-fingerprint'];
    const userId = request.user?.id;

    if (!deviceFingerprint || Array.isArray(deviceFingerprint) || !userId) {
      return true;
    }

    const { data: boundDevice } = await this.supabaseService
      .getClient()
      .from('devices')
      .select('fingerprint')
      .eq('user_id', userId)
      .eq('is_active', true)
      .maybeSingle();

    if (!boundDevice) {
      return true;
    }

    if (
      (boundDevice as { fingerprint: string }).fingerprint !== deviceFingerprint
    ) {
      const { data: approvedRequest } = await this.supabaseService
        .getClient()
        .from('device_change_requests')
        .select('id')
        .eq('user_id', userId)
        .eq('new_fingerprint', deviceFingerprint)
        .eq('status', 'approved')
        .maybeSingle();

      if (!approvedRequest) {
        throw new UnauthorizedException(
          'This account is bound to another device. Please use the authorized device or request a device change from settings.',
        );
      }
    }

    return true;
  }
}
