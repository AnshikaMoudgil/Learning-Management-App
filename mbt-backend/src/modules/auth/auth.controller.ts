import { Controller, Post, Get, Body, UseGuards, Req, Query } from '@nestjs/common';
import { AuthService } from './auth.service';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { GoogleAuthDto } from './dto/google-auth.dto';
import { AuthGuard } from '../../common/guards/auth.guard';

@Controller('api/v1/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('send-otp')
  sendOtp(@Body() dto: SendOtpDto) {
    return this.authService.sendOtp(dto.phone);
  }

  @Post('verify-otp')
  verifyOtp(@Body() dto: VerifyOtpDto) {
    return this.authService.verifyOtp(dto.phone, dto.token, dto.deviceId);
  }

  @Post('google')
  googleAuth(@Body() dto: GoogleAuthDto) {
    return this.authService.authenticateWithGoogle(dto.idToken, dto.accessToken, dto.deviceId);
  }

  @Get('session')
  @UseGuards(AuthGuard)
  getSession(@Req() req: any, @Query('deviceId') deviceId?: string) {
    return this.authService.getSession(req.user.id, deviceId);
  }
}
