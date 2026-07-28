import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class ZoomOAuthRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async findExistingProvider(provider: string) {
    const { data: existing } = await this.db
      .from('meeting_provider_accounts')
      .select('id')
      .eq('provider', provider)
      .maybeSingle();

    return existing as { id: string } | null;
  }

  async upsertProvider(data: Record<string, unknown>, existingId?: string) {
    const query = existingId
      ? this.db.from('meeting_provider_accounts').update(data).eq('id', existingId)
      : this.db.from('meeting_provider_accounts').insert(data);

    const { error } = await query;

    if (error) {
      throw new InternalServerErrorException('Failed to store Zoom connection');
    }
  }

  async updateProviderStatus(provider: string, status: string) {
    await this.db
      .from('meeting_provider_accounts')
      .update({ status })
      .eq('provider', provider);
  }

  async findActiveConnection(provider: string): Promise<Record<string, unknown> | null> {
    const { data } = await this.db
      .from('meeting_provider_accounts')
      .select('*')
      .eq('provider', provider)
      .eq('status', 'connected')
      .maybeSingle();

    return data;
  }

  async updateAccount(id: string, data: Record<string, unknown>) {
    await this.db
      .from('meeting_provider_accounts')
      .update(data)
      .eq('id', id);
  }
}
