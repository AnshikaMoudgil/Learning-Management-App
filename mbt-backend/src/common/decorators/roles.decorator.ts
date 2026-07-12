import { SetMetadata } from '@nestjs/common';
import type { UserRole } from '../types/profile.type';
import { ROLES_KEY } from '../guards/roles.guard';

export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles);
