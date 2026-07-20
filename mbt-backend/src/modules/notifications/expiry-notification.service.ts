import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { NotificationsService } from './notifications.service';

@Injectable()
export class ExpiryNotificationService implements OnModuleInit {
  private readonly logger = new Logger(ExpiryNotificationService.name);
  private intervalHandle: ReturnType<typeof setInterval> | null = null;

  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly notificationsService: NotificationsService,
  ) {}

  private get db() {
    return this.supabaseService.getClient();
  }

  async onModuleInit() {
    await this.checkExpirations();
    this.intervalHandle = setInterval(
      () => {
        void this.checkExpirations();
      },
      24 * 60 * 60 * 1000,
    );
  }

  onModuleDestroy() {
    if (this.intervalHandle) clearInterval(this.intervalHandle);
  }

  private async checkExpirations() {
    this.logger.log('Checking enrollment expirations...');
    const now = new Date();

    try {
      await this.notifyExpiringSoon(now);
      await this.notifyAlreadyExpired(now);
    } catch (err) {
      this.logger.error(`Expiry check failed: ${(err as Error).message}`);
    }

    this.logger.log('Enrollment expiry check complete');
  }

  private async notifyExpiringSoon(now: Date) {
    const in30Days = new Date(
      now.getTime() + 30 * 24 * 60 * 60 * 1000,
    ).toISOString();
    const nowISO = now.toISOString();

    const { data, error } = await this.db
      .from('enrollments')
      .select('user_id, course_id, validity_end_at, courses(title)')
      .eq('status', 'active')
      .gt('validity_end_at', nowISO)
      .lte('validity_end_at', in30Days);

    if (error) {
      this.logger.error(
        `Failed to fetch expiring enrollments: ${error.message}`,
      );
      return;
    }

    if (!data?.length) return;

    const rows = data as unknown as {
      user_id: string;
      course_id: string;
      validity_end_at: string;
      courses: { title: string } | null;
    }[];

    const userMap = new Map<
      string,
      { course_id: string; title: string; daysLeft: number }[]
    >();
    for (const row of rows) {
      const daysLeft = Math.ceil(
        (new Date(row.validity_end_at).getTime() - now.getTime()) /
          (1000 * 60 * 60 * 24),
      );
      if (!userMap.has(row.user_id)) userMap.set(row.user_id, []);
      userMap.get(row.user_id)!.push({
        course_id: row.course_id,
        title: row.courses?.title ?? 'a course',
        daysLeft,
      });
    }

    for (const [userId, courses] of userMap) {
      const alreadyNotified =
        await this.notificationsService.wasNotifiedRecently(
          userId,
          'expiry_alert',
        );
      if (alreadyNotified) continue;

      const courseList = courses.map((c) => c.title).join(', ');
      const minDays = Math.min(...courses.map((c) => c.daysLeft));
      await this.notificationsService.notify(userId, {
        type: 'expiry_alert',
        title: minDays <= 3 ? 'Course Expiring Soon!' : 'Courses Expiring Soon',
        body:
          minDays <= 3
            ? `"${courseList}" will expire in ${minDays} day${minDays > 1 ? 's' : ''}! Renew now.`
            : `${courses.length} course${courses.length > 1 ? 's' : ''} expiring in ${minDays} days.`,
        data: { course_ids: courses.map((c) => c.course_id).join(',') },
      });
    }
  }

  private async notifyAlreadyExpired(now: Date) {
    const nowISO = now.toISOString();

    const { data, error } = await this.db
      .from('enrollments')
      .select('user_id, course_id, validity_end_at, courses(title)')
      .eq('status', 'active')
      .lt('validity_end_at', nowISO);

    if (error) {
      this.logger.error(
        `Failed to fetch expired enrollments: ${error.message}`,
      );
      return;
    }

    if (!data?.length) return;

    const rows = data as unknown as {
      user_id: string;
      course_id: string;
      validity_end_at: string;
      courses: { title: string } | null;
    }[];

    const userMap = new Map<string, { course_id: string; title: string }[]>();
    for (const row of rows) {
      if (!userMap.has(row.user_id)) userMap.set(row.user_id, []);
      userMap.get(row.user_id)!.push({
        course_id: row.course_id,
        title: row.courses?.title ?? 'a course',
      });
    }

    for (const [userId, courses] of userMap) {
      const alreadyNotified =
        await this.notificationsService.wasNotifiedRecently(
          userId,
          'expiry_expired',
        );
      if (alreadyNotified) continue;

      const courseList = courses.map((c) => c.title).join(', ');
      await this.notificationsService.notify(userId, {
        type: 'expiry_expired',
        title: 'Course Expired',
        body: `"${courseList}" has expired. Renew your access to continue learning.`,
        data: { course_ids: courses.map((c) => c.course_id).join(',') },
      });
    }
  }
}
