import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import Redis from 'ioredis';

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private redisClient: Redis | null = null;

  onModuleInit() {
    const rawUrl = process.env.REDIS_URL ?? '';
    const redisUrl = rawUrl.replace(/^["'\s]+|["'\s]+$/g, '').trim();
    if (redisUrl) {
      this.redisClient = new Redis(redisUrl);
    }
  }

  onModuleDestroy() {
    if (this.redisClient) {
      this.redisClient.disconnect();
    }
  }

  getClient(): Redis | null {
    return this.redisClient;
  }
}
