import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);
  private firebaseApp: admin.app.App | null = null;

  constructor(
    private readonly configService: ConfigService,
    private readonly supabaseService: SupabaseService,
  ) {}

  onModuleInit() {
    this.initializeFirebase();
  }

  private initializeFirebase() {
    if (admin.apps.length > 0) {
      this.firebaseApp = admin.apps[0];
      return;
    }

    const serviceAccountVar = this.configService.get<string>('fcmServiceAccountJson');

    if (!serviceAccountVar) {
      this.logger.warn(
        'FCM_SERVICE_ACCOUNT_JSON is not configured. FCM push notifications will be disabled.',
      );
      return;
    }

    try {
      let credentialObj: admin.ServiceAccount;
      if (serviceAccountVar.trim().startsWith('{')) {
        credentialObj = JSON.parse(serviceAccountVar) as admin.ServiceAccount;
      } else {
        // eslint-disable-next-line @typescript-eslint/no-require-imports
        credentialObj = require(serviceAccountVar) as admin.ServiceAccount;
      }

      this.firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(credentialObj),
      });
      this.logger.log('Firebase Admin SDK initialized successfully.');
    } catch (error) {
      this.logger.error(
        `Failed to initialize Firebase Admin SDK: ${(error as Error).message}`,
      );
    }
  }

  async sendPushNotification(
    tokens: string[],
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<void> {
    if (!this.firebaseApp) {
      this.logger.warn('Firebase Admin SDK not initialized. Skipping push notification.');
      return;
    }

    const uniqueTokens = Array.from(new Set(tokens.filter(t => !!t)));
    if (uniqueTokens.length === 0) return;

    try {
      const response = await admin.messaging(this.firebaseApp).sendEachForMulticast({
        tokens: uniqueTokens,
        notification: {
          title,
          body,
        },
        data: data || {},
      });

      this.logger.log(
        `Multicast push sent: ${response.successCount} success, ${response.failureCount} failure.`,
      );

      if (response.failureCount > 0) {
        const invalidTokens: string[] = [];
        response.responses.forEach((resp, index) => {
          if (!resp.success && resp.error) {
            const code = resp.error.code;
            if (
              code === 'messaging/registration-token-not-registered' ||
              code === 'messaging/invalid-registration-token'
            ) {
              invalidTokens.push(uniqueTokens[index]);
            }
          }
        });

        if (invalidTokens.length > 0) {
          this.logger.log(`Nullifying ${invalidTokens.length} invalid/unregistered FCM tokens.`);
          const db = this.supabaseService.getClient();
          const { error } = await db
            .from('devices')
            .update({ fcm_token: null } as never)
            .in('fcm_token', invalidTokens);

          if (error) {
            this.logger.error(`Failed to nullify invalid FCM tokens: ${error.message}`);
          }
        }
      }
    } catch (error) {
      this.logger.error(`Error sending multicast FCM notification: ${(error as Error).message}`);
    }
  }
}
