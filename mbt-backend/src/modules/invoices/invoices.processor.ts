import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { InvoicesService } from './invoices.service';

@Processor('invoices-queue')
export class InvoicesProcessor extends WorkerHost {
  private readonly logger = new Logger(InvoicesProcessor.name);

  constructor(private readonly invoicesService: InvoicesService) {
    super();
  }

  async process(
    job: Job<{ paymentId: string }, unknown, string>,
  ): Promise<{ success: boolean }> {
    this.logger.log(`Processing job ${job.id} of type ${job.name}`);
    if (job.name === 'generate-invoice') {
      const { paymentId } = job.data;
      try {
        await this.invoicesService.createInvoiceForPayment(paymentId);
      } catch (err) {
        this.logger.error(
          `Failed to process invoice generation for payment ${paymentId}: ${(err as Error).message}`,
        );
        throw err;
      }
    }
    return { success: true };
  }
}
