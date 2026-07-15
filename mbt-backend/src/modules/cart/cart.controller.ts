import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { IsUUID } from 'class-validator';
import { AuthGuard } from '../../common/guards/auth.guard';
import { DeviceGuard } from '../../common/guards/device.guard';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';
import { CartService } from './cart.service';

class AddCartItemDto {
  @IsUUID()
  courseId!: string;
}

@Controller('api/v1/cart')
@UseGuards(AuthGuard, DeviceGuard)
export class CartController {
  constructor(private readonly cartService: CartService) {}

  @Get()
  findCart(@Req() req: AuthenticatedRequest) {
    return this.cartService.findCart(req.user.id);
  }

  @Post('items')
  addItem(@Req() req: AuthenticatedRequest, @Body() body: AddCartItemDto) {
    return this.cartService.addItem(req.user.id, body.courseId);
  }

  @Delete('items/:courseId')
  removeItem(
    @Req() req: AuthenticatedRequest,
    @Param('courseId') courseId: string,
  ) {
    return this.cartService.removeItem(req.user.id, courseId);
  }
}
