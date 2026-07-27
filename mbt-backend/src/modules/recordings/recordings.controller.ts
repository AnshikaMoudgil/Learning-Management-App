import { Controller, Get, Param, Res, BadRequestException } from '@nestjs/common';
import type { Response } from 'express';
import { SupabaseService } from '../supabase/supabase.service';

@Controller('recordings')
export class RecordingsController {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  @Get('course/:courseId')
  async getRecordingsByCourse(
    @Param('courseId') courseId: string,
    @Res({ passthrough: true }) res?: Response,
  ) {
    if (!courseId) {
      throw new BadRequestException('courseId is required');
    }

    const { data, error } = await this.db
      .from('session_recordings')
      .select('*, sessions!inner(*)')
      .eq('sessions.course_id', courseId)
      .eq('processing_status', 'ready');

    if (error) {
      throw new BadRequestException(error.message);
    }

    res?.setHeader(
      'Cache-Control',
      's-maxage=300, stale-while-revalidate=600',
    );
    return data;
  }

  @Get(':id')
  async getRecordingDetail(
    @Param('id') id: string,
    @Res({ passthrough: true }) res?: Response,
  ) {
    const { data, error } = await this.db
      .from('session_recordings')
      .select('*, sessions(*)')
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    res?.setHeader(
      'Cache-Control',
      's-maxage=300, stale-while-revalidate=600',
    );
    return data;
  }
}
