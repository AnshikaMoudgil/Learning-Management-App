import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { BullModule } from '@nestjs/bullmq';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { SupabaseModule } from './modules/supabase/supabase.module';
import configuration from './config/configuration';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { CoursesModule } from './modules/courses/courses.module';
import { EnrollmentsModule } from './modules/enrollments/enrollments.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { CouponsModule } from './modules/coupons/coupons.module';
import { LiveClassesModule } from './modules/live-classes/live-classes.module';
import { RecordingsModule } from './modules/recordings/recordings.module';
import { DevicesModule } from './modules/devices/devices.module';
import { CertificatesModule } from './modules/certificates/certificates.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { AuditLogsModule } from './modules/audit-logs/audit-logs.module';
import { SearchModule } from './modules/search/search.module';
import { InvoicesModule } from './modules/invoices/invoices.module';
import { CartModule } from './modules/cart/cart.module';
import { ZoomModule } from './modules/zoom/zoom.module';
import { ZoomQueuesModule } from './modules/queues/zoom-queues.module';
import { StorageModule } from './storage/storage.module';
import { ResourcesModule } from './modules/resources/resources.module';
import { MyCoursesModule } from './modules/my-courses/my-courses.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      envFilePath: '.env',
      load: [configuration],
      isGlobal: true,
    }),
    BullModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: () => {
        const rawUrl = process.env.REDIS_URL ?? '';
        const redisUrl = rawUrl.replace(/^["'\s]+|["'\s]+$/g, '').trim();
        if (!redisUrl) {
          throw new Error('REDIS_URL environment variable is required');
        }
        const parsed = new URL(redisUrl);
        const connection: {
          host: string;
          port: number;
          password: string | undefined;
          username: string | undefined;
          tls?: Record<string, unknown>;
        } = {
          host: parsed.hostname,
          port: parseInt(parsed.port, 10) || 6379,
          password: parsed.password || undefined,
          username: parsed.username || undefined,
        };
        if (parsed.protocol === 'rediss:') {
          connection.tls = {};
        }
        return {
          connection,
          defaultJobOptions: {
            removeOnComplete: true,
            removeOnFail: false,
          },
          defaultWorkerOptions: {
            stalledInterval: 60000,
          },
        };
      },
    }),
    SupabaseModule,
    AuthModule,
    UsersModule,
    CoursesModule,
    EnrollmentsModule,
    PaymentsModule,
    CouponsModule,
    LiveClassesModule,
    RecordingsModule,
    DevicesModule,
    CertificatesModule,
    NotificationsModule,
    AuditLogsModule,
    SearchModule,
    InvoicesModule,
    CartModule,
    ZoomModule,
    ZoomQueuesModule,
    StorageModule,
    ResourcesModule,
    MyCoursesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
