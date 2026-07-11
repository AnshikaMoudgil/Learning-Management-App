import {
  Injectable,
  CanActivate,
  ExecutionContext,
  BadRequestException,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { Request } from 'express';

@Injectable()
export class DeviceGuard implements CanActivate {
  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const request = context.switchToHttp().getRequest<Request>();
    const deviceFingerprint = request.headers['x-device-fingerprint'];

    if (!deviceFingerprint || Array.isArray(deviceFingerprint)) {
      throw new BadRequestException('Missing X-Device-Fingerprint header');
    }

    return true;
  }
}
