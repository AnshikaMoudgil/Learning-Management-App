import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService implements OnModuleInit {
  private supabaseClient!: ReturnType<typeof createClient>;
  private readonly logger = new Logger(SupabaseService.name);

  constructor(private configService: ConfigService) {}

  async onModuleInit() {
    const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
    const supabaseKey =
      this.configService.get<string>('SUPABASE_SERVICE_ROLE_KEY') ||
      this.configService.get<string>('SUPABASE_ANON_KEY');

    if (!supabaseUrl || !supabaseKey) {
      throw new Error(
        'Supabase URL or Key is not defined in environment variables',
      );
    }

    this.supabaseClient = createClient(supabaseUrl, supabaseKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });

    await this.ensureStorageBucket('avatars');
  }

  private async ensureStorageBucket(name: string) {
    const { data: buckets } = await this.supabaseClient.storage.listBuckets();
    const exists = buckets?.some((b) => b.name === name);
    if (!exists) {
      this.logger.log(`Storage bucket "${name}" not found. Creating...`);
      const { error } = await this.supabaseClient.storage.createBucket(name, {
        public: true,
      });
      if (error) {
        this.logger.error(
          `Failed to create bucket "${name}": ${error.message}`,
        );
      } else {
        this.logger.log(`Storage bucket "${name}" created successfully.`);
      }
    }
  }

  getClient() {
    return this.supabaseClient;
  }
}
