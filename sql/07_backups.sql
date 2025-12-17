/* 07_backups.sql - Backup de la BD (ajusta la ruta) */
USE master;
GO

-- IMPORTANTE:
-- 1) Crea la carpeta C:\Backups\ en tu PC
-- 2) Si da error de permisos, abre SSMS como Administrador
-- 3) Puedes cambiar la ruta a una que SQL Server tenga permiso

BACKUP DATABASE IronStrongFitness
TO DISK = 'C:\Backups\IronStrongFitness.bak'
WITH INIT, COMPRESSION;
GO
