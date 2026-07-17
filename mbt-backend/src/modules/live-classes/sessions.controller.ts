import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Request,
  HttpCode,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';
import { SessionsService } from './sessions.service';
import { CreateSessionDto } from './dto/create-session.dto';
import { UpdateSessionDto } from './dto/update-session.dto';

@Controller('sessions')
export class SessionsController {
  constructor(private readonly sessionsService: SessionsService) {}

  @Post()
  @UseGuards(AuthGuard)
  async create(
    @Request() req: AuthenticatedRequest,
    @Body() dto: CreateSessionDto,
  ) {
    return this.sessionsService.createSession(req.user?.id, dto);
  }

  @Patch(':id')
  @UseGuards(AuthGuard)
  async update(
    @Param('id') id: string,
    @Request() req: AuthenticatedRequest,
    @Body() dto: UpdateSessionDto,
  ) {
    return this.sessionsService.updateSession(id, req.user?.id, dto);
  }

  @Delete(':id')
  @UseGuards(AuthGuard)
  async cancel(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    return this.sessionsService.cancelSession(id, req.user?.id);
  }

  @Get()
  async getAll() {
    return this.sessionsService.getAllSessions();
  }

  @Get('upcoming')
  @UseGuards(AuthGuard)
  async getUpcoming(@Request() req: AuthenticatedRequest) {
    return this.sessionsService.getUpcomingSessions(req.user?.id);
  }

  @Get('course/:courseId')
  async getCourseSessions(@Param('courseId') courseId: string) {
    return this.sessionsService.getCourseSessions(courseId);
  }

  @Get(':id')
  async getDetail(@Param('id') id: string) {
    return this.sessionsService.getSessionDetail(id);
  }

  @Post(':id/join')
  @HttpCode(200)
  @UseGuards(AuthGuard)
  async join(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    return this.sessionsService.joinSession(id, req.user?.id);
  }

  @Post(':id/start')
  @HttpCode(200)
  @UseGuards(AuthGuard)
  async start(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    return this.sessionsService.startSession(id, req.user?.id);
  }

  @Post(':id/end')
  @HttpCode(200)
  @UseGuards(AuthGuard)
  async end(@Param('id') id: string, @Request() req: AuthenticatedRequest) {
    return this.sessionsService.endSession(id, req.user?.id);
  }
}
