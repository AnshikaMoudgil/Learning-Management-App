import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class ZoomOAuthRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async findExistingProvider(provider: string) {
    const { data: existing } = await (this.db.from('meeting_provider_accounts') as any)
      .select('id')
      .eq('provider', provider)
      .maybeSingle();

    return existing as { id: string } | null;
  }

  async upsertProvider(data: Record<string, unknown>, existingId?: string) {
    let query;

    if (existingId) {
      query = (this.db.from('meeting_provider_accounts') as any)
        .update(data)
        .eq('id', existingId);
    } else {
      query = (this.db.from('meeting_provider_accounts') as any).insert(data);
    }

    const { error } = await query;

    if (error) {
      throw new InternalServerErrorException('Failed to store Zoom connection');
    }
  }

  async updateProviderStatus(provider: string, status: string) {
    await (this.db.from('meeting_provider_accounts') as any)
      .update({ status })
      .eq('provider', provider);
  }

  async findActiveConnection(provider: string) {
    const { data } = await (this.db.from('meeting_provider_accounts') as any)
      .select('*')
      .eq('provider', provider)
      .eq('status', 'connected')
      .maybeSingle();

    return data as Record<string, unknown> | null;
  }

  async updateAccount(id: string, data: Record<string, unknown>) {
    await (this.db.from('meeting_provider_accounts') as any)
      .update(data)
      .eq('id', id);
  }
}
