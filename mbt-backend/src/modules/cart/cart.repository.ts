import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import type { CartItemRow } from '../../common/types/cart.types';

@Injectable()
export class CartRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async findCartItems(cartId: string) {
    const { data: items, error } = await this.db
      .from('cart_items')
      .select(
        'id, course_id, created_at, courses:course_id(id, title, slug, short_description, thumbnail_url, price, discount_price, category, level, estimated_duration, total_lessons)',
      )
      .eq('cart_id', cartId)
      .order('created_at', { ascending: false });

    if (error) {
      throw new InternalServerErrorException('Failed to fetch cart');
    }

    return items as unknown as CartItemRow[];
  }

  async findCartItem(cartId: string, courseId: string) {
    const { data: existing, error } = await this.db
      .from('cart_items')
      .select('id')
      .eq('cart_id', cartId)
      .eq('course_id', courseId)
      .maybeSingle();

    if (error) {
      throw new InternalServerErrorException('Failed to check cart item');
    }

    return existing as { id: string } | null;
  }

  async insertCartItem(cartId: string, courseId: string) {
    const { error } = await this.db
      .from('cart_items')
      .insert({ cart_id: cartId, course_id: courseId } as never);

    if (error) {
      throw new InternalServerErrorException('Failed to add item to cart');
    }
  }

  async deleteCartItem(cartId: string, courseId: string) {
    const { error } = await this.db
      .from('cart_items')
      .delete()
      .eq('cart_id', cartId)
      .eq('course_id', courseId);

    if (error) {
      throw new InternalServerErrorException('Failed to remove item from cart');
    }
  }

  async getCartItemCourseIds(cartId: string): Promise<string[]> {
    const { data, error } = await this.db
      .from('cart_items')
      .select('course_id')
      .eq('cart_id', cartId);

    if (error) return [];
    return (data as { course_id: string }[]).map((i) => i.course_id);
  }

  async getOrCreateCartId(userId: string): Promise<string> {
    const { data, error } = await this.db.rpc('get_or_create_cart', {
      p_user_id: userId,
    } as never);

    if (error) {
      throw new InternalServerErrorException('Failed to get or create cart');
    }

    return data;
  }
}
