/* 03_queries_reportes.sql - Requerimientos del gerente */
USE IronStrongFitness;
GO

-- 1) Listar miembros con membresía VIP
SELECT DISTINCT
    m.IdMiembro, m.Nombre, m.Email, mb.Nombre AS Membresia
FROM dbo.Miembros m
INNER JOIN dbo.Contratos c ON c.IdMiembro = m.IdMiembro
INNER JOIN dbo.Membresias mb ON mb.IdMembresia = c.IdMembresia
WHERE mb.Nombre = 'VIP';

-- 2) Calendario de clases ordenado por horario y nombre entrenador
SELECT
    c.IdClase, c.NombreClase, e.Nombre AS Entrenador, c.Horario, c.CupoMaximo
FROM dbo.Clases c
INNER JOIN dbo.Entrenadores e ON e.IdEntrenador = c.IdEntrenador
ORDER BY c.Horario ASC, e.Nombre ASC;

-- 3) Miembros que nunca han asistido a una clase (LEFT JOIN)
SELECT
    m.IdMiembro, m.Nombre, m.Email
FROM dbo.Miembros m
LEFT JOIN dbo.Asistencias a ON a.IdMiembro = m.IdMiembro
WHERE a.IdAsistencia IS NULL
ORDER BY m.Nombre;

-- 4) Pagos realizados en el último mes
SELECT
    p.IdPago, p.IdContrato, p.Monto, p.FechaPago
FROM dbo.Pagos p
WHERE p.FechaPago >= DATEADD(MONTH, -1, SYSDATETIME())
ORDER BY p.FechaPago DESC;
GO
