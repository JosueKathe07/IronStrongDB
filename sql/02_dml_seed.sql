/* 02_dml_seed.sql - Datos de prueba */
USE IronStrongFitness;
GO

-- Membresías (5)
INSERT INTO dbo.Membresias (Nombre, Costo, DuracionDias) VALUES
('Mensual', 35.00, 30),
('Trimestral', 95.00, 90),
('Semestral', 175.00, 180),
('Anual', 300.00, 365),
('VIP', 55.00, 30);
GO

-- Miembros (20)
INSERT INTO dbo.Miembros (Nombre, FechaNacimiento, Email, Estado) VALUES
('Ana Rojas','1998-02-10','ana.rojas@correo.com','Activo'),
('Luis Mora','1995-06-15','luis.mora@correo.com','Activo'),
('María Solís','2001-11-20','maria.solis@correo.com','Activo'),
('Carlos Jiménez','1990-03-01','carlos.jimenez@correo.com','Activo'),
('Sofía Vargas','1999-09-09','sofia.vargas@correo.com','Activo'),
('Diego Herrera','1997-12-30','diego.herrera@correo.com','Activo'),
('Valeria Castro','2000-01-17','valeria.castro@correo.com','Activo'),
('Andrés Fallas','1989-04-22','andres.fallas@correo.com','Activo'),
('Paula León','1996-08-08','paula.leon@correo.com','Activo'),
('Jorge Pérez','1993-10-05','jorge.perez@correo.com','Activo'),
('Camila Brenes','2002-07-12','camila.brenes@correo.com','Activo'),
('Daniela Campos','1994-05-19','daniela.campos@correo.com','Activo'),
('Fernando Soto','1988-02-28','fernando.soto@correo.com','Activo'),
('Natalia Chaves','1992-09-14','natalia.chaves@correo.com','Activo'),
('Kevin Salazar','1999-01-03','kevin.salazar@correo.com','Activo'),
('Isabel Núñez','1991-06-27','isabel.nunez@correo.com','Inactivo'),
('Ricardo Arias','1995-12-11','ricardo.arias@correo.com','Activo'),
('Mónica Calvo','1998-03-23','monica.calvo@correo.com','Activo'),
('Esteban Quesada','2001-05-07','esteban.quesada@correo.com','Activo'),
('Laura Delgado','1997-09-18','laura.delgado@correo.com','Activo');
GO

/* Contratos (20)
   Mezclamos contratos vigentes y vencidos para probar vistas/triggers */
DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

-- Asignación: algunos VIP, algunos otros
INSERT INTO dbo.Contratos (IdMiembro, IdMembresia, FechaInicio, FechaFin) VALUES
(1, 5, DATEADD(DAY,-10,@Hoy), DATEADD(DAY,20,@Hoy)),   -- VIP vigente
(2, 1, DATEADD(DAY,-40,@Hoy), DATEADD(DAY,-10,@Hoy)),  -- vencido
(3, 4, DATEADD(DAY,-30,@Hoy), DATEADD(DAY,335,@Hoy)),  -- anual vigente
(4, 2, DATEADD(DAY,-100,@Hoy), DATEADD(DAY,-10,@Hoy)), -- vencido
(5, 5, DATEADD(DAY,-5,@Hoy), DATEADD(DAY,25,@Hoy)),    -- VIP vigente
(6, 1, DATEADD(DAY,-15,@Hoy), DATEADD(DAY,15,@Hoy)),   -- mensual vigente
(7, 3, DATEADD(DAY,-200,@Hoy), DATEADD(DAY,-20,@Hoy)), -- vencido
(8, 4, DATEADD(DAY,-60,@Hoy), DATEADD(DAY,305,@Hoy)),
(9, 2, DATEADD(DAY,-30,@Hoy), DATEADD(DAY,60,@Hoy)),
(10,5, DATEADD(DAY,-20,@Hoy), DATEADD(DAY,10,@Hoy)),   -- VIP vigente
(11,1, DATEADD(DAY,-45,@Hoy), DATEADD(DAY,-15,@Hoy)),  -- vencido
(12,2, DATEADD(DAY,-10,@Hoy), DATEADD(DAY,80,@Hoy)),
(13,4, DATEADD(DAY,-120,@Hoy), DATEADD(DAY,245,@Hoy)),
(14,3, DATEADD(DAY,-210,@Hoy), DATEADD(DAY,-30,@Hoy)), -- vencido
(15,1, DATEADD(DAY,-5,@Hoy), DATEADD(DAY,25,@Hoy)),
(16,2, DATEADD(DAY,-90,@Hoy), DATEADD(DAY,-1,@Hoy)),   -- vencido (inactivo)
(17,5, DATEADD(DAY,-2,@Hoy), DATEADD(DAY,28,@Hoy)),    -- VIP vigente
(18,1, DATEADD(DAY,-20,@Hoy), DATEADD(DAY,10,@Hoy)),
(19,3, DATEADD(DAY,-30,@Hoy), DATEADD(DAY,150,@Hoy)),
(20,4, DATEADD(DAY,-15,@Hoy), DATEADD(DAY,350,@Hoy));
GO

