# STOCKMASTERbdv4 - Sistema de Gestión de Inventario y Ventas

## 📋 Descripción General

STOCKMASTERbdv4 es una base de datos SQL Server diseñada para gestionar:
- **Productos** con control de stock y precio
- **Personas** (clientes y vendedores) con tipos
- **Ventas** y detalles de facturas
- **Categorías** de productos
- **Auditoría** de cambios en personas

## 📁 Estructura de Carpeta

```
Entrgable_dos/
├── README.md                      # Este archivo
├── scriptusuariosyalma.sql        # Creación de base de datos y tablas
├── INSERTAR_DATOS.sql             # Script para ingresar datos (505 ventas + 1000 stock/artículo)
├── triggers.sql                   # Definición de todos los triggers
├── ejemplos_triggers.sql          # Ejemplos de uso de triggers
└── consulta_Optimizada.sql        # Consultas de ejemplo
```

## 📊 Tablas Principales

### 1. **TipoPersona**
Almacena los tipos de personas en el sistema.
```sql
- id_tipo_persona (PK, INT IDENTITY)
- descripcion (NVARCHAR)
```

**Datos incluidos:**
- Cliente
- Vendedor
- Administrador

### 2. **Categoria**
Almacena las categorías de productos.
```sql
- id_categoria (PK, INT IDENTITY)
- descripcion (NVARCHAR)
```

**Datos incluidos:**
- Electrónica
- Componentes
- Pantallas

### 3. **Articulo**
Almacena los productos con stock y precio.
```sql
- codigo (PK, NVARCHAR 50)
- nombre (NVARCHAR)
- precio (NUMERIC 18,0)
- stock (INT)
- id_categoria (FK, INT)
```

**15 Artículos disponibles:**
```
ART-001 | LED 2121              | $100       | 1000 stock | Electrónica
ART-002 | Fuente 60A 5v         | $180,000   | 1000 stock | Componentes
ART-003 | Modulo p4 80 40"      | $150,000   | 1000 stock | Pantallas
ART-004 | Cable HDMI 3m         | $45,000    | 1000 stock | Componentes
ART-005 | Router WiFi 6         | $320,000   | 1000 stock | Electrónica
ART-006 | Monitor LED 24"       | $450,000   | 1000 stock | Pantallas
ART-007 | Teclado Mecánico RGB  | $280,000   | 1000 stock | Electrónica
ART-008 | Mouse Inalámbrico     | $65,000    | 1000 stock | Electrónica
ART-009 | Webcam Full HD        | $95,000    | 1000 stock | Electrónica
ART-010 | Mousepad Grande       | $45,000    | 1000 stock | Componentes
ART-011 | Hub USB 7 Puertos     | $120,000   | 1000 stock | Componentes
ART-012 | Adaptador VGA         | $35,000    | 1000 stock | Componentes
ART-013 | Cable Ethernet CAT6   | $25,000    | 1000 stock | Componentes
ART-014 | Fuente ATX 650W       | $250,000   | 1000 stock | Componentes
ART-015 | Tarjeta Gráfica GTX   | $750,000   | 1000 stock | Electrónica
```

### 4. **Persona**
Almacena información de clientes, vendedores y administradores.
```sql
- id_persona (PK, INT IDENTITY)
- nombre (NVARCHAR)
- usuario (NVARCHAR)
- contrasena (NVARCHAR)
- direccion (NVARCHAR)
- id_tipo (FK, INT)
```

**6 Personas registradas:**
```
ID 1 | Cliente 1          | cliente1   | Calle Principal 123      | Cliente
ID 2 | Cliente 2          | cliente2   | Carrera Secundaria 456   | Cliente
ID 3 | Cliente 3          | cliente3   | Avenida Central 789      | Cliente
ID 4 | Vendedor Juan      | juanvend   | Calle Comercial 100      | Vendedor
ID 5 | Vendedor María     | mariavend  | Calle Comercial 200      | Vendedor
ID 6 | Administrador      | admin      | Oficina Central          | Administrador
```

### 5. **Venta**
Almacena las ventas realizadas.
```sql
- id_venta (PK, INT IDENTITY)
- fecha (DATE)
- descuento (NUMERIC 3,2) - Valores entre 0 y 100
- total (NUMERIC 18,0)
- id_persona (FK, INT)
```

**Datos incluidos:**
- 505 ventas distribuidas entre clientes (IDs 1-3)
- Fechas distribuidas en 2026
- Descuentos variables: 0%, 5%, 10%, 15%

