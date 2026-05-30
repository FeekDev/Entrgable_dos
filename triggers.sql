USE [STOCKMASTERbdv4]
GO

/****** Trigger 1: Actualizar stock cuando se inserta un detalle de factura ******/
/* Eliminado
CREATE TRIGGER [dbo].[tr_ActualizarStockInsert]
ON [dbo].[DetalleFactura]
AFTER INSERT
AS
BEGIN
	SET NOCOUNT OFF;
	
	-- Actualizar el stock del artículo restando la cantidad vendida
	UPDATE [dbo].[Articulo]
	SET [stock] = [stock] - INSERTED.[cantidad]
	FROM INSERTED
	WHERE [dbo].[Articulo].[codigo] = INSERTED.[codigo_articulo];
END;
GO */

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

-- Revisar
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
GO------*

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
/* Eliminado
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
*/


/****** Trigger 6: Prevenir eliminación de categorías que tienen artículos ******/
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
