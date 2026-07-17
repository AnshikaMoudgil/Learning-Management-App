import { Controller, Get, Param, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Controller('recordings')
export class RecordingsController {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  @Get('course/:courseId')
  async getRecordingsByCourse(@Param('courseId') courseId: string) {
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

    return data;
  }

  @Get(':id')
  async getRecordingDetail(@Param('id') id: string) {
    const { data, error } = await this.db
      .from('session_recordings')
      .select('*, sessions(*)')
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }
}
