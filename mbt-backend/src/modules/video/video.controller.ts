import {
  Controller,
  Get,
  Param,
  Redirect,
  Req,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';
import { MediaAssetsService } from '../media-assets/media-assets.service';

interface PlaybackResponse {
  playbackUrl: string;
}

@Controller('api/v1/video')
@UseGuards(AuthGuard, RolesGuard, DeviceGuard)
@Roles('learner', 'admin', 'superadmin', 'instructor')
export class VideoController {
  constructor(private readonly mediaAssetsService: MediaAssetsService) {}

  @Get('playback/:lessonId')
  getPlaybackInfo(
    @Req() req: AuthenticatedRequest,
    @Param('lessonId') lessonId: string,
  ): Promise<unknown> {
    return this.mediaAssetsService.getPlaybackInfoForLesson(
      lessonId,
      req.user.id,
    );
  }

  @Get('proxy/:lessonId')
  @Redirect(undefined, 302)
  async proxyLessonVideo(
    @Req() req: AuthenticatedRequest,
    @Param('lessonId') lessonId: string,
  ) {
    const playback = (await this.mediaAssetsService.getPlaybackInfoForLesson(
      lessonId,
      req.user.id,
    )) as PlaybackResponse;

    return { url: playback.playbackUrl };
  }
}
