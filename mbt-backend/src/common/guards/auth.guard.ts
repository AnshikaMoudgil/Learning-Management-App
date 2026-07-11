import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { SupabaseService } from '../../modules/supabase/supabase.service';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private supabaseService: SupabaseService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers['authorization'];

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing or invalid Authorization header');
    }

    const token = authHeader.split(' ')[1];

    try {
      const { data: { user }, error } = await this.supabaseService.getClient().auth.getUser(token);

      if (error || !user) {
        throw new UnauthorizedException(error?.message || 'Invalid token');
      }

      // Attach the user to the request context
      request.user = user;
      return true;
    } catch (err) {
      throw new UnauthorizedException(err.message || 'Token verification failed');
    }
  }
}
