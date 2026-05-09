USE [STOCKMASTERbdv4]
GO

/**
=======================================================================================
EJEMPLOS DE SENTENCIAS SQL PARA PROBAR CADA TRIGGER
=======================================================================================
*/

/**
TRIGGER 1 y 2: tr_ActualizarStockInsert y tr_ActualizarStockDelete
Objetivo: Actualizar automáticamente el stock cuando se venden artículos
=======================================================================================
*/

-- Ver el stock actual de un artículo
SELECT [codigo], [nombre], [stock] FROM [dbo].[Articulo] WHERE [codigo] = 'ART-001';
GO

-- Insertar un detalle de factura (el trigger reducirá automáticamente el stock)
INSERT INTO [dbo].[DetalleFactura] ([cantidad], [precio_unitario], [subtotal], [id_venta], [codigo_articulo])
VALUES (5, 100, 0, 1, 'ART-001');
GO

-- Verificar que el stock se ha reducido
SELECT [codigo], [nombre], [stock] FROM [dbo].[Articulo] WHERE [codigo] = 'ART-001';
GO

-- Eliminar el detalle (el trigger restaurará el stock)
DELETE FROM [dbo].[DetalleFactura] WHERE [id_venta] = 1 AND [codigo_articulo] = 'ART-001';
GO

-- Verificar que el stock se ha restaurado
SELECT [codigo], [nombre], [stock] FROM [dbo].[Articulo] WHERE [codigo] = 'ART-001';
GO

/**
TRIGGER 3: tr_ActualizarStockUpdate
Objetivo: Ajustar el stock cuando se modifica la cantidad vendida
=======================================================================================
*/

-- Obtener el stock actual
SELECT [codigo], [nombre], [stock] FROM [dbo].[Articulo] WHERE [codigo] = 'ART-002';
GO

-- Insertar un detalle de factura
INSERT INTO [dbo].[DetalleFactura] ([cantidad], [precio_unitario], [subtotal], [id_venta], [codigo_articulo])
VALUES (3, 180000, 0, 1, 'ART-002');
GO

-- Verificar stock después de insertar
SELECT [codigo], [nombre], [stock] FROM [dbo].[Articulo] WHERE [codigo] = 'ART-002';
GO

-- Actualizar la cantidad (cambiar de 3 a 5 unidades)
UPDATE [dbo].[DetalleFactura]
SET [cantidad] = 5
WHERE [id_venta] = 1 AND [codigo_articulo] = 'ART-002';
GO

-- Verificar que el stock se ajustó (se restaron 2 unidades más)
SELECT [codigo], [nombre], [stock] FROM [dbo].[Articulo] WHERE [codigo] = 'ART-002';
GO

/**
TRIGGER 4: tr_ValidarStockDisponible
Objetivo: Evitar vender más cantidad de la disponible
=======================================================================================
*/

-- Ver stock disponible
SELECT [codigo], [nombre], [stock] FROM [dbo].[Articulo] WHERE [codigo] = 'ART-001';
GO

-- Intentar vender MÁS cantidad de la disponible (esto lanzará un error)
-- Este trigger usa INSTEAD OF INSERT, reemplaza el comportamiento normal
INSERT INTO [dbo].[DetalleFactura] ([cantidad], [precio_unitario], [subtotal], [id_venta], [codigo_articulo])
VALUES (9999, 100, 0, 1, 'ART-001');
GO

-- Intento con producto que no existe (también dará error)
INSERT INTO [dbo].[DetalleFactura] ([cantidad], [precio_unitario], [subtotal], [id_venta], [codigo_articulo])
VALUES (10, 100, 0, 1, 'PRODUCTO-INEXISTENTE');
GO

/**
TRIGGER 5: tr_CalcularSubtotal
Objetivo: Calcular automáticamente el subtotal (cantidad × precio_unitario)
=======================================================================================
*/

-- Insertar un detalle sin especificar subtotal
INSERT INTO [dbo].[DetalleFactura] ([cantidad], [precio_unitario], [id_venta], [codigo_articulo])
VALUES (2, 50000, 1, 'ART-001');
GO

-- El trigger calculará el subtotal automáticamente
SELECT [id_detalle], [cantidad], [precio_unitario], [subtotal] 
FROM [dbo].[DetalleFactura] 
WHERE [id_venta] = 1 AND [codigo_articulo] = 'ART-001'
ORDER BY [id_detalle] DESC;
GO

