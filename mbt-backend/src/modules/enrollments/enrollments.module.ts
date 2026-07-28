import { Module } from '@nestjs/common';
import { SupabaseModule } from '../supabase/supabase.module';
import { EnrollmentsService } from './enrollments.service';
import { EnrollmentsController } from './enrollments.controller';
import { EnrollmentsRepository } from './enrollments.repository';

@Module({
  imports: [SupabaseModule],
  providers: [EnrollmentsService, EnrollmentsRepository],
  controllers: [EnrollmentsController],
  exports: [EnrollmentsService],
})
export class EnrollmentsModule {}
