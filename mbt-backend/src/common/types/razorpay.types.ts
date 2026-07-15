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
