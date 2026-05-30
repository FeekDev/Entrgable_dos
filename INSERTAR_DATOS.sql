USE [STOCKMASTERbdv4]
GO

/**=======================================================================================
    SCRIPT PARA INGRESAR DATOS EN LAS TABLAS
    Estructura según las tablas creadas en scriptusuariosyalma.sql
    Asegúrate de ejecutar en este orden para no violar restricciones de clave foránea
=======================================================================================**/

-- =====================================================================================
-- PASO 1: INSERTAR TIPOS DE PERSONAS
-- =====================================================================================
DELETE FROM [dbo].[TipoPersona];
INSERT INTO [dbo].[TipoPersona] ([descripcion])
VALUES 
(N'Cliente'),
(N'Vendedor'),
(N'Administrador');
GO

PRINT 'Tipos de personas insertados correctamente'
GO

-- =====================================================================================
-- PASO 2: INSERTAR CATEGORÍAS
-- =====================================================================================
DELETE FROM [dbo].[Categoria];
INSERT INTO [dbo].[Categoria] ([descripcion]) 
VALUES 
(N'Electrónica'),
(N'Componentes'),
(N'Pantallas');
GO

PRINT 'Categorías insertadas correctamente'
GO

-- =====================================================================================
-- PASO 3: INSERTAR ARTÍCULOS (Productos)
-- =====================================================================================
DELETE FROM [dbo].[Articulo];
INSERT INTO [dbo].[Articulo] ([codigo], [nombre], [precio], [stock], [id_categoria])
VALUES 
(N'ART-001', N'LED 2121', 100, 1000, 1),
(N'ART-002', N'Fuente 60A 5v', 180000, 1000, 2),
(N'ART-003', N'Modulo p4 80 40"', 150000, 1000, 3),
(N'ART-004', N'Cable HDMI 3m', 45000, 1000, 2),
(N'ART-005', N'Router WiFi 6', 320000, 1000, 1),
(N'ART-006', N'Monitor LED 24"', 450000, 1000, 3),
(N'ART-007', N'Teclado Mecánico RGB', 280000, 1000, 1),
(N'ART-008', N'Mouse Inalámbrico', 65000, 1000, 1),
(N'ART-009', N'Webcam Full HD', 95000, 1000, 1),
(N'ART-010', N'Mousepad Grande', 45000, 1000, 2),
(N'ART-011', N'Hub USB 7 Puertos', 120000, 1000, 2),
(N'ART-012', N'Adaptador VGA', 35000, 1000, 2),
(N'ART-013', N'Cable Ethernet CAT6', 25000, 1000, 2),
(N'ART-014', N'Fuente ATX 650W', 250000, 1000, 2),
(N'ART-015', N'Tarjeta Gráfica GTX', 750000, 1000, 1);
GO

PRINT 'Artículos insertados correctamente'
GO

-- =====================================================================================
-- PASO 4: INSERTAR PERSONAS (Clientes y Vendedores)
-- =====================================================================================
DELETE FROM [dbo].[Persona];
INSERT INTO [dbo].[Persona] ([nombre], [usuario], [contrasena], [direccion], [id_tipo])
VALUES 
(N'Cliente 1', N'cliente1', N'pass123', N'Calle Principal 123', 1),
(N'Cliente 2', N'cliente2', N'pass456', N'Carrera Secundaria 456', 1),
(N'Cliente 3', N'cliente3', N'pass789', N'Avenida Central 789', 1),
(N'Vendedor Juan', N'juanvend', N'vend123', N'Calle Comercial 100', 2),
(N'Vendedor María', N'mariavend', N'vend456', N'Calle Comercial 200', 2),
(N'Administrador', N'admin', N'admin123', N'Oficina Central', 3);
GO

PRINT 'Personas insertadas correctamente'
GO

-- =====================================================================================
-- PASO 5: INSERTAR 505 VENTAS CON DETALLES
-- Artículos: ART-001, ART-002, ART-003, ART-004, ART-006, ART-007
-- Personas: ID del 1 al 3 (Clientes)
-- =====================================================================================

DELETE FROM [dbo].[DetalleFactura];
DELETE FROM [dbo].[Venta];

DECLARE @counter INT = 1;
DECLARE @personaId INT;
DECLARE @fecha DATE;
DECLARE @descuento NUMERIC(3,2);
DECLARE @articulos TABLE (id INT IDENTITY(1,1), codigo NVARCHAR(50), precio NUMERIC(18,0));

-- Poblamos la tabla de artículos especificados con sus precios
INSERT INTO @articulos (codigo, precio) VALUES
(N'ART-001', 100),
(N'ART-002', 180000),
(N'ART-003', 150000),
(N'ART-004', 45000),
(N'ART-006', 450000),
(N'ART-007', 280000);

