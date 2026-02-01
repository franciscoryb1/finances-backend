import { IsString, Matches } from 'class-validator';

export class ResolveChatbotUserDto {
    @IsString()
    @Matches(/^\+\d{10,15}$/)
    phoneNumber: string;
}
