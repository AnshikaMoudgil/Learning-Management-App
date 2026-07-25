import { Injectable, BadRequestException } from '@nestjs/common';
import { SearchRepository } from './search.repository';

@Injectable()
export class SearchService {
  constructor(private readonly searchRepository: SearchRepository) {}

  async globalSearch(query: string) {
    const searchTerm = `${query.trim()}%`;

    try {
      return await this.searchRepository.globalSearch(searchTerm);
    } catch {
      throw new BadRequestException('Search failed');
    }
  }
}
