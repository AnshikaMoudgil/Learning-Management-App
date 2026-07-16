import { Module } from '@nestjs/common';
import { RecordingsController } from './recordings.controller';
import { SupabaseModule } from '../supabase/supabase.module';

@Module({
  imports: [SupabaseModule],
  controllers: [RecordingsController],
})
export class RecordingsModule {}
