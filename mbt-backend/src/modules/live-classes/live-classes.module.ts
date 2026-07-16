import { Module } from '@nestjs/common';
import { SessionsController } from './sessions.controller';
import { SessionsService } from './sessions.service';
import { SessionsRepository } from './sessions.repository';
import { ZoomModule } from '../zoom/zoom.module';
import { SupabaseModule } from '../supabase/supabase.module';
import { BullModule } from '@nestjs/bullmq';

@Module({
  imports: [
    SupabaseModule,
    ZoomModule,
    BullModule.registerQueue(
      { name: 'zoom-create-meeting' },
      { name: 'zoom-update-meeting' },
      { name: 'zoom-delete-meeting' },
      { name: 'zoom-send-reminders' },
    ),
  ],
  controllers: [SessionsController],
  providers: [SessionsService, SessionsRepository],
  exports: [SessionsService, SessionsRepository],
})
export class LiveClassesModule {}
