import {
    BadRequestException,
    ForbiddenException,
    Injectable,
    NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateStatementDto } from './dto/create-statement.dto';
import { CreditCardInstallmentStatus, CreditCardStatementStatus } from '@prisma/client';

@Injectable()
export class CreditCardStatementsService {
    constructor(private readonly prisma: PrismaService) { }

    // -----------------------
    // Crear o asegurar statement OPEN
    // -----------------------
    async create(userId: number, dto: CreateStatementDto) {
        const {
            creditCardId,
            year,
            month,
            periodStartDate,
            closingDate,
            dueDate,
        } = dto;

        const card = await this.prisma.creditCard.findFirst({
            where: { id: creditCardId, userId, isActive: true },
        });

        if (!card) {
            throw new ForbiddenException('Invalid credit card');
        }

        const existing = await this.prisma.creditCardStatement.findUnique({
            where: {
                creditCardId_year_month: {
                    creditCardId,
                    year,
                    month,
                },
            },
        });

        if (existing) {
            return existing; // idempotente
        }

        // busco el último statement de la tarjeta
        const lastStatement = await this.prisma.creditCardStatement.findFirst({
            where: {
                creditCardId,
            },
            orderBy: {
                sequenceNumber: 'desc',
            },
        });

        const nextSequenceNumber = lastStatement ? lastStatement.sequenceNumber + 1 : 1;

        return this.prisma.creditCardStatement.create({
            data: {
                userId,
                creditCardId,
                sequenceNumber: nextSequenceNumber,
                year,
                month,
                periodStartDate: new Date(periodStartDate),
                closingDate: new Date(closingDate),
                dueDate: new Date(dueDate),
                status: CreditCardStatementStatus.OPEN,
            },
        });
    }

    // -----------------------
    // Cerrar statement
    // -----------------------
    async close(userId: number, statementId: number) {
        return this.prisma.$transaction(async (tx) => {

            // 1️⃣ Traer statement
            const statement = await tx.creditCardStatement.findUnique({
                where: { id: statementId },
            });

            if (!statement) {
                throw new NotFoundException('Statement not found');
            }

            if (statement.userId !== userId) {
                throw new ForbiddenException();
            }

            if (statement.status !== CreditCardStatementStatus.OPEN) {
                throw new BadRequestException('Statement is not open');
            }

            // traigo cuotas pendientes
            const purchases = await tx.creditCardPurchase.findMany({
                where: {
                    creditCardId: statement.creditCardId,
                    isDeleted: false,

                    OR: [
                        // 🔹 compras en cuotas con algo pendiente
                        {
                            installments: {
                                some: {
                                    status: CreditCardInstallmentStatus.PENDING,
                                },
                            },
                        },

                        // 🔹 compras en 1 pago que corresponden a este statement
                        {
                            installmentsCount: 1,
                            firstStatementSequence: statement.sequenceNumber,
                        },
                    ],
                },
                select: {
                    id: true,
                    installmentsCount: true,
                    firstStatementSequence: true,
                    totalAmountCents: true,

                    installments: {
                        where: {
                            status: CreditCardInstallmentStatus.PENDING,
                        },
                        select: {
                            id: true,
                            amountCents: true,
                            billingCycleOffset: true,
                        },
                    },
                },
            });

            const installmentsToBill = purchases.flatMap((purchase) =>
                purchase.installments.filter(
                    (installment) =>
                        purchase.installmentsCount > 1 &&
                        purchase.firstStatementSequence + installment.billingCycleOffset === statement.sequenceNumber,
                ),
            );

            const installmentsTotal = installmentsToBill.reduce(
                (sum, i) => sum + i.amountCents,
                0,
            );


            // marco las cuotas como BIILED
            if (installmentsToBill.length > 0) {
                await tx.creditCardInstallment.updateMany({
                    where: {
                        id: { in: installmentsToBill.map((i) => i.id) },
                    },
                    data: {
                        status: CreditCardInstallmentStatus.BILLED,
                        statementId: statement.id,
                        year: statement.year,
                        month: statement.month,
                    },
                });
            }

            // traigo las compras en un unico pago dentro del período del statement
            const singlePaymentPurchases = purchases.filter(
                (purchase) =>
                    purchase.installmentsCount === 1 &&
                    purchase.firstStatementSequence === statement.sequenceNumber,
            );

            // total de compras en un unico pago
            const singlePaymentsTotal = singlePaymentPurchases.reduce(
                (sum, p) => sum + p.totalAmountCents,
                0,
            );

            // monto total del statement
            const totalCents = installmentsTotal + singlePaymentsTotal;

            // 6️⃣ Cerrar statement
            return tx.creditCardStatement.update({
                where: { id: statement.id },
                data: {
                    status: CreditCardStatementStatus.CLOSED,
                    totalCents,
                },
            });
        });
    }
}
