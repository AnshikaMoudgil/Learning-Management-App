import { Controller, Get, Post, Body, UseGuards, Req } from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { DevicesService } from './devices.service';
import { BindDeviceDto } from './dto/bind-device.dto';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';

@Controller('api/v1/devices')
@UseGuards(AuthGuard)
export class DevicesController {
  constructor(private readonly devicesService: DevicesService) {}

  @Get()
  getUserDevices(@Req() req: AuthenticatedRequest) {
    return this.devicesService.getUserDevices(req.user.id);
  }

  @Get('active')
  getActiveDevice(@Req() req: AuthenticatedRequest) {
    return this.devicesService.getActiveDevice(req.user.id);
  }

  @Post('bind')
  bindDevice(@Req() req: AuthenticatedRequest, @Body() body: BindDeviceDto) {
    return this.devicesService.bindDevice(
      req.user.id,
      body.fingerprint,
      body.platform,
    );
  }
}
