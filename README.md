# ERP Salteñería Don José (Dolibarr)

Infraestructura ERP contenerizada con Docker para la gestión operativa, control de inventarios, producción MRP y flujo de tesorería de Salteñería Don José (Cochabamba, Bolivia).

Es el **sistema interno del negocio** (configurado en SIG I). La tienda en línea se conecta a este Dolibarr por su API REST: [e-commerce_Salteneria_Don_Jose](https://github.com/Jherson1727/e-commerce_Salteneria_Don_Jose).

---

## Contenido del repositorio

| Archivo | Qué es |
|---|---|
| `docker-compose.yml` | Levanta Dolibarr 19.0.2 (`tuxgasy/dolibarr`) y MariaDB 10.8 |
| `backup_don_jose.sql` | Base de datos completa del negocio (se importa sola al primer arranque) |

## Requisitos

- Docker Desktop (en Windows, con WSL2 activado).
- Puerto **8080** libre.

## Cómo levantarlo

```bash
git clone https://github.com/Jherson1727/erp-salteneria-don-jose.git
cd erp-salteneria-don-jose
docker compose up -d
```

Abrir **http://localhost:8080** (la primera vez tarda unos minutos mientras importa el backup).

- Usuario: `admin` · Contraseña: `adminpassword` (solo para desarrollo local; se cambia antes de la demo).

### Actualizar a un backup nuevo del repo

El backup solo se importa cuando la base está vacía. Para cargar uno nuevo:

```bash
git pull
docker compose down -v   # ⚠️ borra la base de datos local
docker compose up -d
```

## Datos configurados

**Módulos activos:** Terceros, Productos, Stock, Facturas, Proveedores, Bancos/Cajas, Listas de materiales (BOM), Fabricación (MRP), Presupuestos, Márgenes, Usuarios y **API REST**.

**Almacenes**

| Ref | Uso |
|---|---|
| `ALM-INS` | Cocina: materias primas e insumos (INS-01 a INS-10) |
| `ALM-POS` | Mostrador: productos terminados para la venta |

**Productos a la venta**

| Ref | Producto |
|---|---|
| SAL-01 | Salteña de Carne |
| SAL-02 | Salteña de Pollo |
| SAL-03 | Salteña Mixta |
| SAL-04 | Salteña Picante |
| BEB-01 | Gaseosa / Refresco 500 ml |
| BEB-02 | Jugo Natural / Mocochinchi |

**Producción:** recetas (BOM) de las salteñas y órdenes de fabricación (MRP) que consumen insumos de ALM-INS e ingresan producto a ALM-POS.

**Terceros:** proveedores (harina, carnes, lácteos y grasas, verduras, bebidas), clientes y el tercero **Cliente Web** (respaldo para ventas en línea).

**Bancos y cajas**

| Ref | Uso |
|---|---|
| `CAJA-01` | Caja chica del mostrador (efectivo) |
| `BANCO-QR` | Cobros por QR (ventas web y QR en mostrador) |

**Usuarios y roles**

| Usuario | Rol |
|---|---|
| `admin` | Administrador (gerencia) |
| `cajero_pos` | Ventas en mostrador |
| `cocina_mrp` | Producción |
| `ecommerce` | Usuario técnico de la tienda en línea (solo API, permisos mínimos) |

**Histórico:** 3 meses de transacciones simuladas (ventas, movimientos de caja y órdenes de producción) desde julio de 2026.

## Conexión con el e-commerce

1. En Dolibarr: **Usuarios y grupos → ecommerce → Modificar → Clave para API → generar → Grabar**.
2. Copiar esa clave en el `.env.local` del e-commerce (`VITE_DOLIBARR_API_KEY`).
3. Cada venta web crea la factura a nombre del cliente, la valida en **ALM-POS** (descuenta stock) y registra el cobro en **BANCO-QR**.

> La API key **nunca** se sube al repo ni se comparte en grupos.

## Cómo exportar un backup (solo el responsable del repo)

Exportar **siempre** así, desde la carpeta del repo. **No usar** `mysqldump ... > archivo.sql` en PowerShell: guarda el archivo en UTF-16, se pierden las ñ y tildes, y el backup ya no se puede importar.

```bash
docker compose exec dolibarr-db mysqldump -u root -prootpassword --default-character-set=utf8mb4 --result-file=/tmp/backup.sql dolibarr
docker compose cp dolibarr-db:/tmp/backup.sql ./backup_don_jose.sql
```

Luego `git add`, `git commit` y `git push`.

## Problemas frecuentes

| Problema | Solución |
|---|---|
| Sale el asistente de instalación de Dolibarr | El backup no se importó: `docker compose down -v` y `docker compose up -d` |
| Los enlaces de Dolibarr pierden el `:8080` | Verificar `DOLI_URL_ROOT: http://localhost:8080` en `docker-compose.yml` |
| Error al importar (`ASCII '\0'`) | El backup está en UTF-16: volver a exportarlo con los comandos de arriba |
