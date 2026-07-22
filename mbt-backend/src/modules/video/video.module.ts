import { Module } from '@nestjs/common';
import { MediaAssetsModule } from '../media-assets/media-assets.module';
import { VideoController } from './video.controller';

@Module({
  imports: [MediaAssetsModule],
  controllers: [VideoController],
})
export class VideoModule {}
