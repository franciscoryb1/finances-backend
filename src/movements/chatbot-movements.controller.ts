import {
    Controller,
    Get,
    Query,
    UseGuards,
    Req,
    BadRequestException,
    ForbiddenException,
} from '@nestjs/common';
import { ChatbotApiKeyGuard } from '../auth/chatbot-api-key.guard';
import { MovementsService } from './movements.service';
import { ListMovementsDto } from './dto/list-movements.dto';
import { UsersService } from '../users/users.service';

@Controller('chatbot/movements')
@UseGuards(ChatbotApiKeyGuard)
export class ChatbotMovementsController {
    constructor(
        private readonly movementsService: MovementsService,
        private readonly usersService: UsersService,
    ) { }

    @Get()
    async list(@Req() req: any, @Query() query: ListMovementsDto) {
        const phoneNumber = req.headers['x-user-phone'];

        if (!phoneNumber) {
            throw new BadRequestException('Missing X-User-Phone header');
        }

        const user = await this.usersService.findByPhone(phoneNumber);

        if (!user) {
            throw new BadRequestException('User not found for phone number');
        }

        if (!user.isActive) {
            throw new ForbiddenException('User is inactive');
        }

        return this.movementsService.listMovements(user.id, query);
    }
}
