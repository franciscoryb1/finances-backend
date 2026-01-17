Dale, David. Roadmap **sin código**, bien paso a paso, para que lo vayamos ejecutando en orden y sin mezclar etapas.

## Roadmap general del proyecto (backend first)

### Fase 0 — Definición del alcance (1 sesión)

**Objetivo:** que el MVP esté clarísimo y no se agrande antes de tiempo.
**Entregables:**

* Qué entra en MVP y qué queda “Futuro”
* Principios del sistema (multiusuario desde el inicio, moneda, etc.)
* Reglas básicas (cómo se registra un gasto, qué es una cuenta, etc.)
  **Criterio de listo:** podemos describir 5 casos de uso básicos en una frase cada uno.

---

## Fase 1 — Base de datos (diseño primero, implementación después)

### Paso 1 — Definir entidades iniciales (MVP)

**Objetivo:** acordar el “core” del modelo.
**Entregables:**

* Lista de entidades mínimas (ej: User, Account, Category, Movement)
* Campos mínimos por entidad
* Relaciones y cardinalidades (1:N, N:N, opcionales)
* Decisiones clave:

  * cómo representar montos (centavos vs decimal)
  * categorías por usuario o globales
  * soporte multi-moneda ahora vs después
    **Criterio de listo:** podemos dibujar (aunque sea textual) el diagrama y justificar decisiones.

### Paso 2 — Definir convenciones del modelo

**Objetivo:** evitar caos cuando crezca.
**Entregables:**

* Naming conventions (singular/plural, snake/camel, etc.)
* “Soft delete” sí/no
* Auditoría mínima (createdAt/updatedAt)
* Estrategia de IDs (uuid vs int)
* Índices esperados (para reportes mensuales)
  **Criterio de listo:** hay reglas escritas y las respetamos en cada nueva tabla.

---

## Fase 2 — Infra local: Docker + Postgres

### Paso 3 — Definir estrategia de entorno local

**Objetivo:** que levantar el proyecto sea trivial.
**Entregables:**

* Decisión: Postgres en Docker
* Qué herramientas se usan para inspección (pgAdmin / DBeaver / psql)
* Convención de variables de entorno (sin valores todavía)
  **Criterio de listo:** cualquiera puede entender “cómo se corre local” en 5 líneas.

### Paso 4 — Levantar Postgres local

**Objetivo:** tener DB operativa para que el backend ya apunte ahí.
**Entregables:**

* Contenedor funcionando
* Persistencia (volumen)
* Acceso confirmado (conexión ok)
  **Criterio de listo:** DB viva y accesible desde tu máquina.

---

## Fase 3 — Backend base (esqueleto limpio)

### Paso 5 — Crear proyecto backend y estructura base

**Objetivo:** arrancar ordenado desde el minuto 1.
**Entregables:**

* Proyecto Nest inicial
* Estructura de módulos base
* Configuración de envs por ambientes (local/dev)
  **Criterio de listo:** corre local, tiene healthcheck y estructura modular clara.

### Paso 6 — Integración ORM y migraciones

**Objetivo:** que el schema sea fuente de verdad.
**Entregables:**

* ORM conectado a Postgres
* Migración inicial aplicada
* Seed mínimo (opcional)
  **Criterio de listo:** podés borrar la DB y reconstruirla con migraciones.

---

## Fase 4 — Seguridad y usuarios (sin esto, no avanzamos)

### Paso 7 — Auth (registro/login/refresh)

**Objetivo:** base segura para un sistema financiero.
**Entregables:**

* Registro
* Login
* Refresh token
* Hash de contraseña + políticas mínimas
  **Criterio de listo:** usuario se registra, inicia sesión y renueva sesión sin romperse.

### Paso 8 — Autorización por usuario (ownership)

**Objetivo:** nadie toca datos que no le pertenecen (aunque seas vos solo).
**Entregables:**

* Middleware/guard para usuario autenticado
* Regla: todo dato pertenece a un userId
  **Criterio de listo:** endpoints devuelven solo data del usuario logueado.

---

## Fase 5 — Core funcional (MVP real)

### Paso 9 — CRUD mínimo de cuentas y categorías

**Objetivo:** preparar el terreno para registrar movimientos bien.
**Entregables:**

* Crear/editar/desactivar cuenta
* Crear/editar categoría
  **Criterio de listo:** se pueden crear las “piezas” del sistema.

### Paso 10 — Movimientos (ingresos/gastos)

**Objetivo:** la función principal.
**Entregables:**

* Crear movimiento
* Listar movimientos (con filtros por fecha/cuenta/categoría)
* Editar / eliminar (decidir si hard o soft)
  **Criterio de listo:** registrar “gasté 5000 en cine” y verlo reflejado.

### Paso 11 — Reportes básicos

**Objetivo:** valor real: entender tus finanzas.
**Entregables:**

* Resumen mensual (total ingresos/gastos/balance)
* Totales por categoría en un mes
  **Criterio de listo:** “gastos de mayo” funciona.

---

## Fase 6 — Calidad, estabilidad y preparación para crecer

### Paso 12 — Validaciones, errores y logging

**Objetivo:** que sea mantenible.
**Entregables:**

* Validación de DTOs
* Manejo consistente de errores
* Logs útiles
  **Criterio de listo:** errores claros y trazabilidad.

### Paso 13 — Testing mínimo (sin volverse loco)

**Objetivo:** evitar regressions.
**Entregables:**

* Tests para auth + movimientos
  **Criterio de listo:** cambios no rompen lo esencial.

### Paso 14 — Documentación y contratos

**Objetivo:** dejar el backend “consumible” por frontend o chatbot.
**Entregables:**

* Swagger / OpenAPI
* Convención de responses
  **Criterio de listo:** cualquiera puede usar la API mirando la doc.

---

## Fase 7 — Futuro (cuando el MVP ya vive)

### Paso 15 — Deudas/cuotas/presupuestos/impuestos/depto

**Objetivo:** ampliar el dominio sin romper lo existente.
**Entregables:** nuevas entidades + reportes.

### Paso 16 — Documentos (tickets, PDFs)

**Objetivo:** pipeline: subir → extraer → confirmar → registrar.

### Paso 17 — IA + WhatsApp

**Objetivo:** la IA interpreta, el backend ejecuta (la IA no escribe directo).

* Intent detection → comando interno → createMovement
* “Resumen de mayo” → query → respuesta formateada

---