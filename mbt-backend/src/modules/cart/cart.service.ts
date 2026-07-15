import {
  ConflictException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import type { CartItemRow } from '../../common/types/cart.types';

@Injectable()
export class CartService {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async findCart(userId: string) {
    const cartId = await this.getOrCreateCartId(userId);

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
    const cartId = await this.getOrCreateCartId(userId);

    const { data: existing } = await this.db
      .from('cart_items')
      .select('id')
      .eq('cart_id', cartId)
      .eq('course_id', courseId)
      .maybeSingle();

    if (existing) {
      throw new ConflictException('Course already in cart');
    }

    const { error } = await this.db
      .from('cart_items')
      .insert({ cart_id: cartId, course_id: courseId } as never);

    if (error) {
      throw new InternalServerErrorException('Failed to add item to cart');
    }

    return { success: true };
  }

  async removeItem(userId: string, courseId: string) {
    const cartId = await this.getOrCreateCartId(userId);

    const { data: existing } = await this.db
      .from('cart_items')
      .select('id')
      .eq('cart_id', cartId)
      .eq('course_id', courseId)
      .maybeSingle();

    if (!existing) {
      throw new NotFoundException('Cart item not found');
    }

    const { error } = await this.db
      .from('cart_items')
      .delete()
      .eq('cart_id', cartId)
      .eq('course_id', courseId);

    if (error) {
      throw new InternalServerErrorException('Failed to remove item from cart');
    }

    return { success: true };
  }

  async getCartItemCourseIds(userId: string): Promise<string[]> {
    const cartId = await this.getOrCreateCartId(userId);
    const { data, error } = await this.db
      .from('cart_items')
      .select('course_id')
      .eq('cart_id', cartId);

    if (error) return [];
    return (data as { course_id: string }[]).map((i) => i.course_id);
  }

  private async getOrCreateCartId(userId: string): Promise<string> {
    const { data, error } = await this.db.rpc('get_or_create_cart', {
      p_user_id: userId,
    } as never);

    if (error) {
      throw new InternalServerErrorException('Failed to get or create cart');
    }

    return data;
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