### 6. **DetalleFactura**
Almacena los items de cada venta.
```sql
- id_detalle (PK, INT IDENTITY)
- cantidad (INT)
- precio_unitario (NUMERIC 18,0)
- subtotal (NUMERIC 18,0)
- id_venta (FK, INT)
- codigo_articulo (FK, NVARCHAR 50)
```

**Datos incluidos:**
- ~1500+ detalles de facturas
- 2-3 items por venta
- Subtotales calculados (cantidad × precio_unitario)

### 7. **AuditoriaPersona** (Opcional)
Registra cambios en usuarios, contraseñas y direcciones.
```sql
- id_auditoria (PK, INT IDENTITY)
- id_persona (FK, INT)
- usuario (NVARCHAR)
- campo_modificado (NVARCHAR)
- valor_anterior (NVARCHAR)
- valor_nuevo (NVARCHAR)
- fecha_cambio (DATETIME)
```

## 🚀 Guía de Uso

### Paso 1: Crear la Base de Datos
Ejecuta el script `scriptusuariosyalma.sql`:
```sql
-- En SQL Server Management Studio:
-- 1. Selecciona "New Query"
-- 2. Abre el archivo scriptusuariosyalma.sql
-- 3. Presiona F5 para ejecutar
```

### Paso 2: Ingresar Datos
Ejecuta el script `INSERTAR_DATOS.sql`:
```sql
-- Este script inserta:
-- ✓ 3 Tipos de Personas
-- ✓ 3 Categorías
-- ✓ 15 Artículos (1000 stock cada uno)
-- ✓ 6 Personas
-- ✓ 505 Ventas
-- ✓ ~1500 Detalles de Ventas
```

### Paso 3: Trabajar con los Triggers
Los triggers se crean automáticamente en `scripts/usuariosyalma.sql` y funcionan automáticamente.

## 📈 Datos Incluidos

### Resumen
| Tabla | Cantidad |
|-------|----------|
| Tipos de Personas | 3 |
| Categorías | 3 |
| Artículos | 15 |
| Personas | 6 |
| Ventas | 505 |
| Detalles de Ventas | ~1500+ |

## 🔍 Consultas Útiles

### Ver todas las ventas
```sql
SELECT v.id_venta, v.fecha, p.nombre, v.total, v.descuento
FROM dbo.Venta v
INNER JOIN dbo.Persona p ON v.id_persona = p.id_persona
ORDER BY v.id_venta DESC;
```

### Ver detalles de una venta
```sql
SELECT 
    df.id_detalle,
    a.codigo,
    a.nombre,
    df.cantidad,
    df.precio_unitario,
    df.subtotal
FROM dbo.DetalleFactura df
INNER JOIN dbo.Articulo a ON df.codigo_articulo = a.codigo
WHERE df.id_venta = 1;
```

### Ver stock actual
```sql
SELECT codigo, nombre, precio, stock, id_categoria
FROM dbo.Articulo
ORDER BY codigo;
```

### Ventas totales por persona
```sql
SELECT 
    p.id_persona,
    p.nombre,
    tp.descripcion,
    COUNT(v.id_venta) AS total_ventas,
    SUM(v.total) AS monto_vendido
FROM dbo.Persona p
LEFT JOIN dbo.TipoPersona tp ON p.id_tipo = tp.id_tipo_persona
LEFT JOIN dbo.Venta v ON p.id_persona = v.id_persona
GROUP BY p.id_persona, p.nombre, tp.descripcion
ORDER BY monto_vendido DESC;
```

### Artículos con bajo stock
```sql
SELECT codigo, nombre, precio, stock
FROM dbo.Articulo
WHERE stock < 100
ORDER BY stock;
```

### Ingresos por categoría
```sql
SELECT 
    c.id_categoria,
    c.descripcion,
    COUNT(DISTINCT v.id_venta) AS num_ventas,
    SUM(df.subtotal) AS ingresos_totales
FROM dbo.Categoria c
INNER JOIN dbo.Articulo a ON c.id_categoria = a.id_categoria
INNER JOIN dbo.DetalleFactura df ON a.codigo = df.codigo_articulo
INNER JOIN dbo.Venta v ON df.id_venta = v.id_venta
GROUP BY c.id_categoria, c.descripcion
ORDER BY ingresos_totales DESC;
```

## ⚙️ Procedimientos Comunes

### Insertar una nueva venta
```sql
-- 1. Crear la venta
INSERT INTO dbo.Venta (fecha, descuento, total, id_persona)
VALUES (GETDATE(), 0, 0, 1);

-- 2. Obtener el ID de la venta creada
DECLARE @ventaId INT = IDENT_CURRENT('dbo.Venta');

-- 3. Agregar detalles
INSERT INTO dbo.DetalleFactura (cantidad, precio_unitario, subtotal, id_venta, codigo_articulo)
VALUES (2, 100, 200, @ventaId, 'ART-001');
```

