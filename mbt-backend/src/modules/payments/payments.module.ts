import { Module } from '@nestjs/common';
import { SupabaseModule } from '../supabase/supabase.module';
import { CouponsModule } from '../coupons/coupons.module';
import { EnrollmentsModule } from '../enrollments/enrollments.module';
import { PaymentsController } from './payments.controller';
import { PaymentsService } from './payments.service';
import { RazorpayService } from './razorpay.service';
import { InvoicesModule } from '../invoices/invoices.module';

@Module({
  imports: [SupabaseModule, CouponsModule, EnrollmentsModule, InvoicesModule],
  controllers: [PaymentsController],
  providers: [PaymentsService, RazorpayService],
})
export class PaymentsModule {}
