# 📘 Módulo Tarjetas de Crédito y Cuotas (v1)

Este documento resume **todas las decisiones de dominio** tomadas para implementar el módulo de **tarjetas de crédito, consumos, cuotas, resúmenes y pagos** dentro del backend de finanzas personales.

El objetivo es modelar el comportamiento **real** de una tarjeta de crédito, de forma consistente, extensible y sin ambigüedades.

---

## 🎯 Principios generales

* Una **tarjeta de crédito NO es una cuenta bancaria**
* Un **consumo con tarjeta NO es un Movement**
* Las **cuotas representan gastos futuros comprometidos**
* El **statement (resumen)** es la unidad central de facturación
* El **impacto real en dinero** ocurre únicamente al **pagar el resumen**
* Toda operación crítica debe ser **transaccional**

---

## 🏦 1. Tarjeta de crédito (`CreditCard`)

La tarjeta es un modelo **separado** de `Account`.

### Características principales

* Pertenece a un usuario
* Está asociada a un banco mediante un `Account` de tipo `BANK`
* Tiene límite, fechas de cierre y vencimiento
* Tiene vencimiento del plástico independiente de los resúmenes

### Datos relevantes

* `userId`
* `bankAccountId` (Account tipo `BANK`)
* `name`
* `brand` (opcional)
* `limitCents`
* `closingDay` (1–28)
* `dueDay` (1–28)
* `cardExpiresAt` (DateTime)
* `cardLast4`
* `isActive`

---

## 📅 2. Statements (resúmenes de tarjeta)

Un **statement** representa un período de facturación de una tarjeta.

### Campos clave

* `periodStartDate`
* `closingDate`
* `dueDate`
* `year`
* `month`
* `totalCents`
* `status` (`OPEN` | `CLOSED` | `PAID`)

---

## 🔒 Definición exacta del período (D1 — DEFINITIVO)

Dado un statement actual y uno anterior:

```text
periodStartDate = previousStatement.closingDate
periodEndDate   = closingDate
```

### Primer statement

Si no existe un statement anterior:

* `periodStartDate` se define explícitamente

Esto permite inicializar correctamente una tarjeta nueva.

---

## 🧾 3. Consumos con tarjeta (`CreditCardPurchase`)

Un consumo representa una compra real hecha con la tarjeta.

### Reglas

* NO impacta saldo
* NO es un `Movement`
* Siempre es un gasto (`EXPENSE`)
* Puede ser:

  * en 1 pago
  * en cuotas

### Datos relevantes

* `creditCardId`
* `categoryId` (EXPENSE)
* `totalAmountCents`
* `installmentsCount` (>= 1)
* `occurredAt`
* `description`
* `isDeleted`
* `createdAt`
* `updatedAt`

---

## 🔢 4. Cuotas (`CreditCardInstallment`)

Se usan cuotas explícitas (no cálculo dinámico).

### Cuándo se crean

* Solo si `installmentsCount > 1`
* Si es 1 pago → **NO** se generan cuotas

### Datos de cada cuota

* `purchaseId`
* `installmentNumber` (1..N)
* `amountCents`
* `year`
* `month`
* `status` (`PENDING` | `BILLED` | `PAID`)
* `statementId` (nullable)

---

## 📌 Regla definitiva de cuotas (D2)

* La cuota **1** entra en el statement vigente al momento de la compra
* Las cuotas siguientes entran en los statements de los meses siguientes

### Regla de corte

```text
Si occurredAt < closingDate  → statement actual
Si occurredAt >= closingDate → statement siguiente
```

Esto replica el comportamiento real de tarjetas en Argentina.

---

## 📑 5. Relación compras ↔ statements

### Compras en 1 pago

* Se asignan directamente al statement correspondiente
* No generan installments

### Compras en cuotas

* Generan installments
* Cada installment se asigna a un statement por período

### Al cerrar el statement

* Las installments correspondientes se marcan como `BILLED`
* Se calcula el `totalCents` del statement

---

## 💳 6. Pago de tarjeta

Pagar un statement implica:

1. Crear **1 Movement** de tipo `EXPENSE`
2. Desde una cuenta bancaria (`Account`)
3. Por el total del statement

Luego marcar:

* Statement como `PAID`
* Installments asociadas como `PAID`

Todo debe ejecutarse en una **transacción**.

> (Opcional) Se puede registrar una entidad `CreditCardPayment` para trazabilidad.

---

## ✏️ 7. Edición y borrado de consumos

Un consumo puede:

* editarse
* borrarse (soft delete)

### Condición

Solo si:

* NO está facturado
* Ninguna installment está `BILLED` o `PAID`

### Categoría

* Puede cambiarse hasta que el consumo sea facturado

---

## 🔁 8. Integración con el sistema existente

* `Movement` sigue siendo la única entidad que impacta saldo
* Tarjetas y consumos **no tocan balances**
* La integración ocurre únicamente al **pagar el statement**

---

Si querés, en el próximo paso puedo:

* Pasarlo a **diagrama de entidades**
* Definir **modelo Prisma**
* O escribir los **casos de uso formales (CreatePurchase, CloseStatement, PayStatement, etc.)**

Este diseño está muy sólido, David. Con esto podés implementar sin sorpresas más adelante. 💪