WHILE @counter <= 505
BEGIN
    -- Determinamos la persona (ciclo del 1 al 3, solo clientes)
    SET @personaId = ((@counter - 1) % 3) + 1;
    
    -- Generamos una fecha aleatoria en 2026
    SET @fecha = DATEADD(DAY, ((@counter - 1) % 330), '2026-01-01');
    
    -- Descuento aleatorio (0.00, 0.05, 0.10, 0.15)
    SET @descuento = CASE (@counter % 4)
        WHEN 0 THEN 0.00
        WHEN 1 THEN 0.05
        WHEN 2 THEN 0.10
        ELSE 0.15
    END;
    
    -- Insertamos la venta
    INSERT INTO [dbo].[Venta] ([fecha], [descuento], [total], [id_persona])
    VALUES (@fecha, @descuento, 0, @personaId);
    
    -- Insertamos 2-3 detalles aleatorios para esta venta
    DECLARE @detailCounter INT = 1;
    DECLARE @detailCount INT = 2 + ((@counter - 1) % 2);  -- 2 o 3 detalles
    DECLARE @ventaId INT = @@IDENTITY;
    
    WHILE @detailCounter <= @detailCount
    BEGIN
        DECLARE @artIndex INT = ((@counter + @detailCounter) % 6) + 1;
        DECLARE @cantidad INT = 1 + ((@counter + @detailCounter) % 5);
        DECLARE @precio NUMERIC(18,0);
        DECLARE @codigo NVARCHAR(50);
        DECLARE @subtotal NUMERIC(18,0);
        
        SELECT @codigo = codigo, @precio = precio 
        FROM @articulos 
        WHERE id = @artIndex;
        
        SET @subtotal = @cantidad * @precio;
        
        INSERT INTO [dbo].[DetalleFactura] ([cantidad], [precio_unitario], [subtotal], [id_venta], [codigo_articulo])
        VALUES (@cantidad, @precio, @subtotal, @ventaId, @codigo);
        
        SET @detailCounter = @detailCounter + 1;
    END;
    
    SET @counter = @counter + 1;
    
    -- Mostrar progreso cada 100 ventas
    IF @counter % 100 = 0
        PRINT 'Procesadas ' + CAST(@counter - 1 AS VARCHAR(10)) + ' ventas...';
END;

GO

PRINT '505 Ventas con detalles insertadas correctamente'
GO

-- =====================================================================================
-- VERIFICACIONES
-- =====================================================================================
PRINT ''
PRINT '========== RESUMEN DE DATOS INGRESADOS =========='
PRINT ''

SELECT 'Tipo de Personas' AS [Tabla], COUNT(*) AS [Cantidad] FROM [dbo].[TipoPersona]
UNION ALL
SELECT 'Categorías' AS [Tabla], COUNT(*) AS [Cantidad] FROM [dbo].[Categoria]
UNION ALL
SELECT 'Artículos' AS [Tabla], COUNT(*) AS [Cantidad] FROM [dbo].[Articulo]
UNION ALL
SELECT 'Personas' AS [Tabla], COUNT(*) AS [Cantidad] FROM [dbo].[Persona]
UNION ALL
SELECT 'Ventas' AS [Tabla], COUNT(*) AS [Cantidad] FROM [dbo].[Venta]
UNION ALL
SELECT 'Detalles de Ventas' AS [Tabla], COUNT(*) AS [Cantidad] FROM [dbo].[DetalleFactura];

GO

-- Estadísticas de ventas por personas
PRINT ''
PRINT '========== ESTADÍSTICAS DE VENTAS POR PERSONA =========='
PRINT ''

SELECT 
    p.[id_persona],
    p.[nombre],
    tp.[descripcion],
    COUNT(v.[id_venta]) AS [Total Ventas],
    SUM(v.[total]) AS [Monto Total],
    AVG(v.[total]) AS [Promedio por Venta]
FROM [dbo].[Persona] p
LEFT JOIN [dbo].[TipoPersona] tp ON p.[id_tipo] = tp.[id_tipo_persona]
LEFT JOIN [dbo].[Venta] v ON p.[id_persona] = v.[id_persona]
GROUP BY p.[id_persona], p.[nombre], tp.[descripcion]
ORDER BY p.[id_persona];

GO

PRINT ''
PRINT '========== ESTADO DEL STOCK ACTUAL (Artículos utilizados) =========='
PRINT ''

SELECT [codigo], [nombre], [precio], [stock] 
FROM [dbo].[Articulo]
WHERE [codigo] IN (N'ART-001', N'ART-002', N'ART-003', N'ART-004', N'ART-006', N'ART-007')
ORDER BY [codigo];

GO

PRINT ''
PRINT '========== TOP 10 ÚLTIMAS VENTAS =========='
PRINT ''

SELECT TOP 10
    v.[id_venta],
    v.[fecha],
    p.[nombre] AS [cliente],
    COUNT(df.[id_detalle]) AS [items],
    v.[total],
    v.[descuento]
FROM [dbo].[Venta] v
INNER JOIN [dbo].[Persona] p ON v.[id_persona] = p.[id_persona]
LEFT JOIN [dbo].[DetalleFactura] df ON v.[id_venta] = df.[id_venta]
GROUP BY v.[id_venta], v.[fecha], p.[nombre], v.[total], v.[descuento]
ORDER BY v.[id_venta] DESC;

GO

PRINT ''
PRINT '✓ Script de inserción completado exitosamente'
PRINT 'Se han ingresado 505 VENTAS TOTALES con 1000 stock por artículo'
PRINT ''
