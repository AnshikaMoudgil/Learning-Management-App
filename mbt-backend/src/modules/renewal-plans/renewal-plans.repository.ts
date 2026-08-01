import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

export interface RenewalPlanRow {
  id: string;
  course_id: string;
  label: string;
  duration_value: number;
  duration_unit: 'days' | 'months' | 'years';
  price: number;
  sort_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

@Injectable()
export class RenewalPlansRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async findActivePlansByCourseId(courseId: string): Promise<RenewalPlanRow[]> {
    const { data, error } = await this.db
      .from('course_renewal_plans')
      .select(
        'id, course_id, label, duration_value, duration_unit, price, sort_order, is_active, created_at, updated_at',
      )
      .eq('course_id', courseId)
      .eq('is_active', true)
      .order('sort_order', { ascending: true });

    if (error) {
      throw new Error(`Failed to fetch renewal plans: ${error.message}`);
    }

    return (data ?? []) as RenewalPlanRow[];
  }

  async findPlanById(planId: string): Promise<RenewalPlanRow | null> {
    const { data, error } = await this.db
      .from('course_renewal_plans')
      .select(
        'id, course_id, label, duration_value, duration_unit, price, sort_order, is_active, created_at, updated_at',
      )
      .eq('id', planId)
      .eq('is_active', true)
      .maybeSingle();

    if (error) {
      throw new Error(`Failed to fetch renewal plan: ${error.message}`);
    }

    return data as RenewalPlanRow | null;
  }
}
