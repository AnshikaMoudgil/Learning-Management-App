import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class MediaCleanupService implements OnModuleInit {
  private readonly logger = new Logger(MediaCleanupService.name);
  private intervalHandle: ReturnType<typeof setInterval> | null = null;

  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

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

    const now = new Date().toISOString();

    const { error: failedError } = await this.db
      .from('media_assets')
      .update({ status: 'DELETED', updated_at: now })
      .eq('status', 'FAILED')
      .lt(
        'updated_at',
        new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString(),
      );

    if (failedError) {
      this.logger.error(
        `Failed to cleanup stale FAILED assets: ${failedError.message}`,
      );
    }

    const { error: pendingError } = await this.db
      .from('media_assets')
      .update({
        status: 'FAILED',
        processing_error: 'Timed out',
        updated_at: now,
      })
      .eq('status', 'PENDING')
      .lt('created_at', new Date(Date.now() - 60 * 60 * 1000).toISOString());

    if (pendingError) {
      this.logger.error(
        `Failed to cleanup stale PENDING assets: ${pendingError.message}`,
      );
    }

    const { error: uploadingError } = await this.db
      .from('media_assets')
      .update({
        status: 'FAILED',
        processing_error: 'Upload timed out',
        updated_at: now,
      })
      .eq('status', 'UPLOADING')
      .lt(
        'created_at',
        new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
      );

    if (uploadingError) {
      this.logger.error(
        `Failed to cleanup stale UPLOADING assets: ${uploadingError.message}`,
      );
    }

    this.logger.log('Media asset cleanup complete');
  }
}
