# Guía de Contribución

¡Gracias por tu interés en contribuir a **Enterprise Service Management**!

## Requisitos previos

- Node.js `20.11.1` (usa `nvm use` con el archivo `.nvmrc`).
- Docker y Docker Compose.
- Git.

## Configuración del entorno

```bash
# 1. Clonar repositorio
git clone https://github.com/org/enterprise-service-management.git
cd enterprise-service-management

# 2. Instalar dependencias
npm install

# 3. Copiar variables de entorno
cp .env .env.local

# 4. Levantar servicios de desarrollo
docker compose -f compose.yaml -f compose.dev.yaml up -d

# 5. Ejecutar migraciones
npm run db:migrate --workspace=apps/backend

Flujo de trabajo
Crea una rama a partir de develop:

bash
git checkout -b feat/mi-nueva-funcionalidad
Realiza tus cambios siguiendo las convenciones de código.

Asegúrate de que los tests pasen:

bash
npm run lint
npm run test
npm run build
Realiza un commit siguiendo Conventional Commits:

text
feat(backend): agregar endpoint de usuarios
fix(frontend): corregir renderizado de tabla
docs: actualizar README
Abre un Pull Request hacia develop siguiendo la plantilla.

Convenciones de código
TypeScript estricto en todos los paquetes.

Prettier y ESLint configurados en la raíz.

Nombres de archivos en kebab-case.

Componentes React en PascalCase.

Base de datos
Motor: MySQL 8.0

Base de datos: esm_db

Usuario: ADMIN

Contraseña: gestionada vía .env (nunca commitear secretos reales)

Reporte de bugs y solicitudes
Usa las plantillas de issues en .github/ISSUE_TEMPLATE/.

Para vulnerabilidades, consulta SECURITY.md.

Código de Conducta
Al participar, aceptas cumplir nuestro Código de Conducta .
