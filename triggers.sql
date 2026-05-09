USE [STOCKMASTERbdv4]
GO

/****** Trigger 1: Actualizar stock cuando se inserta un detalle de factura ******/
CREATE TRIGGER [dbo].[tr_ActualizarStockInsert]
ON [dbo].[DetalleFactura]
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Actualizar el stock del artículo restando la cantidad vendida
	UPDATE [dbo].[Articulo]
	SET [stock] = [stock] - INSERTED.[cantidad]
	FROM INSERTED
	WHERE [dbo].[Articulo].[codigo] = INSERTED.[codigo_articulo];
END;
GO

/****** Trigger 2: Restaurar stock cuando se elimina un detalle de factura ******/
CREATE TRIGGER [dbo].[tr_ActualizarStockDelete]
ON [dbo].[DetalleFactura]
AFTER DELETE
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Restaurar el stock del artículo sumando la cantidad eliminada
	UPDATE [dbo].[Articulo]
	SET [stock] = [stock] + DELETED.[cantidad]
	FROM DELETED
	WHERE [dbo].[Articulo].[codigo] = DELETED.[codigo_articulo];
END;
GO

/****** Trigger 3: Ajustar stock cuando se actualiza la cantidad en detalle ******/
CREATE TRIGGER [dbo].[tr_ActualizarStockUpdate]
ON [dbo].[DetalleFactura]
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Si cambió la cantidad, ajustar el stock
	UPDATE [dbo].[Articulo]
	SET [stock] = [stock] - (INSERTED.[cantidad] - DELETED.[cantidad])
	FROM INSERTED
	INNER JOIN DELETED ON INSERTED.[id_detalle] = DELETED.[id_detalle]
	WHERE [dbo].[Articulo].[codigo] = INSERTED.[codigo_articulo];
END;
GO

