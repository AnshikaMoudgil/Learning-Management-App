import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { SupabaseService } from '../../supabase/supabase.service';
import { NotificationsService } from '../../notifications/notifications.service';

type ReminderType = 'reminder_24h' | 'reminder_1h' | 'reminder_10min';

interface SendReminderJob {
  sessionId: string;
  type: ReminderType;
}

const REMINDER_MESSAGES: Record<
  ReminderType,
  { title: string; body: (title: string) => string }
> = {
  reminder_24h: {
    title: 'Live Session Tomorrow',
    body: (title) => `"${title}" starts tomorrow. Make sure you are ready!`,
  },
  reminder_1h: {
    title: 'Session Starts in 1 Hour',
    body: (title) => `"${title}" starts in 1 hour.`,
  },
  reminder_10min: {
    title: 'Session Starting Soon',
    body: (title) => `"${title}" is starting in 10 minutes. Join now!`,
  },
};

@Processor('zoom-send-reminders')
export class ZoomSendRemindersProcessor extends WorkerHost {
  private readonly logger = new Logger(ZoomSendRemindersProcessor.name);

  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly notificationsService: NotificationsService,
  ) {
    super();
  }

  private get db() {
    return this.supabaseService.getClient();
  }

  async process(job: Job<SendReminderJob>): Promise<void> {
    const { sessionId, type } = job.data;

    // Fetch session + enrolled students
    const { data: session } = await this.db
      .from('sessions')
      .select('title, course_id, status')
      .eq('id', sessionId)
      .single();

    if (!session) {
      this.logger.warn(`Session ${sessionId} not found — skipping reminder`);
      return;
    }

    // Don't send reminders for cancelled sessions
    if ((session as any).status === 'cancelled') {
      this.logger.log(`Session ${sessionId} is cancelled — skipping reminder`);
      return;
    }

    const { data: enrollments } = await this.db
      .from('enrollments')
      .select('user_id')
      .eq('course_id', (session as any).course_id)
      .eq('status', 'active');

    if (!enrollments?.length) return;

    const userIds = (enrollments as any[]).map((e) => e.user_id);
    const template = REMINDER_MESSAGES[type];

    await this.notificationsService.notifyMany(userIds, {
      type,
      title: template.title,
      body: template.body((session as any).title),
      data: { session_id: sessionId, course_id: (session as any).course_id },
    });

    this.logger.log(
      `Reminder "${type}" sent to ${userIds.length} users for session ${sessionId}`,
    );
  }
}
