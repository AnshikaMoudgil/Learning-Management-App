import {
  Controller,
  Get,
  Param,
  Req,
  UseGuards,
  NotFoundException,
  ParseUUIDPipe,
} from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { ThrottleGuard } from '../../common/guards/throttle.guard';
import { Throttle } from '../../common/decorators/throttle.decorator';
import { InvoicesService } from './invoices.service';
import type { AuthenticatedRequest } from '../../common/types/authenticated-request.type';

@Controller('api/v1/invoices')
export class InvoicesController {
  constructor(private readonly invoicesService: InvoicesService) {}

  @Get()
  @UseGuards(AuthGuard)
  async findAll(@Req() req: AuthenticatedRequest) {
    return this.invoicesService.findByUser(req.user.id);
  }

  @Get(':id')
  @UseGuards(AuthGuard)
  async findOne(
    @Req() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.invoicesService.findOneForUser(id, req.user.id);
  }

  @Get(':id/pdf')
  @UseGuards(AuthGuard, ThrottleGuard)
  @Throttle({ limit: 10, windowMs: 60000 })
  async downloadPdf(
    @Req() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    const invoice = await this.invoicesService.findOneForUser(id, req.user.id);
    if (!invoice.pdf_url) {
      throw new NotFoundException('PDF not yet available for this invoice');
    }
    return { url: invoice.pdf_url };
  }
}
