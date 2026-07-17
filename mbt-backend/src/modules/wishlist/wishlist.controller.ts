import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  Req,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';
import { WishlistService } from './wishlist.service';

@Controller('api/v1/wishlist')
@UseGuards(AuthGuard, DeviceGuard)
export class WishlistController {
  constructor(private readonly wishlistService: WishlistService) {}

  @Get()
  async getWishlist(@Req() req: AuthenticatedRequest) {
    const userId = req.user.id;
    return this.wishlistService.getWishlist(userId);
  }

  @Post('items')
  async addToWishlist(
    @Req() req: AuthenticatedRequest,
    @Body('courseId') courseId: string,
  ) {
    const userId = req.user.id;
    return this.wishlistService.addToWishlist(userId, courseId);
  }

  @Delete('items/:courseId')
  async removeFromWishlist(
    @Req() req: AuthenticatedRequest,
    @Param('courseId') courseId: string,
  ) {
    const userId = req.user.id;
    return this.wishlistService.removeFromWishlist(userId, courseId);
  }
}
