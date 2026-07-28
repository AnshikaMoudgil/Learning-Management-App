import {
  Injectable,
  CanActivate,
  ExecutionContext,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Request } from 'express';
import { RedisService } from '../redis/redis.service';

export const THROTTLE_KEY = 'throttle';

export interface ThrottleOptions {
  limit: number;
  windowMs: number;
}

@Injectable()
export class ThrottleGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly redisService: RedisService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const options = this.reflector.getAllAndOverride<ThrottleOptions>(
      THROTTLE_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!options) return true;

    const request = context.switchToHttp().getRequest<Request>();
    const key = `throttle:${request.ip}:${request.path}`;
    const redis = this.redisService.getClient();

    if (!redis) {
      return true;
    }

    const windowSec = Math.ceil(options.windowMs / 1000);
    const current = await redis.incr(key);
    if (current === 1) {
      await redis.expire(key, windowSec);
    }

    if (current > options.limit) {
      throw new HttpException(
        'Too many requests',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    return true;
  }
}


