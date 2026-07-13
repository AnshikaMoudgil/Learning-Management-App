export type DeviceChangeRequestStatus = 'pending' | 'approved' | 'rejected';

export interface DeviceChangeRequest {
  id: string;
  user_id: string;
  old_fingerprint: string | null;
  new_fingerprint: string;
  reason: string | null;
  status: DeviceChangeRequestStatus;
  reviewed_by: string | null;
  reviewed_at: string | null;
  created_at: string;
  updated_at: string;
}
