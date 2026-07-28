import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
  Logger,
  NotFoundException,
  OnModuleInit,
} from '@nestjs/common';
import { createHash, randomBytes } from 'crypto';
import * as fs from 'fs';
import * as path from 'path';
import { MediaAssetsRepository } from './media-assets.repository';
import { StorageService } from '../../storage/storage.service';

interface MediaAssetRow {
  id: string;
  provider: string;
  storage_key: string | null;
  storage_url: string | null;
  checksum: string;
  mime_type: string;
  size: number;
  duration: number | null;
  width: number | null;
  height: number | null;
  fps: number | null;
  codec: string | null;
  bitrate: number | null;
  thumbnail_url: string | null;
  status: string;
  processing_error: string | null;
}

@Injectable()
export class MediaAssetsService implements OnModuleInit {
  private readonly playbackExpiresInSeconds = 45;
  private readonly logger = new Logger(MediaAssetsService.name);

  constructor(
    private readonly mediaAssetsRepository: MediaAssetsRepository,
    private readonly storageService: StorageService,
  ) {}

  async onModuleInit() {
    const tempDir = path.join(process.cwd(), 'temp_uploads');
    if (!fs.existsSync(tempDir)) {
      try {
        fs.mkdirSync(tempDir, { recursive: true });
      } catch (err) {
        this.logger.error(`Failed to create temp_uploads directory: ${err}`);
      }
      return;
    }

    try {
      const files = await fs.promises.readdir(tempDir);
      const now = Date.now();
      const twentyFourHoursAgo = now - 24 * 60 * 60 * 1000;

      for (const file of files) {
        const filePath = path.join(tempDir, file);
        try {
          const stats = await fs.promises.stat(filePath);
          if (stats.mtimeMs < twentyFourHoursAgo) {
            await fs.promises.unlink(filePath);
            this.logger.log(`Cleaned up old temp file: ${file}`);
          }
        } catch (err) {
          this.logger.error(`Error processing temp file ${file}: ${err}`);
        }
      }
    } catch (err) {
      this.logger.error(
        `Failed to clean up temp_uploads directory on startup: ${err}`,
      );
    }
  }

  private getFileChecksum(filePath: string): Promise<string> {
    return new Promise((resolve, reject) => {
      const hash = createHash('sha256');
      const stream = fs.createReadStream(filePath);
      stream.on('data', (data) => hash.update(data));
      stream.on('end', () => resolve(hash.digest('hex')));
      stream.on('error', (err) => reject(err));
    });
  }

  async createVideoAsset(
    userId: string,
    file?: Express.Multer.File,
    lessonId?: string,
  ) {
    if (!file) {
      throw new BadRequestException('No video file uploaded');
    }

    let checksum: string;
    try {
      checksum = await this.getFileChecksum(file.path);
    } catch (err) {
      await fs.promises.unlink(file.path).catch(() => {});
      throw new InternalServerErrorException(
        `Failed to calculate file hash: ${
          err instanceof Error ? err.message : String(err)
        }`,
      );
    }

    const existing = await this.mediaAssetsRepository.findExistingAssetByChecksum(checksum);
    if (existing) {
      await fs.promises.unlink(file.path).catch(() => {});
      if (lessonId) {
        await this.mediaAssetsRepository.updateLessonVideoAsset(lessonId, existing.id as string);
      }
      return { asset: existing, duplicate: true };
    }

    const insertData = await this.mediaAssetsRepository.insertMediaAsset({
      provider: 'pending',
      checksum,
      mime_type: file.mimetype,
      size: file.size,
      status: 'UPLOADING',
      uploaded_by: userId,
      uploaded_at: new Date().toISOString(),
    });

    const assetId = insertData.id;
    const fileName = this.buildStorageKey(assetId, file.originalname);

    try {
      const uploadResult = await this.storageService.upload(
        file.path,
        fileName,
        file.mimetype,
      );

      await this.markReady(assetId, uploadResult);

      if (lessonId) {
        await this.mediaAssetsRepository.updateLessonVideoAsset(lessonId, assetId);
      }

      await this.audit(userId, 'upload', assetId, { lessonId });

      const asset = await this.mediaAssetsRepository.findMediaAssetById(assetId);

      return { asset: asset as unknown as MediaAssetRow, duplicate: false };
    } catch (uploadError) {
      const message =
        uploadError instanceof Error
          ? uploadError.message
          : 'Unknown upload error';
      this.logger.error(`Upload failed for asset ${assetId}: ${message}`);
      await this.markFailed(assetId, uploadError);
      throw new InternalServerErrorException(`Video upload failed: ${message}`);
    } finally {
      await fs.promises.unlink(file.path).catch((unlinkErr) => {
        this.logger.error(
          `Failed to delete temp file ${file.path}: ${unlinkErr}`,
        );
      });
    }
  }

