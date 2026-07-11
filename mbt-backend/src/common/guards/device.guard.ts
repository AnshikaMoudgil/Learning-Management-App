import {
  Injectable,
  CanActivate,
  ExecutionContext,
  BadRequestException,
  UnauthorizedException,
} from '@nestjs/common';
import { Request } from 'express';
import { SupabaseService } from '../../modules/supabase/supabase.service';

@Injectable()
export class DeviceGuard implements CanActivate {
  constructor(private supabaseService: SupabaseService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<Request>();
    const deviceFingerprint = request.headers['x-device-fingerprint'];

    if (!deviceFingerprint || Array.isArray(deviceFingerprint)) {
      throw new BadRequestException('Missing X-Device-Fingerprint header');
    }

    const userId = (request as any).user?.id;
    if (!userId) {
      return true;
    }

    const { data: boundDevice } = await this.supabaseService
      .getClient()
      .from('devices')
      .select('fingerprint')
      .eq('user_id', userId)
      .maybeSingle();

    if (
      boundDevice &&
      (boundDevice as { fingerprint: string }).fingerprint !== deviceFingerprint
    ) {
      throw new UnauthorizedException(
        'This account is permanently bound to another device.',
      );
    }

    return true;
  }
}
