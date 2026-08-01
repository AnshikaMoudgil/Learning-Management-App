import { Module } from '@nestjs/common';
import { SupabaseModule } from '../supabase/supabase.module';
import { RenewalPlansController } from './renewal-plans.controller';
import { RenewalPlansService } from './renewal-plans.service';
import { RenewalPlansRepository } from './renewal-plans.repository';

@Module({
  imports: [SupabaseModule],
  controllers: [RenewalPlansController],
  providers: [RenewalPlansService, RenewalPlansRepository],
  exports: [RenewalPlansService],
})
export class RenewalPlansModule {}
