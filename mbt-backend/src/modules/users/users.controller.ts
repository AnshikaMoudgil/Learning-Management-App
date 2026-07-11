import { Controller, Get, Patch, Post, Delete, Body, UseGuards, Req, UseInterceptors, UploadedFile, BadRequestException } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { CreateProfileDto } from './dto/create-profile.dto';
import { IsString, IsOptional } from 'class-validator';

class LoginDetailsDto {
  @IsString()
  @IsOptional()
  deviceId?: string;
}

@Controller('api/v1/users')
@UseGuards(AuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  getProfile(@Req() req: any) {
    return this.usersService.getProfile(req.user.id);
  }

  @Patch('me')
  updateProfile(@Req() req: any, @Body() body: UpdateProfileDto) {
    return this.usersService.updateProfile(req.user.id, body);
  }

  @Post('me/complete')
  completeProfile(@Req() req: any, @Body() body: CreateProfileDto) {
    return this.usersService.completeProfile(req.user.id, body);
  }

  @Post('me/login-details')
  updateLoginDetails(@Req() req: any, @Body() body: LoginDetailsDto) {
    return this.usersService.updateLoginDetails(req.user.id, body.deviceId);
  }

  @Post('me/photo')
  @UseInterceptors(FileInterceptor('photo'))
  uploadAvatar(@Req() req: any, @UploadedFile() file: Express.Multer.File) {
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
  deleteAvatar(@Req() req: any) {
    return this.usersService.deleteAvatar(req.user.id);
  }
}
