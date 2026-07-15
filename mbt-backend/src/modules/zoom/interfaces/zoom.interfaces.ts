// ============================================================
// Zoom API TypeScript Interfaces
// ============================================================

export interface ZoomMeetingSettings {
  waiting_room: boolean;
  join_before_host: boolean;
  mute_upon_entry: boolean;
  auto_recording: 'cloud' | 'local' | 'none';
  approval_type: 0 | 1 | 2; // 0 = auto, 1 = manual, 2 = none
}

export interface ZoomCreateMeetingPayload {
  topic: string;
  type: 2; // scheduled meeting
  start_time: string; // ISO 8601
  duration: number; // minutes
  timezone?: string;
  password?: string;
  settings: ZoomMeetingSettings;
}

export interface ZoomMeetingData {
  id: number;
  uuid: string;
  host_id: string;
  topic: string;
  type: number;
  start_time: string;
  duration: number;
  password: string;
  join_url: string;
  start_url: string;
}

export interface ZoomUpdateMeetingPayload {
  topic?: string;
  start_time?: string;
  duration?: number;
  settings?: Partial<ZoomMeetingSettings>;
}

export interface ZoomRecordingFile {
  id: string;
  meeting_id: string;
  recording_start: string;
  recording_end: string;
  file_type: string;
  file_size: number;
  play_url: string;
  download_url: string;
  status: string;
  recording_type: string;
}

export interface ZoomRecordingData {
  uuid: string;
  id: number;
  account_id: string;
  host_id: string;
  topic: string;
  start_time: string;
  duration: number;
  total_size: number;
  recording_count: number;
  recording_files: ZoomRecordingFile[];
}

// ============================================================
// Zoom Webhook Payloads
// ============================================================

export interface ZoomWebhookEvent {
  event: string;
  event_ts: number;
  payload: {
    account_id: string;
    object: ZoomWebhookObject;
  };
}

export interface ZoomWebhookObject {
  uuid: string;
  id: number;
  host_id: string;
  topic: string;
  type: number;
  start_time: string;
  timezone: string;
  duration: number;
  participant?: ZoomParticipant;
}

export interface ZoomParticipant {
  user_id: string;
  user_name: string;
  id: string;
  join_time: string;
  leave_time?: string;
  duration?: number;
  email?: string;
}