-- Actualizar la cantidad (el subtotal se recalculará)
UPDATE [dbo].[DetalleFactura]
SET [cantidad] = 4
WHERE [id_venta] = 1 AND [codigo_articulo] = 'ART-001';
GO

-- Verificar que el subtotal se actualizó
SELECT [id_detalle], [cantidad], [precio_unitario], [subtotal] 
FROM [dbo].[DetalleFactura] 
WHERE [id_venta] = 1 AND [codigo_articulo] = 'ART-001'
ORDER BY [id_detalle] DESC;
GO

/**
TRIGGER 6: tr_ActualizarTotalVenta
Objetivo: Recalcular el total de la venta cuando cambian los detalles
=======================================================================================
*/

-- Ver el total actual de la venta
SELECT [id_venta], [fecha], [total], [descuento], [id_persona] 
FROM [dbo].[Venta] 
WHERE [id_venta] = 1;
GO

-- Ver todos los detalles de la venta
SELECT [id_detalle], [cantidad], [precio_unitario], [subtotal], [id_venta]
FROM [dbo].[DetalleFactura]
WHERE [id_venta] = 1;
GO

-- Insertar un nuevo detalle (el total de la venta se recalculará automáticamente)
INSERT INTO [dbo].[DetalleFactura] ([cantidad], [precio_unitario], [id_venta], [codigo_articulo])
VALUES (3, 25000, 1, 'ART-003');
GO

-- Ver el nuevo total de la venta
SELECT [id_venta], [fecha], [total], [descuento], [id_persona] 
FROM [dbo].[Venta] 
WHERE [id_venta] = 1;
GO

-- Actualizar un detalle existente
UPDATE [dbo].[DetalleFactura]
SET [cantidad] = 6
WHERE [id_venta] = 1 AND [codigo_articulo] = 'ART-003';
GO

-- Ver el total actualizado
SELECT [id_venta], [fecha], [total], [descuento], [id_persona] 
FROM [dbo].[Venta] 
WHERE [id_venta] = 1;
GO

/**
TRIGGER 7: tr_PrevenirEliminarCategoria
Objetivo: No permitir eliminar una categoría si tiene artículos
=======================================================================================
*/

-- Ver las categorías
SELECT [id_categoria], [descripcion] FROM [dbo].[Categoria];
GO

-- Ver qué artículos tienen la categoría 1
SELECT [codigo], [nombre], [id_categoria] FROM [dbo].[Articulo] WHERE [id_categoria] = 1;
GO

-- Intentar eliminar una categoría que tiene artículos (dará error)
DELETE FROM [dbo].[Categoria] WHERE [id_categoria] = 1;
GO

-- Para eliminar la categoría, primero hay que transferir o eliminar sus artículos
-- Actualizar los artículos a otra categoría
UPDATE [dbo].[Articulo] SET [id_categoria] = 2 WHERE [id_categoria] = 1;
GO

-- Ahora sí se puede eliminar la categoría
DELETE FROM [dbo].[Categoria] WHERE [id_categoria] = 1;
GO

/**
TRIGGER 8: tr_PrevenirEliminarPersona
Objetivo: No permitir eliminar una persona si tiene ventas registradas
=======================================================================================
*/

-- Ver las personas
SELECT [id_persona], [nombre], [usuario] FROM [dbo].[Persona];
GO

-- Ver qué ventas tiene una persona
SELECT [id_venta], [fecha], [total], [id_persona] FROM [dbo].[Venta] WHERE [id_persona] = 1;
GO

-- Intentar eliminar una persona que tiene ventas (dará error)
DELETE FROM [dbo].[Persona] WHERE [id_persona] = 1;
GO

-- Para eliminar la persona, primero hay que eliminar sus ventas
-- Esto eliminará también los detalles de factura asociados
DELETE FROM [dbo].[DetalleFactura] 
WHERE [id_venta] IN (SELECT [id_venta] FROM [dbo].[Venta] WHERE [id_persona] = 1);

DELETE FROM [dbo].[Venta] WHERE [id_persona] = 1;
GO

-- Ahora sí se puede eliminar la persona
DELETE FROM [dbo].[Persona] WHERE [id_persona] = 1;
GO

/**
TRIGGER 9: tr_AuditarCambiosPersona
Objetivo: Registrar los cambios en usuario, contraseña y dirección
=======================================================================================
*/

-- Ver la tabla de auditoría
SELECT * FROM [dbo].[AuditoriaPersona];
GO

-- Actualizar el usuario de una persona
UPDATE [dbo].[Persona]
SET [usuario] = 'nuevo_usuario'
WHERE [id_persona] = 2;
GO

