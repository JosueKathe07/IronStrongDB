/* 06_objetos_avanzados.sql - SP, Funciones, Vistas, Triggers, CTE */
USE IronStrongFitness;
GO

-- Limpieza (si re-ejecutas)
IF OBJECT_ID('dbo.tr_Pagos_AuditoriaDelete','TR') IS NOT NULL DROP TRIGGER dbo.tr_Pagos_AuditoriaDelete;
IF OBJECT_ID('dbo.tr_Asistencias_ValidarMembresiaVigente','TR') IS NOT NULL DROP TRIGGER dbo.tr_Asistencias_ValidarMembresiaVigente;
GO

IF OBJECT_ID('dbo.vw_OcupacionGimnasio','V') IS NOT NULL DROP VIEW dbo.vw_OcupacionGimnasio;
IF OBJECT_ID('dbo.vw_Deudores','V') IS NOT NULL DROP VIEW dbo.vw_Deudores;
GO

IF OBJECT_ID('dbo.fn_EstadoMembresia','FN') IS NOT NULL DROP FUNCTION dbo.fn_EstadoMembresia;
IF OBJECT_ID('dbo.fn_EdadPromedioClase','FN') IS NOT NULL DROP FUNCTION dbo.fn_EdadPromedioClase;
GO

IF OBJECT_ID('dbo.sp_InscribirClase','P') IS NOT NULL DROP PROCEDURE dbo.sp_InscribirClase;
IF OBJECT_ID('dbo.sp_ReporteVentasEntrenador','P') IS NOT NULL DROP PROCEDURE dbo.sp_ReporteVentasEntrenador;
GO

/* ====== FUNCIONES ====== */
CREATE FUNCTION dbo.fn_EstadoMembresia (@FechaFin DATE)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN (CASE WHEN @FechaFin >= CAST(GETDATE() AS DATE) THEN 'VIGENTE' ELSE 'VENCIDA' END);
END
GO

CREATE FUNCTION dbo.fn_EdadPromedioClase (@IdClase INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Prom DECIMAL(5,2);

    SELECT @Prom = AVG(CAST(DATEDIFF(YEAR, m.FechaNacimiento, CAST(GETDATE() AS DATE)) AS DECIMAL(5,2)))
    FROM dbo.Asistencias a
    INNER JOIN dbo.Miembros m ON m.IdMiembro = a.IdMiembro
    WHERE a.IdClase = @IdClase;

    RETURN ISNULL(@Prom, 0);
END
GO

/* ====== VISTAS ====== */
CREATE VIEW dbo.vw_OcupacionGimnasio
AS
SELECT
    c.IdClase,
    c.NombreClase,
    e.Nombre AS Entrenador,
    c.CupoMaximo,
    COUNT(a.IdAsistencia) AS Inscritos
FROM dbo.Clases c
INNER JOIN dbo.Entrenadores e ON e.IdEntrenador = c.IdEntrenador
LEFT JOIN dbo.Asistencias a ON a.IdClase = c.IdClase
GROUP BY c.IdClase, c.NombreClase, e.Nombre, c.CupoMaximo;
GO

CREATE VIEW dbo.vw_Deudores
AS
SELECT
    m.IdMiembro,
    m.Nombre,
    m.Email,
    c.IdContrato,
    c.FechaFin,
    dbo.fn_EstadoMembresia(c.FechaFin) AS EstadoMembresia
FROM dbo.Contratos c
INNER JOIN dbo.Miembros m ON m.IdMiembro = c.IdMiembro
WHERE c.FechaFin < CAST(GETDATE() AS DATE)
  AND NOT EXISTS (
        SELECT 1
        FROM dbo.Pagos p
        WHERE p.IdContrato = c.IdContrato
          AND CAST(p.FechaPago AS DATE) >= c.FechaFin
  );
GO

/* ====== PROCEDIMIENTOS ALMACENADOS ====== */
CREATE PROCEDURE dbo.sp_InscribirClase
    @IdMiembro INT,
    @IdClase INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM dbo.Miembros WHERE IdMiembro = @IdMiembro)
        THROW 50001, 'El miembro no existe.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Clases WHERE IdClase = @IdClase)
        THROW 50002, 'La clase no existe.', 1;

    DECLARE @CupoMax INT, @Inscritos INT;

    SELECT @CupoMax = CupoMaximo
    FROM dbo.Clases
    WHERE IdClase = @IdClase;

    SELECT @Inscritos = COUNT(1)
    FROM dbo.Asistencias
    WHERE IdClase = @IdClase
      AND CAST(FechaRegistro AS DATE) = CAST(GETDATE() AS DATE);

    IF (@Inscritos >= @CupoMax)
        THROW 50003, 'No hay cupo disponible para esta clase.', 1;

    -- Insertar asistencia (trigger validará vigencia)
    INSERT INTO dbo.Asistencias (IdClase, IdMiembro, FechaRegistro)
    VALUES (@IdClase, @IdMiembro, SYSDATETIME());
