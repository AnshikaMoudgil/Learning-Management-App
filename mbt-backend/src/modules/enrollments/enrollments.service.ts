import { BadRequestException, Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class EnrollmentsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async enrollFromPayment(
    razorpayOrderId: string,
    razorpayPaymentId: string,
    razorpaySignature: string,
  ) {
    const { data, error } = await this.db.rpc('complete_payment_and_enroll', {
      p_order_id: razorpayOrderId,
      p_payment_id: razorpayPaymentId,
      p_signature: razorpaySignature,
    } as never);

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }
}
