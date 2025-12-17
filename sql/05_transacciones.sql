/* 05_transacciones.sql - Transacción ACID: Renovación de Membresía */
USE IronStrongFitness;
GO

-- Ejemplo ejecutable: cambia @IdContrato y @MontoPagado para probar COMMIT/ROLLBACK
DECLARE @IdContrato INT = 2;      -- Prueba: contrato vencido
DECLARE @MontoPagado DECIMAL(10,2) = 10.00;  -- Prueba: insuficiente para provocar ROLLBACK
DECLARE @FechaPago DATETIME2(0) = SYSDATETIME();

BEGIN TRY
    BEGIN TRAN;

    DECLARE @CostoMembresia DECIMAL(10,2);
    DECLARE @DuracionDias INT;

    SELECT
        @CostoMembresia = mb.Costo,
        @DuracionDias = mb.DuracionDias
    FROM dbo.Contratos c
    INNER JOIN dbo.Membresias mb ON mb.IdMembresia = c.IdMembresia
    WHERE c.IdContrato = @IdContrato;

    IF @CostoMembresia IS NULL
        THROW 51001, 'Contrato no encontrado para renovación.', 1;

    -- 1) Insertar pago
    INSERT INTO dbo.Pagos (IdContrato, Monto, FechaPago)
    VALUES (@IdContrato, @MontoPagado, @FechaPago);

    -- 2) Validar monto
    IF (@MontoPagado < @CostoMembresia)
    BEGIN
        ROLLBACK;
        THROW 51002, 'Pago insuficiente: se revierte la renovación.', 1;
    END

    -- 3) Actualizar FechaFin: extiende desde HOY si está vencido, o desde FechaFin si aún vigente
    UPDATE dbo.Contratos
    SET FechaFin =
        CASE
            WHEN FechaFin < CAST(GETDATE() AS DATE)
                THEN DATEADD(DAY, @DuracionDias, CAST(GETDATE() AS DATE))
            ELSE DATEADD(DAY, @DuracionDias, FechaFin)
        END
    WHERE IdContrato = @IdContrato;

    COMMIT;

    SELECT 'RENOVACIÓN EXITOSA' AS Resultado, @IdContrato AS IdContrato, @MontoPagado AS MontoPagado, @CostoMembresia AS CostoRequerido;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO
