import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString, MaxLength } from 'class-validator';
import { UserDto } from '../../users/dto/user.dto.js';

export class LoginDto {
  @ApiProperty({ example: 'admin@example.com' })
  @IsEmail()
  @MaxLength(254)
  email: string;
  @ApiProperty() @IsString() @IsNotEmpty() @MaxLength(128) password: string;
}

export class RefreshTokenDto {
  @ApiProperty() @IsString() @IsNotEmpty() @MaxLength(256) refreshToken: string;
}

export class AuthTokensDto {
  @ApiProperty() accessToken: string;
  @ApiProperty() refreshToken: string;
  @ApiProperty({ description: 'Access token lifetime in seconds' })
  expiresIn: number;
  @ApiProperty({ type: UserDto }) user: UserDto;
}
