-- CreateEnum
CREATE TYPE "CreditCardBrand" AS ENUM ('VISA', 'MASTERCARD', 'AMEX', 'OTHER');

-- CreateEnum
CREATE TYPE "CreditCardStatementStatus" AS ENUM ('OPEN', 'CLOSED', 'PAID');

-- CreateEnum
CREATE TYPE "CreditCardInstallmentStatus" AS ENUM ('PENDING', 'BILLED', 'PAID');

-- CreateTable
CREATE TABLE "CreditCard" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "bankAccountId" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "brand" "CreditCardBrand",
    "limitCents" INTEGER NOT NULL,
    "closingDay" INTEGER NOT NULL,
    "dueDay" INTEGER NOT NULL,
    "cardLast4" TEXT NOT NULL,
    "cardExpiresAt" TIMESTAMP(3) NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CreditCard_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CreditCardPurchase" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "creditCardId" INTEGER NOT NULL,
    "categoryId" INTEGER,
    "totalAmountCents" INTEGER NOT NULL,
    "installmentsCount" INTEGER NOT NULL,
    "occurredAt" TIMESTAMP(3) NOT NULL,
    "description" TEXT,
    "isDeleted" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CreditCardPurchase_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CreditCardInstallment" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "purchaseId" INTEGER NOT NULL,
    "statementId" INTEGER,
    "installmentNumber" INTEGER NOT NULL,
    "amountCents" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "month" INTEGER NOT NULL,
    "status" "CreditCardInstallmentStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CreditCardInstallment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CreditCardStatement" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "creditCardId" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "month" INTEGER NOT NULL,
    "periodStartDate" TIMESTAMP(3) NOT NULL,
    "closingDate" TIMESTAMP(3) NOT NULL,
    "dueDate" TIMESTAMP(3) NOT NULL,
    "totalCents" INTEGER NOT NULL DEFAULT 0,
    "status" "CreditCardStatementStatus" NOT NULL DEFAULT 'OPEN',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CreditCardStatement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CreditCardPayment" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "statementId" INTEGER NOT NULL,
    "paidFromAccountId" INTEGER NOT NULL,
    "movementId" INTEGER,
    "amountCents" INTEGER NOT NULL,
    "paidAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CreditCardPayment_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "CreditCard_userId_idx" ON "CreditCard"("userId");

-- CreateIndex
CREATE INDEX "CreditCard_bankAccountId_idx" ON "CreditCard"("bankAccountId");

-- CreateIndex
CREATE INDEX "CreditCardPurchase_userId_occurredAt_idx" ON "CreditCardPurchase"("userId", "occurredAt");

-- CreateIndex
CREATE INDEX "CreditCardPurchase_creditCardId_idx" ON "CreditCardPurchase"("creditCardId");

-- CreateIndex
CREATE INDEX "CreditCardPurchase_categoryId_idx" ON "CreditCardPurchase"("categoryId");

-- CreateIndex
CREATE INDEX "CreditCardInstallment_userId_year_month_idx" ON "CreditCardInstallment"("userId", "year", "month");

-- CreateIndex
CREATE INDEX "CreditCardInstallment_purchaseId_idx" ON "CreditCardInstallment"("purchaseId");

-- CreateIndex
CREATE INDEX "CreditCardInstallment_statementId_idx" ON "CreditCardInstallment"("statementId");

-- CreateIndex
CREATE INDEX "CreditCardStatement_userId_idx" ON "CreditCardStatement"("userId");

-- CreateIndex
CREATE INDEX "CreditCardStatement_creditCardId_status_idx" ON "CreditCardStatement"("creditCardId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "CreditCardStatement_creditCardId_year_month_key" ON "CreditCardStatement"("creditCardId", "year", "month");

-- CreateIndex
CREATE UNIQUE INDEX "CreditCardPayment_movementId_key" ON "CreditCardPayment"("movementId");

-- CreateIndex
CREATE INDEX "CreditCardPayment_userId_idx" ON "CreditCardPayment"("userId");

-- CreateIndex
CREATE INDEX "CreditCardPayment_statementId_idx" ON "CreditCardPayment"("statementId");

-- CreateIndex
CREATE INDEX "CreditCardPayment_paidFromAccountId_idx" ON "CreditCardPayment"("paidFromAccountId");

-- AddForeignKey
ALTER TABLE "CreditCard" ADD CONSTRAINT "CreditCard_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CreditCard" ADD CONSTRAINT "CreditCard_bankAccountId_fkey" FOREIGN KEY ("bankAccountId") REFERENCES "Account"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CreditCardPurchase" ADD CONSTRAINT "CreditCardPurchase_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CreditCardPurchase" ADD CONSTRAINT "CreditCardPurchase_creditCardId_fkey" FOREIGN KEY ("creditCardId") REFERENCES "CreditCard"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CreditCardPurchase" ADD CONSTRAINT "CreditCardPurchase_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CreditCardInstallment" ADD CONSTRAINT "CreditCardInstallment_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CreditCardInstallment" ADD CONSTRAINT "CreditCardInstallment_purchaseId_fkey" FOREIGN KEY ("purchaseId") REFERENCES "CreditCardPurchase"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CreditCardInstallment" ADD CONSTRAINT "CreditCardInstallment_statementId_fkey" FOREIGN KEY ("statementId") REFERENCES "CreditCardStatement"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CreditCardStatement" ADD CONSTRAINT "CreditCardStatement_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CreditCardStatement" ADD CONSTRAINT "CreditCardStatement_creditCardId_fkey" FOREIGN KEY ("creditCardId") REFERENCES "CreditCard"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CreditCardPayment" ADD CONSTRAINT "CreditCardPayment_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CreditCardPayment" ADD CONSTRAINT "CreditCardPayment_statementId_fkey" FOREIGN KEY ("statementId") REFERENCES "CreditCardStatement"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CreditCardPayment" ADD CONSTRAINT "CreditCardPayment_paidFromAccountId_fkey" FOREIGN KEY ("paidFromAccountId") REFERENCES "Account"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CreditCardPayment" ADD CONSTRAINT "CreditCardPayment_movementId_fkey" FOREIGN KEY ("movementId") REFERENCES "Movement"("id") ON DELETE SET NULL ON UPDATE CASCADE;
