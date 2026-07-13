import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import { ValidateCouponDto } from './dto/validate-coupon.dto';
import { CouponsService } from './coupons.service';

@Controller('api/v1/coupons')
@UseGuards(AuthGuard, DeviceGuard)
export class CouponsController {
  constructor(private readonly couponsService: CouponsService) {}

  @Post('validate')
  validate(@Body() body: ValidateCouponDto) {
    return this.couponsService.validateCoupon(body.code, body.courseId);
  }
}
