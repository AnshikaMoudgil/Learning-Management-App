import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class MediaAssetsRepository {
  private readonly logger = new Logger(MediaAssetsRepository.name);

  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async insertMediaAsset(data: Record<string, unknown>) {
    const { data: insertData, error: insertError } = await this.db
      .from('media_assets')
      .insert(data as never)
      .select('id')
      .single();

    if (insertError) {
      throw new BadRequestException(insertError.message);
    }

    return insertData as { id: string };
  }

  async insertMediaAssetFull(input: Record<string, unknown>) {
    const { data, error } = await this.db
      .from('media_assets')
      .insert(input as never)
      .select('*')
      .single();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data as Record<string, unknown>;
  }

  async findMediaAssetById(assetId: string) {
    const { data: asset } = await this.db
      .from('media_assets')
      .select('*')
      .eq('id', assetId)
      .single();

    return asset as Record<string, unknown> | null;
  }

  async findLessonVideoInfo(lessonId: string) {
    const { data, error } = await this.db
      .from('course_lessons')
      .select('video_asset_id, video_url')
      .eq('id', lessonId)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }
    return data as {
      video_asset_id?: string | null;
      video_url?: string | null;
    } | null;
  }

  async findExistingAssetByChecksum(checksum: string) {
    const { data, error } = await this.db
      .from('media_assets')
      .select('*')
      .eq('checksum', checksum)
      .neq('status', 'DELETED')
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }
    return data as Record<string, unknown> | null;
  }

  async findReadyAsset(assetId: string) {
    const { data, error } = await this.db
      .from('media_assets')
      .select('id, storage_key, provider, storage_url, mime_type, duration, width, height, thumbnail_url')
      .eq('id', assetId)
      .eq('status', 'READY')
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }
    return data as Record<string, unknown> | null;
  }

  async findLessonsByAssetId(assetId: string) {
    const { data: lessons, error } = await this.db
      .from('course_lessons')
      .select('id, course_id, is_free_preview')
      .eq('video_asset_id', assetId);

    if (error) {
      throw new BadRequestException(error.message);
    }

    return (lessons ?? []) as Record<string, unknown>[];
  }

  async findEnrollmentsByUserAndCourses(userId: string, courseIds: string[]) {
    const { data: enrollments, error: enrollmentError } = await this.db
      .from('enrollments')
      .select('id')
      .eq('user_id', userId)
      .eq('status', 'active')
      .in('course_id', courseIds)
      .limit(1);

    if (enrollmentError) {
      throw new BadRequestException(enrollmentError.message);
    }

    return (enrollments ?? []) as { id: string }[];
  }

  async updateLessonVideoAsset(lessonId: string, assetId: string) {
    const { error } = await this.db
      .from('course_lessons')
      .update({ video_asset_id: assetId } as never)
      .eq('id', lessonId);

    if (error) {
      throw new BadRequestException(error.message);
    }
  }

  async updateMediaAsset(assetId: string, patch: Record<string, unknown>) {
    const { error } = await this.db
      .from('media_assets')
      .update({ ...patch, updated_at: new Date().toISOString() })
      .eq('id', assetId);

    if (error) {
      throw new BadRequestException(error.message);
    }
  }

  async findProfileById(userId: string) {
    const { data } = await this.db
      .from('profiles')
      .select('full_name, email, phone')
      .eq('id', userId)
      .maybeSingle();

    return data as { full_name: string | null; email: string | null; phone: string | null } | null;
  }

  async insertAuditLog(data: Record<string, unknown>) {
    await this.db
      .from('media_asset_audit_logs')
      .insert(data as never)
      .then(() => undefined);
  }

  async markFailedAssetsAsDeleted(beforeDate: string) {
    const { error: failedError } = await this.db
      .from('media_assets')
      .update({ status: 'DELETED', updated_at: new Date().toISOString() })
      .eq('status', 'FAILED')
      .lt('updated_at', beforeDate);

    if (failedError) {
      this.logger.error(
        `Failed to cleanup stale FAILED assets: ${failedError.message}`,
      );
    }
  }

  async markPendingAssetsAsFailed(beforeDate: string) {
    const { error: pendingError } = await this.db
      .from('media_assets')
      .update({
        status: 'FAILED',
        processing_error: 'Timed out',
        updated_at: new Date().toISOString(),
      })
      .eq('status', 'PENDING')
      .lt('created_at', beforeDate);

    if (pendingError) {
      this.logger.error(
        `Failed to cleanup stale PENDING assets: ${pendingError.message}`,
      );
    }
  }

  async markUploadingAssetsAsFailed(beforeDate: string) {
    const { error: uploadingError } = await this.db
      .from('media_assets')
      .update({
        status: 'FAILED',
        processing_error: 'Upload timed out',
        updated_at: new Date().toISOString(),
      })
      .eq('status', 'UPLOADING')
      .lt('created_at', beforeDate);

    if (uploadingError) {
      this.logger.error(
        `Failed to cleanup stale UPLOADING assets: ${uploadingError.message}`,
      );
    }
  }
}
