import { Injectable, Logger } from '@nestjs/common';
import { ZoomAuthService } from './zoom-auth.service';

@Injectable()
export class ZoomRecordingService {
  private readonly logger = new Logger(ZoomRecordingService.name);

  constructor(private readonly zoomAuth: ZoomAuthService) {}

  async downloadRecording(
    instructorId: string,
    downloadUrl: string,
  ): Promise<Buffer> {
    const token = await this.zoomAuth.getAccessToken();

    this.logger.log(`Downloading Zoom recording from: ${downloadUrl}`);

    const response = await fetch(`${downloadUrl}?access_token=${token}`, {
      method: 'GET',
    });

    if (!response.ok) {
      const text = await response.text();
      this.logger.error(
        `Failed to download recording: ${response.status} ${text}`,
      );
      throw new Error(`Recording download failed: ${response.status}`);
    }

    const arrayBuffer = await response.arrayBuffer();
    return Buffer.from(arrayBuffer);
  }
}
