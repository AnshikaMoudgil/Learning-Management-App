import { Request } from 'express';

export interface AuthenticatedRequest extends Request {
  user: {
    id: string;
    email?: string;
    phone?: string;
    user_metadata?: Record<string, unknown>;
  };
}