-- Ver el registro de auditoría (se agregará un registro)
SELECT [id_auditoria], [id_persona], [usuario], [campo_modificado], [valor_anterior], [valor_nuevo], [fecha_cambio]
FROM [dbo].[AuditoriaPersona]
ORDER BY [id_auditoria] DESC;
GO

-- Actualizar la contraseña
UPDATE [dbo].[Persona]
SET [contrasena] = 'nueva_contrasena_123'
WHERE [id_persona] = 2;
GO

-- Actualizar la dirección
UPDATE [dbo].[Persona]
SET [direccion] = 'Calle Nueva 456, Apartamento 5'
WHERE [id_persona] = 2;
GO

-- Ver todos los cambios registrados
SELECT [id_auditoria], [id_persona], [usuario], [campo_modificado], [valor_anterior], [valor_nuevo], [fecha_cambio]
FROM [dbo].[AuditoriaPersona]
WHERE [id_persona] = 2
ORDER BY [fecha_cambio] DESC;
GO

/**
TRIGGER 10: tr_PrevenirStockNegativo
Objetivo: Evitar que el stock sea negativo
=======================================================================================
*/

-- Ver el stock actual
SELECT [codigo], [nombre], [stock] FROM [dbo].[Articulo] WHERE [codigo] = 'ART-001';
GO

-- Intentar actualizar directamente el stock a un valor negativo (dará error)
UPDATE [dbo].[Articulo]
SET [stock] = -10
WHERE [codigo] = 'ART-001';
GO

-- Actualizar a un valor positivo (funcionará)
UPDATE [dbo].[Articulo]
SET [stock] = 100
WHERE [codigo] = 'ART-001';
GO

-- Verificar
SELECT [codigo], [nombre], [stock] FROM [dbo].[Articulo] WHERE [codigo] = 'ART-001';
GO

/**
=======================================================================================
CONSULTAS DE VERIFICACIÓN Y MONITOREO
=======================================================================================
*/

-- Consulta 1: Ver el estado actual del stock de todos los artículos
SELECT 
    [codigo],
    [nombre],
    [stock],
    [id_categoria]
FROM [dbo].[Articulo]
ORDER BY [codigo];
GO

-- Consulta 2: Ver todas las ventas con sus totales
SELECT 
    v.[id_venta],
    v.[fecha],
    p.[nombre] AS [cliente],
    v.[descuento],
    v.[total]
FROM [dbo].[Venta] v
INNER JOIN [dbo].[Persona] p ON v.[id_persona] = p.[id_persona]
ORDER BY v.[id_venta] DESC;
GO

-- Consulta 3: Ver los detalles de una venta específica
SELECT 
    df.[id_detalle],
    df.[codigo_articulo],
    a.[nombre],
    df.[cantidad],
    df.[precio_unitario],
    df.[subtotal]
FROM [dbo].[DetalleFactura] df
INNER JOIN [dbo].[Articulo] a ON df.[codigo_articulo] = a.[codigo]
WHERE df.[id_venta] = 1
ORDER BY df.[id_detalle];
GO

-- Consulta 4: Ver el resumen de auditoría
SELECT 
    [id_auditoria],
    [id_persona],
    [usuario],
    [campo_modificado],
    [valor_anterior],
    [valor_nuevo],
    [fecha_cambio]
FROM [dbo].[AuditoriaPersona]
ORDER BY [fecha_cambio] DESC;
GO

-- Consulta 5: Ver artículos con bajo stock (menos de 10 unidades)
SELECT 
    [codigo],
    [nombre],
    [stock],
    [id_categoria]
FROM [dbo].[Articulo]
WHERE [stock] < 10
ORDER BY [stock];
GO

-- Consulta 6: Ver ingresos por categoría
SELECT 
    c.[id_categoria],
    c.[descripcion],
    COUNT(DISTINCT v.[id_venta]) AS [num_ventas],
    SUM(df.[subtotal]) AS [ingresos_totales]
FROM [dbo].[Categoria] c
INNER JOIN [dbo].[Articulo] a ON c.[id_categoria] = a.[id_categoria]
INNER JOIN [dbo].[DetalleFactura] df ON a.[codigo] = df.[codigo_articulo]
INNER JOIN [dbo].[Venta] v ON df.[id_venta] = v.[id_venta]
GROUP BY c.[id_categoria], c.[descripcion]
ORDER BY [ingresos_totales] DESC;
GO
