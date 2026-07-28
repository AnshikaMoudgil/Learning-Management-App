import { Injectable } from '@nestjs/common';
import { WishlistRepository } from './wishlist.repository';

@Injectable()
export class WishlistService {
  constructor(private readonly wishlistRepository: WishlistRepository) {}

  async getWishlist(userId: string) {
    const data = await this.wishlistRepository.findAllByUserId(userId);
    return { items: data || [] };
  }

  async addToWishlist(userId: string, courseId: string) {
    const item = await this.wishlistRepository.insert(userId, courseId);
    if (!item) {
      return { success: true, message: 'Already in wishlist' };
    }
    return { success: true, item };
  }

  async removeFromWishlist(userId: string, courseId: string) {
    await this.wishlistRepository.delete(userId, courseId);
    return { success: true };
  }
}
