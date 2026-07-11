import { Injectable, CanActivate, ExecutionContext, BadRequestException } from '@nestjs/common';
import { Observable } from 'rxjs';

@Injectable()
export class DeviceGuard implements CanActivate {
  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const request = context.switchToHttp().getRequest();
    const deviceFingerprint = request.headers['x-device-fingerprint'];

    if (!deviceFingerprint) {
      throw new BadRequestException('Missing X-Device-Fingerprint header');
    }

    // TODO: Verify device fingerprint matches the active bound device session in Redis/Postgres
    
    return true;
  }
}
