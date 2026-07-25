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
      .select('role, allowed_sections, allowed_actions')
      .eq('id', userId)
      .maybeSingle();

    if (error || !profileRow) {
      throw new ForbiddenException('User profile not found');
    }

    const profile = profileRow as {
      role: string;
      allowed_sections?: string[];
      allowed_actions?: string[];
    };

    // If role is superadmin, grant access to everything
    if (profile.role === 'superadmin') {
      return true;
    }

    // Check if role matches required roles directly
    if (requiredRoles.includes(profile.role as UserRole)) {
      return true;
    }

    // Check dynamic section / action authorization
    const path = request.path || '';
    if (path.includes('/devices/admin')) {
      const hasSection = profile.allowed_sections?.includes('Device Requests');
      const hasAction = profile.allowed_actions?.includes(
        'Accept / Reject Device Requests',
      );
      if (hasSection || hasAction) {
        return true;
      }
    }

    throw new ForbiddenException(
      `Requires one of roles: ${requiredRoles.join(', ')} or specific permissions`,
    );
  }
}
