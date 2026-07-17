import { Injectable, InternalServerErrorException, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class WishlistService {
  private readonly logger = new Logger(WishlistService.name);

  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async getWishlist(userId: string) {
    const { data, error } = await (this.db.from('wishlists') as any)
      .select('*, courses(*, profiles!courses_instructor_id_fkey(full_name))')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) {
      this.logger.error(`Failed to fetch wishlist: ${error.message}`);
      throw new InternalServerErrorException('Failed to fetch wishlist');
    }

    return { items: data || [] };
  }

  async addToWishlist(userId: string, courseId: string) {
    const { data, error } = await (this.db.from('wishlists') as any)
      .insert({ user_id: userId, course_id: courseId })
      .select()
      .maybeSingle();

    if (error) {
      // 23505 is PostgreSQL unique violation error code
      if (error.code === '23505') {
        return { success: true, message: 'Already in wishlist' };
      }
      this.logger.error(`Failed to add to wishlist: ${error.message}`);
      throw new InternalServerErrorException('Failed to add to wishlist');
    }

    return { success: true, item: data };
  }

  async removeFromWishlist(userId: string, courseId: string) {
    const { error } = await (this.db.from('wishlists') as any)
      .delete()
      .eq('user_id', userId)
      .eq('course_id', courseId);

    if (error) {
      this.logger.error(`Failed to remove from wishlist: ${error.message}`);
      throw new InternalServerErrorException('Failed to remove from wishlist');
    }

    return { success: true };
  }
}
