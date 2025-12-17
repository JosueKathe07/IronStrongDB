/* 04_set_logic.sql - UNION, INTERSECT, EXCEPT */
USE IronStrongFitness;
GO

-- UNION: correos de Miembros y Entrenadores
SELECT Email AS Correo, 'Miembro' AS Tipo
FROM dbo.Miembros
UNION
SELECT CONCAT(LOWER(REPLACE(Nombre,' ','.')), '@ironstrong.com') AS Correo, 'Entrenador' AS Tipo
FROM dbo.Entrenadores;

-- INTERSECT: miembros con contrato activo Y asistencia esta semana
-- Conjunto A: miembros con contrato vigente
SELECT IdMiembro
FROM dbo.Contratos
WHERE FechaFin >= CAST(GETDATE() AS DATE)
INTERSECT
-- Conjunto B: miembros con asistencia en los últimos 7 días
SELECT DISTINCT IdMiembro
FROM dbo.Asistencias
WHERE FechaRegistro >= DATEADD(DAY, -7, SYSDATETIME());

-- EXCEPT: entrenadores sin clases asignadas
SELECT IdEntrenador
FROM dbo.Entrenadores
EXCEPT
SELECT DISTINCT IdEntrenador
FROM dbo.Clases;
GO