-- Entrenadores (10)
INSERT INTO dbo.Entrenadores (Nombre, Especialidad) VALUES
('Mario Aguilar','Fuerza'),
('Paola Ríos','Cardio'),
('David Méndez','CrossFit'),
('Andrea Salas','Yoga'),
('José Ramírez','Funcional'),
('Karla Vega','Pilates'),
('Luis Cordero','HIIT'),
('Diana Mora','Spinning'),
('Sergio Paniagua','Boxeo'),
('Gabriela Soto','Movilidad');
GO

-- Clases (15)
DECLARE @Base DATETIME2(0) = DATEADD(DAY, 1, CAST(@Hoy AS DATETIME2(0)));

INSERT INTO dbo.Clases (NombreClase, IdEntrenador, Horario, CupoMaximo) VALUES
('Fuerza Total', 1, DATEADD(HOUR, 6, @Base), 20),
('Cardio Express', 2, DATEADD(HOUR, 7, @Base), 25),
('CrossFit Intro', 3, DATEADD(HOUR, 8, @Base), 18),
('Yoga Flow', 4, DATEADD(HOUR, 9, @Base), 20),
('Funcional Full', 5, DATEADD(HOUR, 10, @Base), 22),
('Pilates Core', 6, DATEADD(HOUR, 11, @Base), 18),
('HIIT Burn', 7, DATEADD(HOUR, 12, @Base), 24),
('Spinning Pro', 8, DATEADD(HOUR, 13, @Base), 30),
('Boxeo Básico', 9, DATEADD(HOUR, 14, @Base), 16),
('Movilidad Activa', 10, DATEADD(HOUR, 15, @Base), 20),
('Fuerza Avanzada', 1, DATEADD(DAY,1,DATEADD(HOUR, 6, @Base)), 20),
('Cardio Power', 2, DATEADD(DAY,1,DATEADD(HOUR, 7, @Base)), 25),
('Yoga Relax', 4, DATEADD(DAY,1,DATEADD(HOUR, 9, @Base)), 20),
('HIIT Extreme', 7, DATEADD(DAY,1,DATEADD(HOUR, 12, @Base)), 24),
('Spinning Night', 8, DATEADD(DAY,1,DATEADD(HOUR, 18, @Base)), 30);
GO

-- Asistencias/inscripciones (30) - algunos miembros sin asistencias para pruebas
-- Nota: el trigger de negocio se creará luego, así aquí insertamos sin bloqueo.
INSERT INTO dbo.Asistencias (IdClase, IdMiembro, FechaRegistro) VALUES
(1,1,SYSDATETIME()), (1,2,SYSDATETIME()), (1,3,SYSDATETIME()),
(2,4,SYSDATETIME()), (2,5,SYSDATETIME()), (2,6,SYSDATETIME()),
(3,7,SYSDATETIME()), (3,8,SYSDATETIME()), (3,9,SYSDATETIME()),
(4,10,SYSDATETIME()), (4,11,SYSDATETIME()), (4,12,SYSDATETIME()),
(5,13,SYSDATETIME()), (5,14,SYSDATETIME()), (5,15,SYSDATETIME()),
(6,16,SYSDATETIME()), (6,17,SYSDATETIME()), (6,18,SYSDATETIME()),
(7,19,SYSDATETIME()), (7,20,SYSDATETIME()), (7,1,SYSDATETIME()),
(8,2,SYSDATETIME()), (8,3,SYSDATETIME()), (8,4,SYSDATETIME()),
(9,5,SYSDATETIME()), (9,6,SYSDATETIME()), (10,7,SYSDATETIME()),
(11,8,SYSDATETIME()), (12,9,SYSDATETIME()), (13,10,SYSDATETIME());
GO

-- Pagos iniciales (para reportes y lógica)
-- Algunos en el último mes y otros antiguos
INSERT INTO dbo.Pagos (IdContrato, Monto, FechaPago) VALUES
(1, 55.00, DATEADD(DAY,-5, SYSDATETIME())),
(3, 300.00, DATEADD(DAY,-20, SYSDATETIME())),
(5, 55.00, DATEADD(DAY,-2, SYSDATETIME())),
(6, 35.00, DATEADD(DAY,-1, SYSDATETIME())),
(8, 300.00, DATEADD(DAY,-40, SYSDATETIME())),
(9, 95.00, DATEADD(DAY,-10, SYSDATETIME())),
(10,55.00, DATEADD(DAY,-15, SYSDATETIME())),
(12,95.00, DATEADD(DAY,-7, SYSDATETIME())),
(13,300.00, DATEADD(DAY,-60, SYSDATETIME())),
(15,35.00, DATEADD(DAY,-3, SYSDATETIME()));
GO
