export class JoinSessionResponseDto {
  meeting_number: string;
  password?: string;
  join_url?: string;
  signature: string;
  display_name: string;
  role: 0 | 1;
  zoom_app_key: string;
}
