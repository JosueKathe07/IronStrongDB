/* 01_ddl.sql - Tablas, PK, FK y Restricciones */
USE IronStrongFitness;
GO

-- Limpieza si re-ejecutas
IF OBJECT_ID('dbo.LogPagosEliminados','U') IS NOT NULL DROP TABLE dbo.LogPagosEliminados;
IF OBJECT_ID('dbo.Asistencias','U') IS NOT NULL DROP TABLE dbo.Asistencias;
IF OBJECT_ID('dbo.Pagos','U') IS NOT NULL DROP TABLE dbo.Pagos;
IF OBJECT_ID('dbo.Clases','U') IS NOT NULL DROP TABLE dbo.Clases;
IF OBJECT_ID('dbo.Entrenadores','U') IS NOT NULL DROP TABLE dbo.Entrenadores;
IF OBJECT_ID('dbo.Contratos','U') IS NOT NULL DROP TABLE dbo.Contratos;
IF OBJECT_ID('dbo.Miembros','U') IS NOT NULL DROP TABLE dbo.Miembros;
IF OBJECT_ID('dbo.Membresias','U') IS NOT NULL DROP TABLE dbo.Membresias;
GO

CREATE TABLE dbo.Membresias (
    IdMembresia   INT IDENTITY(1,1) PRIMARY KEY,
    Nombre        VARCHAR(20) NOT NULL UNIQUE,         -- Mensual, Anual, VIP, etc.
    Costo         DECIMAL(10,2) NOT NULL CHECK (Costo > 0),
    DuracionDias  INT NOT NULL CHECK (DuracionDias > 0)
);
GO

CREATE TABLE dbo.Miembros (
    IdMiembro        INT IDENTITY(1,1) PRIMARY KEY,
    Nombre           NVARCHAR(120) NOT NULL,
    FechaNacimiento  DATE NOT NULL,
    Email            VARCHAR(150) NOT NULL UNIQUE,
    Estado           VARCHAR(10) NOT NULL CHECK (Estado IN ('Activo','Inactivo'))
);
GO

CREATE TABLE dbo.Contratos (
    IdContrato    INT IDENTITY(1,1) PRIMARY KEY,
    IdMiembro     INT NOT NULL,
    IdMembresia   INT NOT NULL,
    FechaInicio   DATE NOT NULL,
    FechaFin      DATE NOT NULL,
    CONSTRAINT FK_Contratos_Miembros  FOREIGN KEY (IdMiembro)   REFERENCES dbo.Miembros(IdMiembro),
    CONSTRAINT FK_Contratos_Membresias FOREIGN KEY (IdMembresia) REFERENCES dbo.Membresias(IdMembresia),
    CONSTRAINT CK_Contratos_Fechas CHECK (FechaFin > FechaInicio)
);
GO

CREATE TABLE dbo.Entrenadores (
    IdEntrenador  INT IDENTITY(1,1) PRIMARY KEY,
    Nombre        NVARCHAR(120) NOT NULL,
    Especialidad  NVARCHAR(80) NOT NULL
);
GO

CREATE TABLE dbo.Clases (
    IdClase       INT IDENTITY(1,1) PRIMARY KEY,
    NombreClase   NVARCHAR(120) NOT NULL,
    IdEntrenador  INT NOT NULL,
    Horario       DATETIME2(0) NOT NULL,
    CupoMaximo    INT NOT NULL CHECK (CupoMaximo > 0),
    CONSTRAINT FK_Clases_Entrenadores FOREIGN KEY (IdEntrenador) REFERENCES dbo.Entrenadores(IdEntrenador)
);
GO

CREATE TABLE dbo.Asistencias (
    IdAsistencia   INT IDENTITY(1,1) PRIMARY KEY,
    IdClase        INT NOT NULL,
    IdMiembro      INT NOT NULL,
    FechaRegistro  DATETIME2(0) NOT NULL DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Asistencias_Clases   FOREIGN KEY (IdClase)   REFERENCES dbo.Clases(IdClase),
    CONSTRAINT FK_Asistencias_Miembros FOREIGN KEY (IdMiembro) REFERENCES dbo.Miembros(IdMiembro),
    CONSTRAINT UQ_Asistencia_Unica UNIQUE (IdClase, IdMiembro, CAST(FechaRegistro AS DATE))
);
GO

CREATE TABLE dbo.Pagos (
    IdPago      INT IDENTITY(1,1) PRIMARY KEY,
    IdContrato  INT NOT NULL,
    Monto       DECIMAL(10,2) NOT NULL CHECK (Monto > 0),
    FechaPago   DATETIME2(0) NOT NULL DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Pagos_Contratos FOREIGN KEY (IdContrato) REFERENCES dbo.Contratos(IdContrato)
);
GO

-- Tabla de auditoría (trigger al borrar pagos)
CREATE TABLE dbo.LogPagosEliminados (
    IdLog        INT IDENTITY(1,1) PRIMARY KEY,
    IdPago       INT NOT NULL,
    IdContrato   INT NOT NULL,
    Monto        DECIMAL(10,2) NOT NULL,
    FechaPago    DATETIME2(0) NOT NULL,
    UsuarioElim  SYSNAME NOT NULL,
    FechaElim    DATETIME2(0) NOT NULL
);
GO

-- Índices útiles
CREATE INDEX IX_Contratos_IdMiembro ON dbo.Contratos(IdMiembro);
CREATE INDEX IX_Asistencias_IdClase ON dbo.Asistencias(IdClase);
CREATE INDEX IX_Pagos_FechaPago ON dbo.Pagos(FechaPago);
GO
