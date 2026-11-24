import { Injectable } from '@nestjs/common';
import bcrypt from 'bcryptjs';

const COST = 12;
// Pre-computed hash used to keep login timing constant when the email is unknown.
const DUMMY_HASH = bcrypt.hashSync(
  'timing-equaliser-not-a-real-password',
  COST,
);

@Injectable()
export class PasswordHasher {
  hash(plain: string): Promise<string> {
    return bcrypt.hash(plain, COST);
  }

  verify(plain: string, hash: string | null | undefined): Promise<boolean> {
    return bcrypt.compare(plain, hash ?? DUMMY_HASH).then((ok) => ok && !!hash);
  }
}
