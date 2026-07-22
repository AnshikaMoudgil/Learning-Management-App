export interface UploadResult {
  provider: string;
  key: string;
  url: string;
  size: number;
  mimeType: string;
  duration?: number | null;
  width?: number | null;
  height?: number | null;
  fps?: number | null;
  codec?: string | null;
  bitrate?: number | null;
  thumbnailUrl?: string | null;
}
