import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import { ThrottleGuard } from '../../common/guards/throttle.guard';
import { Throttle } from '../../common/decorators/throttle.decorator';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';
import { ValidateCouponDto } from './dto/validate-coupon.dto';
import { ValidateCartCouponDto } from './dto/validate-cart-coupon.dto';
import { CouponsService } from './coupons.service';

@Controller('api/v1/coupons')
@UseGuards(AuthGuard, DeviceGuard)
export class CouponsController {
  constructor(private readonly couponsService: CouponsService) {}

  @Get('active')
  getActive() {
    return this.couponsService.getActiveCoupons();
  }

  @Post('validate')
  @UseGuards(ThrottleGuard)
  @Throttle({ limit: 10, windowMs: 60000 })
  async validate(
    @Req() req: AuthenticatedRequest,
    @Body() body: ValidateCouponDto,
  ) {
    const result = await this.couponsService.validateCoupon(
      body.code,
      body.courseId,
    );
    if (result.valid && result.couponId) {
      await this.couponsService.assertUserCouponNotUsed(
        req.user.id,
        result.couponId,
      );
    }
    return result;
  }

  @Post('validate-cart')
  @UseGuards(ThrottleGuard)
  @Throttle({ limit: 10, windowMs: 60000 })
  validateCart(
    @Req() req: AuthenticatedRequest,
    @Body() body: ValidateCartCouponDto,
  ) {
    return this.couponsService.validateCouponForCart(
      body.code,
      body.courseIds,
      req.user.id,
    );
  }
}
