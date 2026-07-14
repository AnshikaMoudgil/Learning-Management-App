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
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 10_000);

    try {
      const response = await fetch(`${this.baseUrl}/orders`, {
        signal: controller.signal,
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
    } finally {
      clearTimeout(timeout);
    }
  }

  async fetchPayment(
    gateway: RazorpayGateway,
    paymentId: string,
  ): Promise<RazorpayPayment> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 10_000);

    try {
      const response = await fetch(`${this.baseUrl}/payments/${paymentId}`, {
        signal: controller.signal,
        headers: {
          Authorization: this.basicAuth(gateway),
        },
      });

      return this.parseResponse<RazorpayPayment>(
        response,
        'fetch Razorpay payment',
      );
    } finally {
      clearTimeout(timeout);
    }
  }

  async fetchOrder(
    gateway: RazorpayGateway,
    orderId: string,
  ): Promise<RazorpayOrder> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 10_000);

    try {
      const response = await fetch(`${this.baseUrl}/orders/${orderId}`, {
        signal: controller.signal,
        headers: {
          Authorization: this.basicAuth(gateway),
        },
      });

      return this.parseResponse<RazorpayOrder>(
        response,
        'fetch Razorpay order',
      );
    } finally {
      clearTimeout(timeout);
    }
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
      const rawDescription =
        typeof payload.error === 'object' && payload.error !== null
          ? (payload.error as Record<string, unknown>).description
          : undefined;
      const description = typeof rawDescription === 'string' ? rawDescription : response.statusText;
      throw new BadGatewayException(
        `Failed to ${action}: ${description}`,
      );
    }

    return payload as T;
  }
}
