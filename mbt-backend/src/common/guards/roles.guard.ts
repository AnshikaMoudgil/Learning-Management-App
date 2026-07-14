import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Request } from 'express';
import { SupabaseService } from '../../modules/supabase/supabase.service';
import type { User } from '@supabase/supabase-js';
import type { UserRole } from '../types/profile.type';

export const ROLES_KEY = 'allowed_roles';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly supabaseService: SupabaseService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredRoles = this.reflector.getAllAndOverride<UserRole[]>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }

    const request = context
      .switchToHttp()
      .getRequest<Request & { user: User }>();
    const userId = request.user?.id;

    if (!userId) {
      throw new ForbiddenException('User not authenticated');
    }

    const { data: profileRow, error } = await this.supabaseService
      .getClient()
      .from('profiles')
      .select('role')
      .eq('id', userId)
      .maybeSingle();

    if (error || !profileRow) {
      throw new ForbiddenException('User profile not found');
    }

    const profile = profileRow as { role: string };
    if (!requiredRoles.includes(profile.role as UserRole)) {
      throw new ForbiddenException(
        `Requires one of roles: ${requiredRoles.join(', ')}`,
      );
    }

    return true;
  }
}
