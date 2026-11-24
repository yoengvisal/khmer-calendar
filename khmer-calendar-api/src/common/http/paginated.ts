/** Return this from a controller to get `{ success, data, meta }` paging envelope. */
export class Paginated<T> {
  constructor(
    readonly items: T[],
    readonly page: number,
    readonly limit: number,
    readonly total: number,
  ) {}

  get meta() {
    return {
      page: this.page,
      limit: this.limit,
      total: this.total,
      totalPages: Math.max(1, Math.ceil(this.total / this.limit)),
    };
  }
}
