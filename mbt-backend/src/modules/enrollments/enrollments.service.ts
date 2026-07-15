import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class EnrollmentsService {
  private readonly logger = new Logger(EnrollmentsService.name);

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
      this.logger.error(
        `RPC complete_payment_and_enroll failed: ${error.message}`,
        {
          razorpayOrderId,
          razorpayPaymentId,
          details: error.details,
          hint: error.hint,
          code: error.code,
        },
      );
      if (error.message?.includes('already enrolled')) {
        throw new BadRequestException(error.message);
      }
      throw new InternalServerErrorException('Failed to complete enrollment');
    }

    return data;
  }
}
