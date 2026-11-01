# Enterprise Service Management (ESM)

Monorepo empresarial para la gestión de servicios, con backend Node.js/TypeScript, frontend web React y aplicación Android.

## 🧱 Stack Tecnológico

| Capa        | Tecnología                                    |
|-------------|-----------------------------------------------|
| Backend     | Node.js 20 · TypeScript · Express / Fastify   |
| Frontend    | React 18 · Vite · TypeScript                  |
| Android     | Kotlin · Jetpack Compose · Gradle             |
| Base datos  | MySQL 8.0                                     |
| Caché       | Redis 7                                       |
| Orquestador | Turbo                                         |
| Contenedores| Docker · Docker Compose                       |
| CI/CD       | GitHub Actions                                |

## 📂 Estructura del Proyecto

```text
enterprise-service-management/
├── apps/
│   ├── backend/     # API REST
│   ├── frontend/    # SPA React
│   └── android/     # App Android
├── packages/        # Paquetes compartidos
├── .github/         # CI/CD y plantillas
├── compose.yaml     # Compose base
├── compose.dev.yaml # Override desarrollo
├── compose.prod.yaml # Override producción
├── compose.test.yaml # Override pruebas
├── package.json
├── turbo.json
└── tsconfig.base.json
```

## 🚀 Inicio rápido

### Requisitos

- Node.js `20.11.1` (usa `nvm use`)
- Docker ≥ 24
- Docker Compose ≥ 2.20

### Instalación

```bash
git clone https://github.com/org/enterprise-service-management.git
cd enterprise-service-management
npm install
cp .env .env.local
```

### Levantar en desarrollo

```bash
npm run docker:dev

# Frontend: <http://localhost:3000>
# Backend:  <http://localhost:4000>
# Adminer:  <http://localhost:8080>
```

### Ejecutar local sin Docker

```bash
npm run dev
```

## 🗄️ Base de datos

Motor: MySQL 8.0

Base de datos: `esm_db`

Usuario: `ADMIN`

Password: configurada en `.env` (`MYSQL_PASSWORD`)

Conexión desde Adminer (<http://localhost:8080>):

| Campo    | Valor      |
|----------|------------|
| Sistema  | MySQL      |
| Servidor | mysql      |
| Usuario  | ADMIN      |
| Password | (ver .env) |
| Base     | esm_db     |

## 🧪 Pruebas

```bash
npm test                    # Unitarias
npm run test:integration    # Integración (Playwright)
npm run docker:test         # Todo en contenedores
```

## 📦 Build y despliegue

```bash
npm run build
npm run docker:prod
```

## 🤝 Contribución

Consulta `CONTRIBUTING.md` y el Código de Conducta.

## 🔒 Seguridad

Consulta `SECURITY.md`.

## 📄 Licencia

MIT
