import {
  Body,
  Controller,
  Headers,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import { ThrottleGuard } from '../../common/guards/throttle.guard';
import { Throttle } from '../../common/decorators/throttle.decorator';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';
import { CreateOrderDto } from './dto/create-order.dto';
import { VerifyPaymentDto } from './dto/verify-payment.dto';
import { PaymentsService } from './payments.service';

interface RawBodyRequest extends Request {
  rawBody?: Buffer;
}

@Controller('api/v1/payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post('create-order')
  @UseGuards(AuthGuard, DeviceGuard, ThrottleGuard)
  @Throttle({ limit: 10, windowMs: 60000 })
  createOrder(@Req() req: AuthenticatedRequest, @Body() body: CreateOrderDto) {
    return this.paymentsService.createOrder(
      req.user.id,
      body.courseIds,
      body.couponCode,
      body.allowRenewal ?? false,
    );
  }

  @Post('verify')
  @UseGuards(AuthGuard, DeviceGuard, ThrottleGuard)
  @Throttle({ limit: 10, windowMs: 60000 })
  verify(@Body() body: VerifyPaymentDto) {
    return this.paymentsService.verifyPayment(body);
  }

  @Post('webhook')
  webhook(
    @Req() req: RawBodyRequest,
    @Headers('x-razorpay-signature') signature?: string,
  ) {
    return this.paymentsService.handleWebhook(req.rawBody, signature);
  }
}
