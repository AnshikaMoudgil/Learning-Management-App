import { Injectable, InternalServerErrorException, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class WishlistRepository {
  private readonly logger = new Logger(WishlistRepository.name);

  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async findAllByUserId(userId: string) {
    const { data, error } = await this.db
      .from('wishlists')
      .select(
        `id, course_id, created_at,
         courses!inner(id, title, slug, thumbnail_url, price, discount_price, category, level, is_published,
           profiles!courses_instructor_id_fkey(full_name)
         )`,
      )
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) {
      this.logger.error(`Failed to fetch wishlist: ${error.message}`);
      throw new InternalServerErrorException('Failed to fetch wishlist');
    }

    return data || [];
  }

  async insert(userId: string, courseId: string) {
    const { data, error } = await this.db
      .from('wishlists')
      .insert({ user_id: userId, course_id: courseId } as never)
      .select()
      .maybeSingle();

    if (error) {
      if (error.code === '23505') {
        return null;
      }
      this.logger.error(`Failed to add to wishlist: ${error.message}`);
      throw new InternalServerErrorException('Failed to add to wishlist');
    }

    return data;
  }

  async delete(userId: string, courseId: string) {
    const { error } = await this.db
      .from('wishlists')
      .delete()
      .eq('user_id', userId)
      .eq('course_id', courseId);

    if (error) {
      this.logger.error(`Failed to remove from wishlist: ${error.message}`);
      throw new InternalServerErrorException('Failed to remove from wishlist');
    }
  }
}
