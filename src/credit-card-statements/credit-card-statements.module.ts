import { Module } from '@nestjs/common';
import { CreditCardStatementsController } from './credit-card-statements.controller';
import { CreditCardStatementsService } from './credit-card-statements.service';
import { PrismaService } from '../prisma/prisma.service';

@Module({
    controllers: [CreditCardStatementsController],
    providers: [CreditCardStatementsService, PrismaService],
})
export class CreditCardStatementsModule { }