### Crear nueva persona
```sql
INSERT INTO dbo.Persona (nombre, usuario, contrasena, direccion, id_tipo)
VALUES (N'Nuevo Cliente', N'usuario_nuevo', N'password', N'Dirección', 1);
-- id_tipo: 1=Cliente, 2=Vendedor, 3=Administrador
```

### Actualizar stock
```sql
UPDATE dbo.Articulo
SET stock = stock - 50
WHERE codigo = 'ART-001';
```

### Eliminar una venta
```sql
-- Eliminar detalles primero
DELETE FROM dbo.DetalleFactura
WHERE id_venta = 1;

-- Luego eliminar la venta
DELETE FROM dbo.Venta
WHERE id_venta = 1;
```

## 📝 Notas Importantes

✅ **CARACTERÍSTICAS:**
- Estructura normalizada para integridad referencial
- Stock inicial de 1000 unidades por artículo
- 505 ventas precargadas para análisis
- Descuentos variados en ventas (0%, 5%, 10%, 15%)
- Artículos especializados en electrónica y componentes

⚠️ **RESTRICCIONES:**
- Los descuentos deben estar entre 0 y 100
- Las categorías deben existir para asignar artículos
- Las personas deben tener un tipo válido
- El stock no puede ser negativo

## 🐛 Solución de Problemas

**Error: "Violación de restricción de clave foránea"**
- Asegúrate de que los IDs referenciados existen en la tabla principal
- Ejemplo: id_categoria debe existir en tabla Categoria

**Error: "El descuento debe estar entre 0 y 100"**
- El campo descuento solo acepta valores de 0 a 100

**Error: "Tipo de persona no existe"**
- Los valores válidos para id_tipo son: 1 (Cliente), 2 (Vendedor), 3 (Administrador)

## 📞 Archivos de Referencia

- `scriptusuariosyalma.sql` - Definiciones de tablas y estructura
- `INSERTAR_DATOS.sql` - Script de inserción de datos con 505 ventas
- `triggers.sql` - Triggers de auditoría y validación
- `ejemplos_triggers.sql` - Ejemplos de uso de triggers
- `consulta_Optimizada.sql` - Consultas de ejemplo

---

**Base de Datos**: STOCKMASTERbdv4  
**Última Actualización**: Mayo 29, 2026  
**Estado**: ✅ Operacional  
**Ventas Precargadas**: 505  
**Stock Inicial**: 1000 por artículo
-- ✓ 6 Personas (clientes y vendedores)
-- ✓ 15 Artículos (1000 stock cada uno)
-- ✓ 505 Ventas (5 iniciales + 500 nuevas)
-- ✓ ~1500+ Detalles de Ventas
```

### Paso 3: Trabajar con los Triggers
Los triggers se crean automáticamente y funcionan:

**Trigger: tr_ActualizarStockDelete**
- Restaura stock cuando se elimina un detalle de venta

**Trigger: tr_ActualizarStockUpdate**
- Ajusta stock cuando se modifica la cantidad vendida

**Trigger: tr_ValidarStockDisponible**
- Valida stock disponible antes de vender

**Trigger: tr_PrevenirEliminarCategoria**
- Evita eliminar categorías con productos

**Trigger: tr_PrevenirEliminarPersona**
- Evita eliminar personas con ventas registradas

**Trigger: tr_AuditarCambiosPersona**
- Registra cambios en usuario, contraseña y dirección

**Trigger: tr_PrevenirStockNegativo**
- Evita stocks negativos

## 📈 Datos Incluidos

### Artículos
```
ART-001 | Laptop HP              | 1000 stock | Electrónica
ART-002 | Mouse Inalámbrico      | 1000 stock | Electrónica
ART-003 | Teclado Mecánico       | 1000 stock | Electrónica
ART-004 | Monitor LG 24"         | 1000 stock | Electrónica
ART-005 | Camiseta Básica        | 1000 stock | Ropa
ART-006 | Pantalón Jeans         | 1000 stock | Ropa
ART-007 | Zapatos Deportivos     | 1000 stock | Ropa
ART-008 | Arroz 5kg              | 1000 stock | Alimentos
ART-009 | Aceite de Oliva 1L     | 1000 stock | Alimentos
ART-010 | Pan de Molde           | 1000 stock | Alimentos
ART-011 | Almohada               | 1000 stock | Hogar
ART-012 | Sábanas Juego          | 1000 stock | Hogar
ART-013 | Balón de Fútbol        | 1000 stock | Deportes
ART-014 | Raqueta de Tenis       | 1000 stock | Deportes
ART-015 | Mancuernas 10kg        | 1000 stock | Deportes
```

### Personas
```
ID 1 | Cliente 1          | cliente1   | Calle Principal 123
ID 2 | Cliente 2          | cliente2   | Carrera Secundaria 456
ID 3 | Cliente 3          | cliente3   | Avenida Central 789
ID 4 | Vendedor Juan      | juanvend   | Calle Comercial 100
ID 5 | Vendedor María     | mariavend  | Calle Comercial 200
ID 6 | Administrador      | admin      | Oficina Central
```

### Ventas
- **505 ventas totales** distribuidas entre los clientes (IDs 1-5)
- Fechas distribuidas en 2026
- Descuentos variables: 0%, 5%, 10%, 15%
- Cada venta contiene 2-3 detalles de artículos

## 🔍 Consultas Útiles

### Ver todas las ventas
```sql
SELECT v.id_venta, v.fecha, p.nombre, v.total, v.descuento
FROM dbo.Venta v
INNER JOIN dbo.Persona p ON v.id_persona = p.id_persona
ORDER BY v.id_venta DESC;
```

### Ver detalles de una venta
```sql
SELECT 
    df.id_detalle,
    a.codigo,
    a.nombre,
    df.cantidad,
    df.precio_unitario,
    df.subtotal
