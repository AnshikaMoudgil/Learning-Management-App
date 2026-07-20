import { Module } from '@nestjs/common';
import { SupabaseModule } from '../supabase/supabase.module';
import { StorageModule } from '../../storage/storage.module';
import {
  MediaAssetsController,
  MediaUploadController,
} from './media-assets.controller';
import { MediaAssetsService } from './media-assets.service';
import { MediaCleanupService } from './media-cleanup.service';

@Module({
  imports: [SupabaseModule, StorageModule],
  controllers: [MediaAssetsController, MediaUploadController],
  providers: [MediaAssetsService, MediaCleanupService],
  exports: [MediaAssetsService],
})
export class MediaAssetsModule {}
