import {
  ConflictException,
  Injectable,
} from '@nestjs/common';
import { CartRepository } from './cart.repository';
import type { CartItemRow } from '../../common/types/cart.types';

@Injectable()
export class CartService {
  constructor(private readonly cartRepository: CartRepository) {}

  async findCart(userId: string) {
    const cartId = await this.cartRepository.getOrCreateCartId(userId);
    const items = await this.cartRepository.findCartItems(cartId);

    const cartItems = (items as unknown as CartItemRow[]).filter(
      (i) => i.courses,
    );
    const hardware = cartItems.filter((i) =>
      i.courses?.category?.toLowerCase().includes('hardware'),
    );
    const software = cartItems.filter(
      (i) => !i.courses?.category?.toLowerCase().includes('hardware'),
    );

    return {
      cartId,
      totalItems: cartItems.length,
      hardware: this.formatItems(hardware),
      software: this.formatItems(software),
    };
  }

  async addItem(userId: string, courseId: string) {
    const cartId = await this.cartRepository.getOrCreateCartId(userId);
    const existing = await this.cartRepository.findCartItem(cartId, courseId);

    if (existing) {
      throw new ConflictException('Course already in cart');
    }

    await this.cartRepository.insertCartItem(cartId, courseId);

    return { success: true };
  }

  async removeItem(userId: string, courseId: string) {
    const cartId = await this.cartRepository.getOrCreateCartId(userId);
    await this.cartRepository.deleteCartItem(cartId, courseId);

    return { success: true };
  }

  async getCartItemCourseIds(userId: string): Promise<string[]> {
    const cartId = await this.cartRepository.getOrCreateCartId(userId);
    return this.cartRepository.getCartItemCourseIds(cartId);
  }

  private formatItems(items: CartItemRow[]) {
    return items.map((item) => ({
      id: item.id,
      courseId: item.course_id,
      title: item.courses!.title,
      slug: item.courses!.slug,
      shortDescription: item.courses!.short_description,
      thumbnailUrl: item.courses!.thumbnail_url,
      price: Number(item.courses!.price),
      discountPrice:
        item.courses!.discount_price != null
          ? Number(item.courses!.discount_price)
          : null,
      effectivePrice: Number(
        item.courses!.discount_price ?? item.courses!.price,
      ),
      category: item.courses!.category,
      level: item.courses!.level,
      estimatedDuration: item.courses!.estimated_duration,
      totalLessons: item.courses!.total_lessons,
      addedAt: item.created_at,
    }));
  }
}
