import { Injectable, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { createHash, randomBytes, randomUUID } from 'node:crypto';
import type { User } from '../../generated/prisma/client.js';
import { AppConfig } from '../../config/app-config.service.js';
import { AppException } from '../../common/errors/app.exception.js';
import { ErrorCode } from '../../common/errors/error-codes.js';
import { UserDto } from '../users/dto/user.dto.js';
import { PasswordHasher } from '../users/password-hasher.js';
import { RefreshTokensRepository } from '../users/refresh-tokens.repository.js';
import { UsersRepository } from '../users/users.repository.js';
import type { AuthTokensDto } from './dto/auth.dto.js';

const hashToken = (token: string) =>
  createHash('sha256').update(token).digest('hex');

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly users: UsersRepository,
    private readonly refreshTokens: RefreshTokensRepository,
    private readonly hasher: PasswordHasher,
    private readonly jwt: JwtService,
    private readonly config: AppConfig,
  ) {}

  async login(email: string, password: string): Promise<AuthTokensDto> {
    const user = await this.users.findByEmail(email.trim());
    const ok = await this.hasher.verify(password, user?.passwordHash);
    if (!user || !ok || !user.isActive) {
      throw AppException.unauthorized(
        ErrorCode.INVALID_CREDENTIALS,
        'Invalid email or password',
      );
    }
    const updated = await this.users.update(user.id, {
      lastLoginAt: new Date(),
    });
    return this.issueTokens(updated, randomUUID());
  }

  /**
   * Rotating refresh: each token is single-use. Presenting an already-revoked token is
   * treated as theft and revokes the whole token family (all sessions from that login).
   */
  async refresh(refreshToken: string): Promise<AuthTokensDto> {
    const invalid = () =>
      AppException.unauthorized(
        ErrorCode.INVALID_REFRESH_TOKEN,
        'Session expired, please sign in again',
      );
    const stored = await this.refreshTokens.findByHash(hashToken(refreshToken));
    if (!stored) throw invalid();

    if (stored.revokedAt) {
      this.logger.warn({
        msg: 'refresh token reuse detected; revoking family',
        userId: stored.userId,
      });
      await this.refreshTokens.revokeFamily(stored.familyId);
      throw invalid();
    }
    if (stored.expiresAt.getTime() <= Date.now()) throw invalid();

    // Atomic single-use: if two requests race with the same token only one wins.
    if (!(await this.refreshTokens.revokeIfActive(stored.id))) throw invalid();

    const user = await this.users.findById(stored.userId);
    if (!user || !user.isActive) {
      await this.refreshTokens.revokeFamily(stored.familyId);
      throw invalid();
    }
    return this.issueTokens(user, stored.familyId);
  }

  async logout(refreshToken: string): Promise<{ loggedOut: true }> {
    const stored = await this.refreshTokens.findByHash(hashToken(refreshToken));
    if (stored) await this.refreshTokens.revokeFamily(stored.familyId);
    return { loggedOut: true };
  }

  async me(userId: string): Promise<UserDto> {
    const user = await this.users.findById(userId);
    if (!user || !user.isActive) throw AppException.unauthorized();
    return UserDto.from(user);
  }

  private async issueTokens(
    user: User,
    familyId: string,
  ): Promise<AuthTokensDto> {
    const expiresIn = this.config.jwtAccessTtlSeconds;
    const accessToken = await this.jwt.signAsync(
      { sub: user.id, email: user.email, role: user.role },
      { expiresIn },
    );
    const refreshToken = randomBytes(48).toString('base64url');
    await this.refreshTokens.create({
      userId: user.id,
      familyId,
      tokenHash: hashToken(refreshToken),
      expiresAt: new Date(
        Date.now() + this.config.refreshTokenTtlDays * 86_400_000,
      ),
    });
    return { accessToken, refreshToken, expiresIn, user: UserDto.from(user) };
  }
}
