import { BadGatewayException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface RazorpayGateway {
  keyId: string;
  keySecret: string;
  name: 'hardware' | 'software';
}

export interface RazorpayOrder {
  id: string;
  amount: number;
  currency: string;
  status: string;
}

export interface RazorpayPayment {
  id: string;
  order_id: string;
  amount: number;
  currency: string;
  status: string;
  captured: boolean;
}

@Injectable()
export class RazorpayService {
  private readonly baseUrl = 'https://api.razorpay.com/v1';

  constructor(private readonly configService: ConfigService) {}

  getGatewayForCategory(category?: string | null): RazorpayGateway {
    const normalized = category?.toLowerCase() ?? '';
    const gatewayName: 'hardware' | 'software' = normalized.includes('hardware')
      ? 'hardware'
      : 'software';
    const keyId = this.configService.get<string>(
      `razorpay.${gatewayName}.keyId`,
    );
    const keySecret = this.configService.get<string>(
      `razorpay.${gatewayName}.keySecret`,
    );

    if (!keyId || !keySecret) {
      throw new BadGatewayException(
        `Razorpay ${gatewayName} gateway is not configured`,
      );
    }

    return { keyId, keySecret, name: gatewayName };
  }

  async createOrder(input: {
    gateway: RazorpayGateway;
    amountSubunits: number;
    currency: string;
    receipt: string;
    notes: Record<string, string>;
  }): Promise<RazorpayOrder> {
    const response = await fetch(`${this.baseUrl}/orders`, {
      method: 'POST',
      headers: {
        Authorization: this.basicAuth(input.gateway),
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        amount: input.amountSubunits,
        currency: input.currency,
        receipt: input.receipt,
        notes: input.notes,
      }),
    });

    return this.parseResponse<RazorpayOrder>(response, 'create Razorpay order');
  }

  async fetchPayment(
    gateway: RazorpayGateway,
    paymentId: string,
  ): Promise<RazorpayPayment> {
    const response = await fetch(`${this.baseUrl}/payments/${paymentId}`, {
      headers: {
        Authorization: this.basicAuth(gateway),
      },
    });

    return this.parseResponse<RazorpayPayment>(
      response,
      'fetch Razorpay payment',
    );
  }

  private basicAuth(gateway: RazorpayGateway): string {
    return `Basic ${Buffer.from(`${gateway.keyId}:${gateway.keySecret}`).toString('base64')}`;
  }

  private async parseResponse<T>(
    response: Response,
    action: string,
  ): Promise<T> {
    const text = await response.text();
    const payload = text ? (JSON.parse(text) as Record<string, unknown>) : {};

    if (!response.ok) {
      const description =
        typeof payload.error === 'object' && payload.error !== null
          ? (payload.error as Record<string, unknown>).description
          : undefined;
      throw new BadGatewayException(
        `Failed to ${action}: ${String(description ?? response.statusText)}`,
      );
    }

    return payload as T;
  }
}
