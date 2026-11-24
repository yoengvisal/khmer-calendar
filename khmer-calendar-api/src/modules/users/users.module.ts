import { Module } from '@nestjs/common';
import { AdminUsersController } from './admin-users.controller.js';
import { PasswordHasher } from './password-hasher.js';
import { RefreshTokensRepository } from './refresh-tokens.repository.js';
import { UsersRepository } from './users.repository.js';
import { UsersService } from './users.service.js';

/** Owns user accounts, credentials and their persisted sessions (refresh tokens). */
@Module({
  controllers: [AdminUsersController],
  providers: [
    UsersRepository,
    UsersService,
    PasswordHasher,
    RefreshTokensRepository,
  ],
  exports: [UsersRepository, PasswordHasher, RefreshTokensRepository],
})
export class UsersModule {}
