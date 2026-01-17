# PostgreSQL – Entorno local con Docker

Este proyecto utiliza **PostgreSQL corriendo en Docker** como base de datos local de desarrollo.

La infraestructura está pensada para ser:
- reproducible
- persistente
- independiente del backend
- fácilmente migrable a nube en el futuro

---

## 📦 Contenedor

- **Imagen**: postgres:16
- **Nombre del contenedor**: `finances_postgres`
- **Base de datos**: `finances`
- **Usuario**: `finances_user`
- **Puerto**: `5432`
- **Persistencia**: volumen Docker (`finances_pgdata`)

---

## 📁 Ubicación de la infraestructura

```

finances_backend/
└── infra/
└── docker/
└── docker-compose.yml

````

---

## ▶️ Comandos básicos

### Levantar el contenedor
```bash
docker compose up -d
````

### Ver contenedores activos

```bash
docker ps
```

### Detener el contenedor

```bash
docker compose down
```

> ⚠️ Esto **NO borra los datos** (gracias al volumen)

---

## 🧠 Logs y diagnóstico

### Ver logs de PostgreSQL

```bash
docker logs finances_postgres
```

Buscar:

```
database system is ready to accept connections
```

---

## 🔐 Acceso a la base de datos (psql)

### Entrar al contenedor con psql

```bash
docker exec -it finances_postgres psql -U finances_user -d finances
```

### Comandos útiles dentro de psql

```sql
\l          -- listar bases de datos
\dt         -- listar tablas
\dn         -- listar schemas
\conninfo   -- info de conexión
\q          -- salir
```

---

## 💾 Persistencia de datos

Los datos se guardan en un **volumen Docker** llamado:

```
finances_pgdata
```

Esto significa que:

* Reiniciar Docker NO borra datos
* Bajar y subir el contenedor NO borra datos
* Los datos solo se pierden si se borra explícitamente el volumen

### Listar volúmenes

```bash
docker volume ls
```

### ⚠️ Borrar datos (solo si querés resetear todo)

```bash
docker volume rm finances_pgdata
```

---

## 🧪 Checks rápidos de estado

### Ver si Postgres responde

```bash
docker exec -it finances_postgres pg_isready -U finances_user
```

Resultado esperado:

```
accepting connections
```

---

## 🔧 Configuración importante

* Las credenciales **son solo para desarrollo**
* No usar estas credenciales en producción
* No commitear `.env` ni secretos reales

---

## 🚫 Qué NO hace este contenedor

* No crea tablas
* No maneja migraciones
* No conoce el backend
* No contiene lógica de negocio

Es **solo infraestructura**.

---

## 📌 Próximos pasos (roadmap)

1. Backend NestJS
2. Integración ORM
3. Migraciones
4. Auth
5. Core financiero

Este contenedor **no cambia** en esos pasos.

---