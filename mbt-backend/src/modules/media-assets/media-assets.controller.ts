import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Param,
  Post,
  Req,
  UploadedFile,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { AnyFilesInterceptor, FileInterceptor } from '@nestjs/platform-express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';
import { CreateVideoAssetDto } from './dto/create-video-asset.dto';
import { MediaAssetsService } from './media-assets.service';

const MAX_VIDEO_SIZE_BYTES = 1024 * 1024 * 1024;
const ALLOWED_VIDEO_MIME_TYPES = new Set([
  'video/mp4',
  'video/quicktime',
  'video/webm',
  'video/x-matroska',
]);

@Controller('api/v1/media-assets')
@UseGuards(AuthGuard, RolesGuard, DeviceGuard)
export class MediaAssetsController {
  constructor(private readonly mediaAssetsService: MediaAssetsService) {}

  @Post('video')
  @Roles('admin', 'superadmin', 'instructor')
  @UseInterceptors(
    FileInterceptor('video', {
      limits: { fileSize: MAX_VIDEO_SIZE_BYTES },
      fileFilter: (_req, file, cb) => {
        if (!ALLOWED_VIDEO_MIME_TYPES.has(file.mimetype)) {
          cb(new BadRequestException('Unsupported video MIME type'), false);
          return;
        }
        cb(null, true);
      },
    }),
  )
  uploadVideo(
    @Req() req: AuthenticatedRequest,
    @UploadedFile() file: Express.Multer.File,
    @Body() body: CreateVideoAssetDto,
  ): Promise<unknown> {
    if (!file && body.videoUrl) {
      return this.mediaAssetsService.createDirectUrlAsset(
        req.user.id,
        body.videoUrl,
        body.lessonId,
      );
    }
    return this.mediaAssetsService.createVideoAsset(
      req.user.id,
      file,
      body.lessonId,
    );
  }

  @Get(':assetId/playback')
  @Roles('learner', 'admin', 'superadmin', 'instructor')
  getPlaybackInfo(
    @Req() req: AuthenticatedRequest,
    @Param('assetId') assetId: string,
  ): Promise<unknown> {
    return this.mediaAssetsService.getPlaybackInfo(assetId, req.user.id);
  }
}

@Controller('api/v1/media')
@UseGuards(AuthGuard, RolesGuard, DeviceGuard)
export class MediaUploadController {
  constructor(private readonly mediaAssetsService: MediaAssetsService) {}

  @Post('upload-video')
  @Roles('admin', 'superadmin', 'instructor')
  @UseInterceptors(
    AnyFilesInterceptor({
      limits: { fileSize: MAX_VIDEO_SIZE_BYTES },
      fileFilter: (_req, file, cb) => {
        if (!ALLOWED_VIDEO_MIME_TYPES.has(file.mimetype)) {
          cb(new BadRequestException('Unsupported video MIME type'), false);
          return;
        }
        cb(null, true);
      },
    }),
  )
  uploadVideo(
    @Req() req: AuthenticatedRequest,
    @UploadedFiles() files: Express.Multer.File[],
    @Body() body: CreateVideoAssetDto,
  ): Promise<unknown> {
    const file = files?.find((item) =>
      ['file', 'video'].includes(item.fieldname),
    );

    if (file) {
      return this.mediaAssetsService.createVideoAsset(
        req.user.id,
        file,
        body.lessonId,
      );
    }

    return this.mediaAssetsService.createDirectUrlAsset(
      req.user.id,
      body.videoUrl ?? '',
      body.lessonId,
    );
  }
}
