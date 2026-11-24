import { Injectable } from '@nestjs/common';
import { AppException } from '../../common/errors/app.exception.js';
import { Paginated } from '../../common/http/paginated.js';
import { RefreshTokensRepository } from './refresh-tokens.repository.js';
import {
  type CreateUserDto,
  type UpdateUserDto,
  UserDto,
} from './dto/user.dto.js';
import { PasswordHasher } from './password-hasher.js';
import { UsersRepository } from './users.repository.js';

@Injectable()
export class UsersService {
  constructor(
    private readonly users: UsersRepository,
    private readonly hasher: PasswordHasher,
    private readonly refreshTokens: RefreshTokensRepository,
  ) {}

  async list(page: number, limit: number): Promise<Paginated<UserDto>> {
    const [rows, total] = await this.users.findPage(page, limit);
    return new Paginated(rows.map(UserDto.from), page, limit, total);
  }

  async get(id: string): Promise<UserDto> {
    const user = await this.users.findById(id);
    if (!user) throw AppException.notFound('User');
    return UserDto.from(user);
  }

  async create(dto: CreateUserDto): Promise<UserDto> {
    const email = dto.email.trim().toLowerCase();
    if (await this.users.findByEmail(email))
      throw AppException.conflict('A user with this email already exists');
    const user = await this.users.create({
      email,
      displayName: dto.displayName.trim(),
      role: dto.role,
      passwordHash: await this.hasher.hash(dto.password),
    });
    return UserDto.from(user);
  }

  async update(
    id: string,
    dto: UpdateUserDto,
    actorId: string,
  ): Promise<UserDto> {
    const existing = await this.users.findById(id);
    if (!existing) throw AppException.notFound('User');
    if (
      id === actorId &&
      (dto.isActive === false || (dto.role && dto.role !== existing.role))
    ) {
      throw AppException.validation([
        {
          field: 'role',
          messages: [
            'You cannot deactivate or change the role of your own account',
          ],
        },
      ]);
    }
    const user = await this.users.update(id, {
      ...(dto.displayName !== undefined
        ? { displayName: dto.displayName.trim() }
        : {}),
      ...(dto.role !== undefined ? { role: dto.role } : {}),
      ...(dto.isActive !== undefined ? { isActive: dto.isActive } : {}),
      ...(dto.password !== undefined
        ? { passwordHash: await this.hasher.hash(dto.password) }
        : {}),
    });
    // Deactivation, role change or password reset ends existing sessions.
    if (
      dto.isActive === false ||
      dto.password !== undefined ||
      (dto.role && dto.role !== existing.role)
    ) {
      await this.refreshTokens.revokeAllForUser(id);
    }
    return UserDto.from(user);
  }
}
