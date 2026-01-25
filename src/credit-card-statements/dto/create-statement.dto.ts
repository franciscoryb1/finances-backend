import { IsDateString, IsInt } from 'class-validator';

export class CreateStatementDto {
    @IsInt()
    creditCardId: number;

    @IsInt()
    year: number;

    @IsInt()
    month: number;

    @IsDateString()
    periodStartDate: string;

    @IsDateString()
    closingDate: string;

    @IsDateString()
    dueDate: string;
}
