/*
  Warnings:

  - Added the required column `sequenceNumber` to the `CreditCardStatement` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "CreditCardStatement" ADD COLUMN     "sequenceNumber" INTEGER NOT NULL;
