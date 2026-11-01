# Política de Seguridad

## Versiones soportadas

| Versión | Soporte          |
|---------|------------------|
| 0.1.x   | ✅ Activo        |
| < 0.1   | ❌ No soportada  |

## Reportar una vulnerabilidad

**Por favor, NO reportes vulnerabilidades a través de issues públicos de GitHub.**

Envía un correo a [security@example.com](mailto:security@example.com) con la siguiente información:

- Descripción detallada de la vulnerabilidad.
- Pasos para reproducirla.
- Versión(es) afectada(s).
- Impacto potencial.
- (Opcional) Posible mitigación o parche.

### Tiempo de respuesta

| Etapa                       | Tiempo estimado |
|-----------------------------|-----------------|
| Confirmación de recepción   | ≤ 48 h          |
| Evaluación inicial          | ≤ 5 días        |
| Resolución o mitigación     | ≤ 30 días       |

## Buenas prácticas de seguridad en el proyecto

- Secretos gestionados vía variables de entorno (`.env`), nunca en el código.
- `.env` incluido en `.gitignore` y `.dockerignore`.
- Escaneo automático con **CodeQL** en cada push/PR.
- Dependencias auditadas vía **Dependabot**.
- HTTPS obligatorio en producción.
- Rotación periódica de credenciales de base de datos (`MYSQL_PASSWORD`).
- Contraseñas hasheadas con bcrypt/argon2 en base de datos.

## Alcance

Esta política cubre:

- Código del backend (`apps/backend`).
- Código del frontend (`apps/frontend`).
- Código Android (`apps/android`).
- Paquetes compartidos (`packages/*`).
- Configuración de infraestructura (`compose*.yaml`, `.github/workflows/*`).
