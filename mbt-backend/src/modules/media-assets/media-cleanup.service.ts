import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { MediaAssetsRepository } from './media-assets.repository';

@Injectable()
export class MediaCleanupService implements OnModuleInit {
  private readonly logger = new Logger(MediaCleanupService.name);
  private intervalHandle: ReturnType<typeof setInterval> | null = null;

  constructor(private readonly mediaAssetsRepository: MediaAssetsRepository) {}

  async onModuleInit() {
    await this.cleanup();
    this.intervalHandle = setInterval(
      () => {
        void this.cleanup();
      },
      24 * 60 * 60 * 1000,
    );
  }

  onModuleDestroy() {
    if (this.intervalHandle) {
      clearInterval(this.intervalHandle);
    }
  }

  async cleanup() {
    this.logger.log('Running media asset cleanup...');

    const oneWeekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString();
    const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString();

    await this.mediaAssetsRepository.markFailedAssetsAsDeleted(oneWeekAgo);
    await this.mediaAssetsRepository.markPendingAssetsAsFailed(oneHourAgo);
    await this.mediaAssetsRepository.markUploadingAssetsAsFailed(twoHoursAgo);

    this.logger.log('Media asset cleanup complete');
  }
}