/****** Trigger 4: Validar que exista stock disponible antes de insertar ******/
CREATE TRIGGER [dbo].[tr_ValidarStockDisponible]
ON [dbo].[DetalleFactura]
INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Verificar si existe stock suficiente
	IF EXISTS (
		SELECT 1
		FROM INSERTED i
		LEFT JOIN [dbo].[Articulo] a ON a.[codigo] = i.[codigo_articulo]
		WHERE i.[cantidad] > COALESCE(a.[stock], 0) OR a.[codigo] IS NULL
	)
	BEGIN
		RAISERROR('Error: No hay stock disponible para el artículo solicitado o el artículo no existe.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END;
	
	-- Si la validación pasa, insertar el registro
	INSERT INTO [dbo].[DetalleFactura] ([cantidad], [precio_unitario], [subtotal], [id_venta], [codigo_articulo])
	SELECT [cantidad], [precio_unitario], [subtotal], [id_venta], [codigo_articulo]
	FROM INSERTED;
	
	-- Actualizar el stock
	UPDATE [dbo].[Articulo]
	SET [stock] = [stock] - i.[cantidad]
	FROM [dbo].[Articulo] a
	INNER JOIN INSERTED i ON a.[codigo] = i.[codigo_articulo];
END;
GO

/****** Trigger 5: Calcular el subtotal automáticamente en detalle de factura ******/
CREATE TRIGGER [dbo].[tr_CalcularSubtotal]
ON [dbo].[DetalleFactura]
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Calcular subtotal (cantidad * precio_unitario)
	UPDATE [dbo].[DetalleFactura]
	SET [subtotal] = i.[cantidad] * i.[precio_unitario]
	FROM INSERTED i
	WHERE [dbo].[DetalleFactura].[id_detalle] = i.[id_detalle];
END;
GO

/****** Trigger 6: Recalcular total de venta cuando cambia detalle de factura ******/
CREATE TRIGGER [dbo].[tr_ActualizarTotalVenta]
ON [dbo].[DetalleFactura]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @id_venta INT;
	
	-- Obtener los ID de ventas afectadas (tanto de INSERTED como de DELETED)
	SELECT DISTINCT @id_venta = [id_venta] FROM INSERTED
	UNION ALL
	SELECT DISTINCT [id_venta] FROM DELETED;
	
	-- Actualizar el total de las ventas afectadas
	UPDATE v
	SET v.[total] = COALESCE((
		SELECT SUM([subtotal])
		FROM [dbo].[DetalleFactura]
		WHERE [id_venta] = v.[id_venta]
	), 0)
	FROM [dbo].[Venta] v
	WHERE v.[id_venta] IN (
		SELECT DISTINCT [id_venta] FROM INSERTED
		UNION ALL
		SELECT DISTINCT [id_venta] FROM DELETED
	);
END;
GO

/****** Trigger 7: Prevenir eliminación de categorías que tienen artículos ******/
CREATE TRIGGER [dbo].[tr_PrevenirEliminarCategoria]
ON [dbo].[Categoria]
INSTEAD OF DELETE
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Verificar si la categoría tiene artículos
	IF EXISTS (
		SELECT 1
		FROM [dbo].[Articulo] a
		WHERE a.[id_categoria] IN (SELECT [id_categoria] FROM DELETED)
	)
	BEGIN
		RAISERROR('Error: No se puede eliminar una categoría que contiene artículos.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END;
	
	-- Si no hay artículos, proceder con la eliminación
	DELETE FROM [dbo].[Categoria]
	WHERE [id_categoria] IN (SELECT [id_categoria] FROM DELETED);
END;
GO

/****** Trigger 8: Prevenir eliminación de personas que tienen ventas ******/
CREATE TRIGGER [dbo].[tr_PrevenirEliminarPersona]
ON [dbo].[Persona]
INSTEAD OF DELETE
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Verificar si la persona tiene ventas
	IF EXISTS (
		SELECT 1
		FROM [dbo].[Venta] v
		WHERE v.[id_persona] IN (SELECT [id_persona] FROM DELETED)
	)
	BEGIN
		RAISERROR('Error: No se puede eliminar una persona que tiene ventas registradas.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END;
	
	-- Si no hay ventas, proceder con la eliminación
	DELETE FROM [dbo].[Persona]
	WHERE [id_persona] IN (SELECT [id_persona] FROM DELETED);
END;
GO

/****** Trigger 9: Auditoría de cambios en contraseña de usuarios ******/
-- Primero, crear tabla de auditoría (si no existe)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AuditoriaPersona')
BEGIN
	CREATE TABLE [dbo].[AuditoriaPersona](
		[id_auditoria] [int] IDENTITY(1,1) NOT NULL,
		[id_persona] [int] NOT NULL,
		[usuario] [nvarchar](50) NOT NULL,
		[campo_modificado] [nvarchar](50) NOT NULL,
		[valor_anterior] [nvarchar](255) NULL,
		[valor_nuevo] [nvarchar](255) NULL,
		[fecha_cambio] [datetime] NOT NULL DEFAULT GETDATE(),
		PRIMARY KEY CLUSTERED ([id_auditoria] ASC)
	);
END;
GO

CREATE TRIGGER [dbo].[tr_AuditarCambiosPersona]
ON [dbo].[Persona]
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Registrar cambios en contraseña
	IF UPDATE([contrasena])
	BEGIN
		INSERT INTO [dbo].[AuditoriaPersona] ([id_persona], [usuario], [campo_modificado], [valor_anterior], [valor_nuevo], [fecha_cambio])
		SELECT 
			i.[id_persona], 
			i.[usuario], 
			'contrasena',
			'***OCULTO***',
			'***OCULTO***',
			GETDATE()
		FROM INSERTED i
		INNER JOIN DELETED d ON i.[id_persona] = d.[id_persona]
		WHERE i.[contrasena] <> d.[contrasena];
	END;
	
	-- Registrar cambios en usuario
	IF UPDATE([usuario])
	BEGIN
		INSERT INTO [dbo].[AuditoriaPersona] ([id_persona], [usuario], [campo_modificado], [valor_anterior], [valor_nuevo], [fecha_cambio])
		SELECT 
			i.[id_persona], 
			i.[usuario], 
			'usuario',
			d.[usuario],
			i.[usuario],
			GETDATE()
		FROM INSERTED i
		INNER JOIN DELETED d ON i.[id_persona] = d.[id_persona]
		WHERE i.[usuario] <> d.[usuario];
	END;
	
	-- Registrar cambios en dirección
	IF UPDATE([direccion])
	BEGIN
		INSERT INTO [dbo].[AuditoriaPersona] ([id_persona], [usuario], [campo_modificado], [valor_anterior], [valor_nuevo], [fecha_cambio])
		SELECT 
			i.[id_persona], 
			i.[usuario], 
			'direccion',
			d.[direccion],
			i.[direccion],
			GETDATE()
		FROM INSERTED i
		INNER JOIN DELETED d ON i.[id_persona] = d.[id_persona]
		WHERE ISNULL(i.[direccion], '') <> ISNULL(d.[direccion], '');
	END;
END;
GO

/****** Trigger 10: Prevenir stock negativo ******/
CREATE TRIGGER [dbo].[tr_PrevenirStockNegativo]
ON [dbo].[Articulo]
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Verificar si el stock quedó negativo
	IF EXISTS (
		SELECT 1
		FROM INSERTED
		WHERE [stock] < 0
	)
	BEGIN
		RAISERROR('Error: El stock no puede ser negativo.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
	END;
END;
GO

