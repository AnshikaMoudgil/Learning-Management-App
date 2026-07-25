import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  UseGuards,
  Req,
} from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { DevicesService } from './devices.service';
import { BindDeviceDto } from './dto/bind-device.dto';
import { CreateChangeRequestDto } from './dto/create-change-request.dto';
import { ReviewChangeRequestDto } from './dto/review-change-request.dto';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';

@Controller('api/v1/devices')
@UseGuards(AuthGuard)
export class DevicesController {
  constructor(private readonly devicesService: DevicesService) {}

  @Get()
  @UseGuards(DeviceGuard)
  getUserDevices(@Req() req: AuthenticatedRequest) {
    return this.devicesService.getUserDevices(req.user.id);
  }

  @Get('active')
  @UseGuards(DeviceGuard)
  getActiveDevice(@Req() req: AuthenticatedRequest) {
    return this.devicesService.getActiveDevice(req.user.id);
  }

  @Post('bind')
  bindDevice(@Req() req: AuthenticatedRequest, @Body() body: BindDeviceDto) {
    return this.devicesService.bindDevice(
      req.user.id,
      body.fingerprint,
      body.platform,
      body.fcmToken,
    );
  }

  @Post('unbind-fcm')
  unbindFcm(
    @Req() req: AuthenticatedRequest,
    @Body() body: { fingerprint: string },
  ) {
    return this.devicesService.unbindFcmToken(req.user.id, body.fingerprint);
  }

  @Post('change-request')
  createChangeRequest(
    @Req() req: AuthenticatedRequest,
    @Body() body: CreateChangeRequestDto,
  ) {
    return this.devicesService.createChangeRequest(
      req.user.id,
      body.fingerprint,
      body.reason,
    );
  }

  @Get('change-requests')
  getUserChangeRequests(@Req() req: AuthenticatedRequest) {
    return this.devicesService.getUserChangeRequests(req.user.id);
  }

  @Get('admin/change-requests')
  @UseGuards(RolesGuard)
  @Roles('admin', 'superadmin')
  getPendingChangeRequests() {
    return this.devicesService.getPendingChangeRequests();
  }

  @Patch('admin/change-requests/:id')
  @UseGuards(RolesGuard)
  @Roles('admin', 'superadmin')
  reviewChangeRequest(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() body: ReviewChangeRequestDto,
  ) {
    return this.devicesService.reviewChangeRequest(
      id,
      req.user.id,
      body.status,
    );
  }
}
