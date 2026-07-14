import { Module } from '@nestjs/common';
import { SupabaseModule } from '../supabase/supabase.module';
import { EnrollmentsService } from './enrollments.service';

@Module({
  imports: [SupabaseModule],
  providers: [EnrollmentsService],
  exports: [EnrollmentsService],
})
export class EnrollmentsModule {}
