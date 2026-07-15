import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';

/**
 * Generates HMAC-SHA256 Meeting SDK signatures for Flutter clients.
 * Role 0 = attendee (student), Role 1 = host (instructor).
 * https://developers.zoom.us/docs/meeting-sdk/auth/
 */
@Injectable()
export class ZoomSdkService {
  constructor(private readonly configService: ConfigService) {}

  generateSignature(
    meetingNumber: string,
    role: 0 | 1,
    expiresInSeconds = 7200,
  ): string {
    const sdkKey = this.configService.get<string>('zoom.sdkKey')!;
    const sdkSecret = this.configService.get<string>('zoom.sdkSecret')!;

    const iat = Math.round(Date.now() / 1000);
    const exp = iat + expiresInSeconds;

    const payload = {
      sdkKey,
      mn: meetingNumber,
      role,
      iat,
      exp,
      tokenExp: exp,
    };

    const header = Buffer.from(
      JSON.stringify({ alg: 'HS256', typ: 'JWT' }),
    ).toString('base64url');
    const body = Buffer.from(JSON.stringify(payload)).toString('base64url');
    const message = `${header}.${body}`;

    const signature = crypto
      .createHmac('sha256', sdkSecret)
      .update(message)
      .digest('base64url');

    return `${message}.${signature}`;
  }
}