  async createDirectUrlAsset(
    userId: string,
    videoUrl: string,
    lessonId?: string,
  ) {
    const trimmedUrl = videoUrl?.trim();
    if (!trimmedUrl) {
      throw new BadRequestException('Video URL is required');
    }

    let parsed: URL;
    try {
      parsed = new URL(trimmedUrl);
    } catch {
      throw new BadRequestException('Video URL must be a valid URL');
    }

    if (!['http:', 'https:'].includes(parsed.protocol)) {
      throw new BadRequestException('Video URL must use HTTP or HTTPS');
    }

    const checksum = createHash('sha256').update(trimmedUrl).digest('hex');
    const existing = await this.mediaAssetsRepository.findExistingAssetByChecksum(checksum);
    if (existing) {
      if (lessonId) {
        await this.mediaAssetsRepository.updateLessonVideoAsset(lessonId, existing.id as string);
      }
      return { asset: existing, duplicate: true };
    }

    const asset = await this.mediaAssetsRepository.insertMediaAssetFull({
      provider: 'direct_url',
      storage_key: trimmedUrl,
      storage_url: trimmedUrl,
      checksum,
      mime_type: 'video/external',
      size: 0,
      status: 'READY',
      uploaded_by: userId,
      uploaded_at: new Date().toISOString(),
    });

    if (lessonId) {
      await this.mediaAssetsRepository.updateLessonVideoAsset(lessonId, asset.id as string);
    }
    await this.audit(userId, 'upload', asset.id as string, { lessonId, directUrl: true });

    return { asset: asset as unknown as MediaAssetRow, duplicate: false };
  }

  async markReady(
    assetId: string,
    uploadResult: Awaited<ReturnType<StorageService['upload']>>,
  ) {
    await this.mediaAssetsRepository.updateMediaAsset(assetId, {
      provider: uploadResult.provider,
      storage_key: uploadResult.key,
      storage_url: uploadResult.url,
      mime_type: uploadResult.mimeType,
      size: uploadResult.size,
      duration: uploadResult.duration ?? null,
      width: uploadResult.width ?? null,
      height: uploadResult.height ?? null,
      fps: uploadResult.fps ?? null,
      codec: uploadResult.codec ?? null,
      bitrate: uploadResult.bitrate ?? null,
      thumbnail_url: uploadResult.thumbnailUrl ?? null,
      status: 'READY',
      processing_error: null,
    });
  }

  async markFailed(assetId: string, error: unknown) {
    const message =
      error instanceof Error ? error.message : 'Unknown processing failure';
    await this.mediaAssetsRepository.updateMediaAsset(assetId, {
      status: 'FAILED',
      processing_error: message,
    });
    await this.mediaAssetsRepository.insertAuditLog({
      media_asset_id: assetId,
      action: 'processing_failure',
      metadata: { message },
    });
  }

