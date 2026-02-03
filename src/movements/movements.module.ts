import { Module } from '@nestjs/common';
import { MovementsService } from './movements.service';
import { MovementsController } from './movements.controller';
import { PrismaService } from '../prisma/prisma.service';
import { ChatbotMovementsController } from './chatbot-movements.controller';
import { UsersService } from '../users/users.service';

@Module({
    controllers: [MovementsController, ChatbotMovementsController],
    providers: [PrismaService, MovementsService, UsersService],
})
export class MovementsModule { }
