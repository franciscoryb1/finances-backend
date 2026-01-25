import { IsInt } from 'class-validator';

export class CloseStatementDto {
    @IsInt()
    statementId: number;
}