FROM dbo.DetalleFactura df
INNER JOIN dbo.Articulo a ON df.codigo_articulo = a.codigo
WHERE df.id_venta = 1;
```

### Ver stock actual
```sql
SELECT codigo, nombre, stock, id_categoria
FROM dbo.Articulo
ORDER BY codigo;
```

### Ventas totales por persona
```sql
SELECT 
    p.id_persona,
    p.nombre,
    COUNT(v.id_venta) AS total_ventas,
    SUM(v.total) AS monto_vendido
FROM dbo.Persona p
LEFT JOIN dbo.Venta v ON p.id_persona = v.id_persona
GROUP BY p.id_persona, p.nombre
ORDER BY monto_vendido DESC;
```

### Artículos con bajo stock
```sql
SELECT codigo, nombre, stock
FROM dbo.Articulo
WHERE stock < 100
ORDER BY stock;
```

## ⚙️ Procedimientos Comunes

### Insertar una nueva venta
```sql
-- 1. Crear la venta
INSERT INTO dbo.Venta (fecha, total, descuento, id_persona)
VALUES (GETDATE(), 0, 0, 1);

-- 2. Obtener el ID de la venta creada
DECLARE @ventaId INT = IDENT_CURRENT('dbo.Venta');

-- 3. Agregar detalles (el trigger validará y ajustará stock automáticamente)
INSERT INTO dbo.DetalleFactura (cantidad, precio_unitario, subtotal, id_venta, codigo_articulo)
VALUES (2, 1200000, 2400000, @ventaId, 'ART-001');
```

### Eliminar una venta
```sql
-- Eliminar detalles primero
DELETE FROM dbo.DetalleFactura
WHERE id_venta = 1;

-- Luego eliminar la venta (stock se restaurará automáticamente)
DELETE FROM dbo.Venta
WHERE id_venta = 1;
```

## 📝 Notas Importantes

⚠️ **TRIGGERS ACTIVOS:**
- El trigger `tr_ValidarStockDisponible` puede rechazar inserciones si no hay stock
- Los triggers actualizan automáticamente el stock y totales
- No se pueden eliminar categorías con artículos
- No se pueden eliminar personas con ventas registradas

✅ **STOCK INICIAL:**
- Cada artículo comienza con 1000 unidades
- El stock se reduce automáticamente con cada venta
- Se restaura si se elimina una factura

## 🐛 Solución de Problemas

**Error: "No hay stock disponible"**
- El trigger rechazó la venta por falta de stock
- Verifica el stock disponible: `SELECT stock FROM dbo.Articulo WHERE codigo = 'ART-001'`

**Error: "No se puede eliminar categoría"**
- La categoría tiene artículos
- Transfiere o elimina primero los artículos

**Error: "No se puede eliminar persona"**
- La persona tiene ventas registradas
- Elimina primero las ventas asociadas

---

**Base de Datos**: STOCKMASTERbdv4  
**Última Actualización**: Mayo 29, 2026  
**Estado**: ✅ Operacional
