import { IsInt, IsOptional, IsString, Min, Max, IsDateString } from 'class-validator';
import { CreditCardBrand } from '@prisma/client';

export class UpdateCreditCardDto {
    @IsOptional()
    @IsString()
    name?: string;

    @IsOptional()
    brand?: CreditCardBrand;

    @IsOptional()
    @IsInt()
    @Min(1)
    limitCents?: number;

    @IsOptional()
    @IsInt()
    @Min(1)
    @Max(28)
    closingDay?: number;

    @IsOptional()
    @IsInt()
    @Min(1)
    @Max(28)
    dueDay?: number;

    @IsOptional()
    @IsString()
    cardLast4?: string;

    @IsOptional()
    @IsDateString()
    cardExpiresAt?: string;

    @IsOptional()
    @IsInt()
    bankAccountId?: number;
}
