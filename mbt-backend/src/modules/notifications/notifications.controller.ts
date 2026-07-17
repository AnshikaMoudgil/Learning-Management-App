import {
  Controller,
  Get,
  Patch,
  Param,
  Request,
  Query,
  HttpCode,
} from '@nestjs/common';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';
import { NotificationsService } from './notifications.service';

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  /** GET /notifications?page=1&limit=20 */
  @Get()
  async getAll(
    @Request() req: AuthenticatedRequest,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const userId = req.user?.id;
    const { data, total } = await this.notificationsService.getNotifications(
      userId,
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
    );
    return { data, meta: { total } };
  }

  /** GET /notifications/unread-count */
  @Get('unread-count')
  async unreadCount(@Request() req: AuthenticatedRequest) {
    const userId = req.user?.id;
    const count = await this.notificationsService.getUnreadCount(userId);
    return { unread: count };
  }

  /** PATCH /notifications/:id/read */
  @Patch(':id/read')
  @HttpCode(200)
  async markOne(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    const userId = req.user?.id;
    await this.notificationsService.markRead(id, userId);
    return { success: true };
  }

  /** PATCH /notifications/read-all */
  @Patch('read-all')
  @HttpCode(200)
  async markAll(@Request() req: AuthenticatedRequest) {
    const userId = req.user?.id;
    await this.notificationsService.markAllRead(userId);
    return { success: true };
  }
}