  async getPlaybackInfo(assetId: string, userId: string) {
    const asset = await this.getReadyAsset(assetId);
    await this.assertPlaybackAccess(asset.id as string, userId);

    if (!asset.storage_key) {
      throw new NotFoundException('Media asset storage key is missing');
    }

    const [playbackUrl, profile] = await Promise.all([
      asset.provider === 'direct_url'
        ? Promise.resolve(asset.storage_url ?? asset.storage_key)
        : this.storageService.getSignedUrl(
            asset.storage_key as string,
            this.playbackExpiresInSeconds,
          ),
      this.mediaAssetsRepository.findProfileById(userId),
    ]);

    if (!playbackUrl) {
      throw new NotFoundException('Media asset playback URL is missing');
    }

    const watermark = this.buildWatermark(userId, profile);
    await this.audit(userId, 'playback_request', asset.id as string, {
      expiresIn: this.playbackExpiresInSeconds,
      sessionId: watermark.sessionId,
    });

    return {
      playbackUrl,
      expiresIn: this.playbackExpiresInSeconds,
      asset: {
        id: asset.id,
        provider: asset.provider,
        mimeType: asset.mime_type,
        duration: asset.duration,
        width: asset.width,
        height: asset.height,
        thumbnailUrl: asset.thumbnail_url,
      },
      watermark,
    };
  }

  async getPlaybackInfoForLesson(lessonId: string, userId: string) {
    const lesson = await this.mediaAssetsRepository.findLessonVideoInfo(lessonId);

    if (!lesson) {
      throw new NotFoundException('Lesson not found');
    }

    if (lesson.video_asset_id) {
      return this.getPlaybackInfo(lesson.video_asset_id, userId);
    }

    if (lesson.video_url) {
      return {
        playbackUrl: lesson.video_url,
        expiresIn: null,
        asset: {
          id: null,
          provider: 'direct_url',
          mimeType: 'video/mp4',
          duration: null,
          width: null,
          height: null,
          thumbnailUrl: null,
        },
        watermark: null,
      };
    }

    throw new NotFoundException('Lesson does not have a media asset');
  }

  private async getReadyAsset(assetId: string) {
    const data = await this.mediaAssetsRepository.findReadyAsset(assetId);

    if (!data) {
      throw new NotFoundException('Ready media asset not found');
    }
    return data;
  }

  private async assertPlaybackAccess(assetId: string, userId: string) {
    const lessons = await this.mediaAssetsRepository.findLessonsByAssetId(assetId);

    const rows = lessons as unknown as Array<{ id: string; course_id: string; is_free_preview: boolean }>;
    if (rows.some((lesson) => lesson.is_free_preview)) {
      return;
    }

    const courseIds = rows.map((lesson) => lesson.course_id);
    if (!courseIds.length) {
      throw new ForbiddenException('Media asset is not attached to a lesson');
    }

    const enrollments = await this.mediaAssetsRepository.findEnrollmentsByUserAndCourses(userId, courseIds);

    if (!enrollments?.length) {
      throw new ForbiddenException('You are not enrolled for this media asset');
    }
  }

  private buildWatermark(userId: string, profile: { full_name: string | null; email: string | null; phone: string | null } | null) {
    const sessionId = randomBytes(3).toString('hex').toUpperCase();
    return {
      userName: profile?.full_name ?? 'Learner',
      email: profile?.email ?? null,
      timestamp: new Date().toISOString(),
      sessionId,
      rotationSeconds: 5,
      opacityRange: { min: 0.22, max: 0.34 },
      positionStrategy: 'rotate',
      seed: createHash('sha256')
        .update(`${userId}:${sessionId}`)
        .digest('hex')
        .slice(0, 16),
    };
  }

  private buildStorageKey(assetId: string, originalName: string) {
    const extension = originalName.includes('.')
      ? originalName.slice(originalName.lastIndexOf('.'))
      : '.mp4';
    return `course-videos/${assetId}${extension}`;
  }

  private async audit(
    userId: string,
    action: string,
    assetId: string,
    metadata?: Record<string, unknown>,
  ) {
    await this.mediaAssetsRepository.insertAuditLog({
      user_id: userId,
      media_asset_id: assetId,
      action,
      metadata: metadata ?? {},
    });
  }
}
