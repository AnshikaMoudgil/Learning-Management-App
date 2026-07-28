import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { InvoicesController } from './invoices.controller';
import { InvoicesService } from './invoices.service';
import { InvoicesRepository } from './invoices.repository';
import { PdfGeneratorService } from './pdf-generator.service';
import { InvoicesProcessor } from './invoices.processor';
import { SupabaseModule } from '../supabase/supabase.module';

@Module({
  imports: [
    BullModule.registerQueue({
      name: 'invoices-queue',
      defaultJobOptions: {
        attempts: 3,
        backoff: {
          type: 'fixed',
          delay: 300_000,
        },
      },
    }),
    SupabaseModule,
  ],
  controllers: [InvoicesController],
  providers: [InvoicesService, InvoicesRepository, PdfGeneratorService, InvoicesProcessor],
  exports: [InvoicesService, BullModule],
})
export class InvoicesModule {}
