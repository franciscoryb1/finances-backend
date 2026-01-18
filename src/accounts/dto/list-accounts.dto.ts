import { IsIn, IsOptional } from 'class-validator';

export class ListAccountsDto {
    @IsOptional()
    @IsIn(['all', 'active', 'inactive'])
    status?: 'all' | 'active' | 'inactive';
}