END
GO

/* Nota de negocio para el reporte:
   Como no existe una tabla de "venta por clase", el ingreso del entrenador se estima
   como la suma de pagos de contratos de miembros que asistieron a AL MENOS una clase
   impartida por ese entrenador (evita contar pagos de miembros que nunca asistieron a sus clases).
*/
CREATE PROCEDURE dbo.sp_ReporteVentasEntrenador
    @IdEntrenador INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Entrenadores WHERE IdEntrenador = @IdEntrenador)
        THROW 50004, 'El entrenador no existe.', 1;

    ;WITH MiembrosDelEntrenador AS (
        SELECT DISTINCT a.IdMiembro
        FROM dbo.Clases c
        INNER JOIN dbo.Asistencias a ON a.IdClase = c.IdClase
        WHERE c.IdEntrenador = @IdEntrenador
    )
    SELECT
        e.IdEntrenador,
        e.Nombre AS Entrenador,
        SUM(p.Monto) AS TotalGenerado
    FROM dbo.Entrenadores e
    INNER JOIN dbo.Contratos ct ON 1=1
    INNER JOIN dbo.Pagos p ON p.IdContrato = ct.IdContrato
    INNER JOIN MiembrosDelEntrenador mte ON mte.IdMiembro = ct.IdMiembro
    WHERE e.IdEntrenador = @IdEntrenador
    GROUP BY e.IdEntrenador, e.Nombre;
END
GO

/* ====== TRIGGERS ====== */

-- Auditoría: al borrar pagos
CREATE TRIGGER dbo.tr_Pagos_AuditoriaDelete
ON dbo.Pagos
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.LogPagosEliminados (IdPago, IdContrato, Monto, FechaPago, UsuarioElim, FechaElim)
    SELECT
        d.IdPago,
        d.IdContrato,
        d.Monto,
        d.FechaPago,
        SUSER_SNAME(),
        SYSDATETIME()
    FROM deleted d;
END
GO

-- Negocio: al insertar asistencia, el miembro debe tener contrato vigente
CREATE TRIGGER dbo.tr_Asistencias_ValidarMembresiaVigente
ON dbo.Asistencias
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Bloquea si no existe contrato vigente del miembro
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE NOT EXISTS (
            SELECT 1
            FROM dbo.Contratos c
            WHERE c.IdMiembro = i.IdMiembro
              AND c.FechaFin >= CAST(GETDATE() AS DATE)
        )
    )
    BEGIN
        THROW 50005, 'No se puede registrar asistencia: el miembro no tiene membresía vigente.', 1;
    END

    -- Si es válido, inserta
    INSERT INTO dbo.Asistencias (IdClase, IdMiembro, FechaRegistro)
    SELECT IdClase, IdMiembro, ISNULL(FechaRegistro, SYSDATETIME())
    FROM inserted;
END
GO

/* ====== CTE Top 3 clases más populares ====== */
-- (Esto lo ejecutarás como consulta; también puedes dejarlo aquí como evidencia)
;WITH Popularidad AS (
    SELECT
        c.IdClase,
        c.NombreClase,
        COUNT(a.IdAsistencia) AS TotalAsistencias
    FROM dbo.Clases c
    LEFT JOIN dbo.Asistencias a ON a.IdClase = c.IdClase
    GROUP BY c.IdClase, c.NombreClase
),
Top3 AS (
    SELECT TOP (3) *
    FROM Popularidad
    ORDER BY TotalAsistencias DESC, NombreClase ASC
)
SELECT * FROM Top3;
GO
