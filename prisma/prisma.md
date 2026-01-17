# Prisma – ORM y manejo de base de datos

Este proyecto utiliza **Prisma** como ORM para manejar:
- el modelo de datos
- la creación y evolución de la base de datos
- las migraciones versionadas

Prisma es la **única fuente de verdad** del esquema de la base de datos.

---

## 🧠 Conceptos clave (muy importante)

### 1️⃣ Prisma Schema
El archivo:

```

prisma/schema.prisma

```

define:
- las entidades (models)
- los campos
- las relaciones
- los enums
- los índices
- las restricciones

👉 **Nunca se crean tablas a mano en PostgreSQL**.  
Todo cambio se hace acá.

---

### 2️⃣ Migraciones
Las migraciones son **versiones del esquema**.

Cada vez que cambiás el schema:
1. Prisma genera una migración SQL
2. La aplica a la DB
3. Guarda el historial

Las migraciones viven en:

```

prisma/migrations/

```

Cada carpeta representa un cambio histórico.

---

### 3️⃣ Relación Prisma ↔ PostgreSQL

El flujo correcto siempre es:

```

schema.prisma
↓
migración
↓
PostgreSQL

````

❌ Nunca al revés.

---

## ⚙️ Configuración (Prisma 7)

### Archivos importantes

#### `schema.prisma`
Define **qué es la base de datos**.

#### `prisma.config.ts`
Define **cómo Prisma se conecta** a la base de datos.

Ejemplo:
```ts
import "dotenv/config";
import { defineConfig } from "prisma/config";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  datasource: {
    url: process.env.DATABASE_URL,
  },
});
````

#### `.env`

Contiene la URL de conexión:

```env
DATABASE_URL="postgresql://user:pass@localhost:5432/finances?schema=public"
```

📌 `.env` **nunca se commitea**.

---

## 📦 Modelos (Models)

Un `model` representa una **tabla**.

Ejemplo conceptual:

```prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  createdAt DateTime @default(now())
}
```

### Reglas que seguimos en este proyecto

* IDs `Int` autoincrementales
* `createdAt` y `updatedAt` en todas las entidades
* Relaciones explícitas
* Nada implícito
* Nada “mágico”

---

## 🔗 Relaciones

Las relaciones se definen con:

* campos FK (`userId`)
* `@relation`

Ejemplo:

```prisma
user User @relation(fields: [userId], references: [id])
```

Esto crea:

* foreign key real en PostgreSQL
* integridad referencial
* joins seguros

---

## 🧩 Enums

Los enums definen **valores permitidos**.

Ejemplo:

```prisma
enum MovementType {
  INCOME
  EXPENSE
}
```

Ventajas:

* Evita strings libres
* Seguridad en runtime
* Tipado fuerte en TypeScript

---

## 🚀 Comandos útiles de Prisma

### Validar el schema

```bash
npx prisma validate
```

Chequea:

* sintaxis
* relaciones
* enums
* config

---

### Crear y aplicar migración

```bash
npx prisma migrate dev --name nombre_descriptivo
```

Ejemplo:

```bash
npx prisma migrate dev --name add_categories
```

---

### Ver estado de migraciones

```bash
npx prisma migrate status
```

---

### Abrir Prisma Studio (UI visual)

```bash
npx prisma studio
```

Permite:

* ver datos
* editar registros
* explorar relaciones

📌 Solo para **desarrollo**.

---

### Regenerar el cliente Prisma

```bash
npx prisma generate
```

(normalmente se ejecuta solo)

---

## ⚠️ Buenas prácticas (clave)

### ❌ NO hacer

* Crear tablas desde pgAdmin
* Modificar columnas manualmente
* Borrar migraciones aplicadas
* Editar migraciones viejas ya aplicadas

---

### ✅ SÍ hacer

* Cambiar `schema.prisma`
* Crear nueva migración
* Versionar todo
* Mantener historial limpio

---

## 🧪 Ambientes

### Desarrollo

* `migrate dev`
* Migraciones automáticas
* Prisma Studio permitido

### Producción (futuro)

* `migrate deploy`
* Nunca `dev`
* Sin Studio

---

## 🧠 Regla de oro

> **Si la DB y el schema no coinciden, el schema tiene razón.**

La DB se adapta al código, no al revés.

---

## 📌 Estado actual del proyecto

* Prisma configurado ✅
* Migración inicial aplicada ✅
* Entidades creadas ✅
* Base sincronizada ✅

A partir de acá, todo el backend se construye **sobre esta base**.

---