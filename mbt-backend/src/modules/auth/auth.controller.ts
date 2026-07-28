import { Controller, Post, Get, Body, UseGuards, Req } from '@nestjs/common';
import { AuthService } from './auth.service';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { GoogleAuthDto } from './dto/google-auth.dto';
import { AuthGuard } from '../../common/guards/auth.guard';
import { ThrottleGuard } from '../../common/guards/throttle.guard';
import { Throttle } from '../../common/decorators/throttle.decorator';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';

@Controller('api/v1/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('send-otp')
  @UseGuards(ThrottleGuard)
  @Throttle({ limit: 5, windowMs: 60000 })
  sendOtp(@Body() dto: SendOtpDto) {
    return this.authService.sendOtp(dto.phone);
  }

  @Post('verify-otp')
  @UseGuards(ThrottleGuard)
  @Throttle({ limit: 10, windowMs: 60000 })
  verifyOtp(@Body() dto: VerifyOtpDto) {
    return this.authService.verifyOtp(dto.phone, dto.token);
  }

  @Post('google')
  @UseGuards(ThrottleGuard)
  @Throttle({ limit: 10, windowMs: 60000 })
  googleAuth(@Body() dto: GoogleAuthDto) {
    return this.authService.authenticateWithGoogle(
      dto.idToken,
      dto.accessToken,
    );
  }

  @Get('session')
  @UseGuards(AuthGuard)
  getSession(@Req() req: AuthenticatedRequest) {
    return this.authService.getSession(req.user.id);
  }
}
