import {
    Body,
    Controller,
    Get,
    Patch,
    Param,
    Post,
    Query,
    Req,
    UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AccountsService } from './accounts.service';
import { CreateAccountDto } from './dto/create-account.dto';
import { ListAccountsDto } from './dto/list-accounts.dto';

@Controller('accounts')
@UseGuards(JwtAuthGuard)
export class AccountsController {
    constructor(private accountsService: AccountsService) { }

    @Post()
    createAccount(@Req() req: any, @Body() dto: CreateAccountDto) {
        const userId = req.user.userId;
        return this.accountsService.createAccount(userId, dto);
    }

    @Get()
    listAccounts(@Req() req: any, @Query() query: ListAccountsDto) {
        const userId = req.user.userId;
        return this.accountsService.listAccounts(userId, query);
    }

    @Patch(':id/deactivate')
    deactivateAccount(@Req() req: any, @Param('id') id: string) {
        const userId = req.user.userId;
        return this.accountsService.deactivateAccount(userId, Number(id));
    }

    @Patch(':id/activate')
    activateAccount(@Req() req: any, @Param('id') id: string) {
        const userId = req.user.userId;
        return this.accountsService.activateAccount(userId, Number(id));
    }
}