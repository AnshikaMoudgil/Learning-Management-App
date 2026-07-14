import {
  Controller,
  Get,
  Param,
  Req,
  UseGuards,
  Res,
  NotFoundException,
  ParseUUIDPipe,
} from '@nestjs/common';
import type { Response } from 'express';
import { AuthGuard } from '../../common/guards/auth.guard';
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
  @UseGuards(AuthGuard)
  async downloadPdf(
    @Req() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) id: string,
    @Res() res: Response,
  ) {
    const invoice = await this.invoicesService.findOneForUser(id, req.user.id);
    const pdfUrl = invoice.pdf_url;
    if (!pdfUrl) {
      throw new NotFoundException('PDF not yet available for this invoice');
    }
    return res.redirect(pdfUrl);
  }
}
