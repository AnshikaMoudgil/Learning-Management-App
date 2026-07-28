import { Module } from '@nestjs/common';
import { SupabaseModule } from '../supabase/supabase.module';
import { ResourcesController } from './resources.controller';
import { ResourcesService } from './resources.service';
import { ResourcesRepository } from './resources.repository';

@Module({
  imports: [SupabaseModule],
  controllers: [ResourcesController],
  providers: [ResourcesService, ResourcesRepository],
})
export class ResourcesModule {}
