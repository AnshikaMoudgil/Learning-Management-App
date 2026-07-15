import { Controller, Get, Request, UnauthorizedException } from '@nestjs/common';
import { ZoomMeetingService } from './zoom-meeting.service';

@Controller('zoom')
export class ZoomController {
  constructor(private readonly zoomMeetingService: ZoomMeetingService) {}

  @Get('status')
  async getStatus(@Request() req: any) {
    const instructorId = req.user?.id;
    if (!instructorId) {
      throw new UnauthorizedException('Authentication required');
    }
    return this.zoomMeetingService.getZoomStatus(instructorId);
  }
}
