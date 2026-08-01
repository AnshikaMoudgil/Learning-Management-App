import { Module } from '@nestjs/common';
import { SupabaseModule } from '../supabase/supabase.module';
import { CouponsModule } from '../coupons/coupons.module';
import { EnrollmentsModule } from '../enrollments/enrollments.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { PaymentsController } from './payments.controller';
import { PaymentsService } from './payments.service';
import { PaymentsRepository } from './payments.repository';
import { RazorpayService } from './razorpay.service';
import { InvoicesModule } from '../invoices/invoices.module';
import { RenewalPlansModule } from '../renewal-plans/renewal-plans.module';

@Module({
  imports: [
    SupabaseModule,
    CouponsModule,
    EnrollmentsModule,
    InvoicesModule,
    NotificationsModule,
    RenewalPlansModule,
  ],
  controllers: [PaymentsController],
  providers: [PaymentsService, PaymentsRepository, RazorpayService],
})
export class PaymentsModule {}
