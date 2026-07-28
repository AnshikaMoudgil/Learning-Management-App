export interface ZoomCreateJob {
  sessionId: string;
  instructorId: string;
  title: string;
  startTime: string;
  duration: number;
}

export interface ZoomUpdateJob {
  instructorId: string;
  meetingId: string;
  topic?: string;
  start_time?: string;
  duration?: number;
}

export interface ZoomDeleteJob {
  instructorId: string;
  meetingId: string;
}

export interface ZoomDownloadJob {
  sessionId: string;
  instructorId: string;
  recordingId: string;
  downloadUrl: string;
  fileSize?: number;
}

export interface ZoomUploadJob {
  sessionId: string;
  recordingId: string;
  fileBase64: string;
  fileSize?: number;
}

export interface ZoomReminderJob {
  sessionId: string;
  type: 'reminder_24h' | 'reminder_1h' | 'reminder_10min';
}
