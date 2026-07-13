import {
  Controller,
  Get,
  Patch,
  Post,
  Delete,
  Body,
  UseGuards,
  Req,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import { SkipDeviceCheck } from '../../common/decorators/skip-device-check.decorator';
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { CreateProfileDto } from './dto/create-profile.dto';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';

@Controller('api/v1/users')
@UseGuards(AuthGuard, DeviceGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  getProfile(@Req() req: AuthenticatedRequest) {
    return this.usersService.getProfile(req.user.id);
  }

  @Patch('me')
  updateProfile(
    @Req() req: AuthenticatedRequest,
    @Body() body: UpdateProfileDto,
  ) {
    return this.usersService.updateProfile(req.user.id, body);
  }

  @Post('me/complete')
  @SkipDeviceCheck()
  completeProfile(
    @Req() req: AuthenticatedRequest,
    @Body() body: CreateProfileDto,
  ) {
    return this.usersService.completeProfile(req.user.id, body);
  }

  @Post('me/login-details')
  updateLoginDetails(@Req() req: AuthenticatedRequest) {
    return this.usersService.updateLoginDetails(req.user.id);
  }

  @Post('me/photo')
  @UseInterceptors(FileInterceptor('photo'))
  uploadAvatar(
    @Req() req: AuthenticatedRequest,
    @UploadedFile() file: Express.Multer.File,
  ) {
    if (!file) {
      throw new BadRequestException('No photo file uploaded');
    }
    return this.usersService.uploadAvatar(
      req.user.id,
      file.buffer,
      file.originalname,
      file.mimetype,
    );
  }

  @Delete('me/photo')
  deleteAvatar(@Req() req: AuthenticatedRequest) {
    return this.usersService.deleteAvatar(req.user.id);
  }
}
