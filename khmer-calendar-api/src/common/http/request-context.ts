import type { Request } from 'express';
import type { UserRole } from '../../generated/prisma/enums.js';

export interface AuthenticatedUser {
  id: string;
  email: string;
  role: UserRole;
}

export interface AppRequest extends Request {
  requestId: string;
  user?: AuthenticatedUser;
}
