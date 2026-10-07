IF DB_ID(N'BibliotecaDB') IS NULL
    CREATE DATABASE BibliotecaDB;
GO

USE BibliotecaDB;
GO

IF OBJECT_ID(N'dbo.Autores', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Autores (
        AutorId INT IDENTITY(1,1) CONSTRAINT PK_Autores PRIMARY KEY,
        Nombre NVARCHAR(120) NOT NULL,
        Nacionalidad NVARCHAR(80) NOT NULL,
        Activo BIT NOT NULL CONSTRAINT DF_Autores_Activo DEFAULT (1)
    );
END;

IF OBJECT_ID(N'dbo.Libros', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Libros (
        LibroId INT IDENTITY(1,1) CONSTRAINT PK_Libros PRIMARY KEY,
        Titulo NVARCHAR(180) NOT NULL,
        ISBN VARCHAR(20) NOT NULL CONSTRAINT UQ_Libros_ISBN UNIQUE,
        AutorId INT NOT NULL,
        Ejemplares INT NOT NULL CONSTRAINT DF_Libros_Ejemplares DEFAULT (0),
        Activo BIT NOT NULL CONSTRAINT DF_Libros_Activo DEFAULT (1),
        CONSTRAINT FK_Libros_Autores FOREIGN KEY (AutorId) REFERENCES dbo.Autores(AutorId),
        CONSTRAINT CK_Libros_Ejemplares CHECK (Ejemplares >= 0)
    );
END;

IF OBJECT_ID(N'dbo.Socios', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Socios (
        SocioId INT IDENTITY(1,1) CONSTRAINT PK_Socios PRIMARY KEY,
        DNI VARCHAR(15) NOT NULL CONSTRAINT UQ_Socios_DNI UNIQUE,
        Nombre NVARCHAR(140) NOT NULL,
        Email NVARCHAR(180) NOT NULL,
        Activo BIT NOT NULL CONSTRAINT DF_Socios_Activo DEFAULT (1)
    );
END;

IF OBJECT_ID(N'dbo.Prestamos', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Prestamos (
        PrestamoId INT IDENTITY(1,1) CONSTRAINT PK_Prestamos PRIMARY KEY,
        SocioId INT NOT NULL,
        FechaPrestamo DATE NOT NULL,
        FechaLimite DATE NOT NULL,
        Estado NVARCHAR(20) NOT NULL CONSTRAINT DF_Prestamos_Estado DEFAULT (N'Pendiente'),
        CONSTRAINT FK_Prestamos_Socios FOREIGN KEY (SocioId) REFERENCES dbo.Socios(SocioId),
        CONSTRAINT CK_Prestamos_Fechas CHECK (FechaLimite >= FechaPrestamo)
    );
END;

IF OBJECT_ID(N'dbo.DetallePrestamo', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DetallePrestamo (
        PrestamoId INT NOT NULL,
        LibroId INT NOT NULL,
        FechaDevolucion DATE NULL,
        CONSTRAINT PK_DetallePrestamo PRIMARY KEY (PrestamoId, LibroId),
        CONSTRAINT FK_DetallePrestamo_Prestamos FOREIGN KEY (PrestamoId) REFERENCES dbo.Prestamos(PrestamoId),
        CONSTRAINT FK_DetallePrestamo_Libros FOREIGN KEY (LibroId) REFERENCES dbo.Libros(LibroId)
    );
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Libros_ListarActivos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT l.LibroId, l.Titulo, l.ISBN, l.AutorId, l.Ejemplares, l.Activo,
           a.Nombre AS AutorNombre
    FROM dbo.Libros AS l
    INNER JOIN dbo.Autores AS a ON a.AutorId = l.AutorId
    WHERE l.Activo = 1
    ORDER BY l.Titulo;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Libros_BuscarPorTitulo
    @Titulo NVARCHAR(180)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT l.LibroId, l.Titulo, l.ISBN, l.AutorId, l.Ejemplares, l.Activo,
           a.Nombre AS AutorNombre
    FROM dbo.Libros AS l
    INNER JOIN dbo.Autores AS a ON a.AutorId = l.AutorId
    WHERE l.Activo = 1 AND l.Titulo LIKE N'%' + @Titulo + N'%'
    ORDER BY l.Titulo;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Libros_ObtenerPorId
    @LibroId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT l.LibroId, l.Titulo, l.ISBN, l.AutorId, l.Ejemplares, l.Activo,
           a.Nombre AS AutorNombre
    FROM dbo.Libros AS l
    INNER JOIN dbo.Autores AS a ON a.AutorId = l.AutorId
    WHERE l.LibroId = @LibroId AND l.Activo = 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Libros_Insertar
    @Titulo NVARCHAR(180), @ISBN VARCHAR(20), @AutorId INT, @Ejemplares INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT dbo.Libros (Titulo, ISBN, AutorId, Ejemplares)
    VALUES (@Titulo, @ISBN, @AutorId, @Ejemplares);
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Libros_Actualizar
    @LibroId INT, @Titulo NVARCHAR(180), @ISBN VARCHAR(20),
    @AutorId INT, @Ejemplares INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Libros
    SET Titulo = @Titulo, ISBN = @ISBN, AutorId = @AutorId, Ejemplares = @Ejemplares
    WHERE LibroId = @LibroId AND Activo = 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Libros_Eliminar
    @LibroId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Libros SET Activo = 0 WHERE LibroId = @LibroId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Autores_ListarActivos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT AutorId, Nombre
    FROM dbo.Autores
    WHERE Activo = 1
    ORDER BY Nombre;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Socios_ListarActivos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SocioId, DNI, Nombre, Email, Activo
    FROM dbo.Socios
    WHERE Activo = 1
    ORDER BY Nombre;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Socios_ExisteDNI
    @DNI VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(1) FROM dbo.Socios WHERE DNI = @DNI;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Socios_Insertar
    @DNI VARCHAR(15), @Nombre NVARCHAR(140), @Email NVARCHAR(180)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT dbo.Socios (DNI, Nombre, Email) VALUES (@DNI, @Nombre, @Email);
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Prestamos_ReportePorFechas
    @Desde DATE, @Hasta DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.PrestamoId,
           s.Nombre AS Socio,
           STRING_AGG(l.Titulo, N', ') WITHIN GROUP (ORDER BY l.Titulo) AS Libros,
           p.FechaPrestamo,
           p.FechaLimite,
           p.Estado
    FROM dbo.Prestamos AS p
    INNER JOIN dbo.Socios AS s ON s.SocioId = p.SocioId
    INNER JOIN dbo.DetallePrestamo AS d ON d.PrestamoId = p.PrestamoId
    INNER JOIN dbo.Libros AS l ON l.LibroId = d.LibroId
    WHERE p.FechaPrestamo BETWEEN @Desde AND @Hasta
    GROUP BY p.PrestamoId, s.Nombre, p.FechaPrestamo, p.FechaLimite, p.Estado
    ORDER BY p.FechaPrestamo DESC, p.PrestamoId DESC;
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Autores)
BEGIN
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;

    INSERT dbo.Autores (Nombre, Nacionalidad) VALUES
        (N'Gabriel García Márquez', N'Colombiana'),
        (N'Isabel Allende', N'Chilena'),
        (N'Mario Vargas Llosa', N'Peruana'),
        (N'Julio Cortázar', N'Argentina'),
        (N'Jane Austen', N'Británica'),
        (N'George Orwell', N'Británica'),
        (N'Ernest Hemingway', N'Estadounidense'),
        (N'Laura Esquivel', N'Mexicana');

    INSERT dbo.Libros (Titulo, ISBN, AutorId, Ejemplares) VALUES
        (N'Cien años de soledad', '9780307474728', 1, 4),
        (N'El amor en los tiempos del cólera', '9780307389732', 1, 3),
        (N'La casa de los espíritus', '9788401352836', 2, 3),
        (N'Paula', '9788401352898', 2, 2),
        (N'La ciudad y los perros', '9788420471839', 3, 3),
        (N'Conversación en La Catedral', '9788420471846', 3, 2),
        (N'Rayuela', '9788420471860', 4, 3),
        (N'Bestiario', '9788420471877', 4, 2),
        (N'Orgullo y prejuicio', '9780141439518', 5, 4),
        (N'Emma', '9780141439587', 5, 2),
        (N'1984', '9780451524935', 6, 4),
        (N'Rebelión en la granja', '9780451526342', 6, 3),
        (N'El viejo y el mar', '9780684801223', 7, 3),
        (N'Por quién doblan las campanas', '9780684803357', 7, 2),
        (N'Como agua para chocolate', '9780385420174', 8, 3),
        (N'El diario de Tita', '9780385420181', 8, 2),
        (N'Crónica de una muerte anunciada', '9780307387740', 1, 2),
        (N'Inés del alma mía', '9788401337551', 2, 2),
        (N'La tía Julia y el escribidor', '9788420471891', 3, 2),
        (N'La autopista del sur', '9788420471907', 4, 2);

    INSERT dbo.Socios (DNI, Nombre, Email) VALUES
        ('74010001', N'Ana Torres', N'ana.torres@correo.com'),
        ('74010002', N'Luis Mendoza', N'luis.mendoza@correo.com'),
        ('74010003', N'Camila Rojas', N'camila.rojas@correo.com'),
        ('74010004', N'Diego Salazar', N'diego.salazar@correo.com'),
        ('74010005', N'Valeria Castro', N'valeria.castro@correo.com'),
        ('74010006', N'José Paredes', N'jose.paredes@correo.com'),
        ('74010007', N'Lucía Herrera', N'lucia.herrera@correo.com'),
        ('74010008', N'Mateo Flores', N'mateo.flores@correo.com'),
        ('74010009', N'Sofía Vega', N'sofia.vega@correo.com'),
        ('74010010', N'Andrés León', N'andres.leon@correo.com');

    INSERT dbo.Prestamos (SocioId, FechaPrestamo, FechaLimite, Estado) VALUES
        (1, DATEADD(DAY, -3, CAST(GETDATE() AS DATE)), DATEADD(DAY, 11, CAST(GETDATE() AS DATE)), N'Pendiente'),
        (2, DATEADD(DAY, -30, CAST(GETDATE() AS DATE)), DATEADD(DAY, -16, CAST(GETDATE() AS DATE)), N'Devuelto'),
        (3, DATEADD(DAY, -10, CAST(GETDATE() AS DATE)), DATEADD(DAY, 4, CAST(GETDATE() AS DATE)), N'Pendiente'),
        (4, DATEADD(DAY, -24, CAST(GETDATE() AS DATE)), DATEADD(DAY, -10, CAST(GETDATE() AS DATE)), N'Devuelto'),
        (5, DATEADD(DAY, -16, CAST(GETDATE() AS DATE)), DATEADD(DAY, -2, CAST(GETDATE() AS DATE)), N'Devuelto');

    INSERT dbo.DetallePrestamo (PrestamoId, LibroId, FechaDevolucion) VALUES
        (1, 1, NULL), (1, 2, NULL), (1, 3, NULL),
        (2, 4, DATEADD(DAY, -18, CAST(GETDATE() AS DATE))),
        (3, 5, NULL), (3, 6, NULL),
        (4, 7, DATEADD(DAY, -11, CAST(GETDATE() AS DATE))),
        (5, 8, DATEADD(DAY, -3, CAST(GETDATE() AS DATE)));

    UPDATE dbo.Libros SET Ejemplares = Ejemplares - 3 WHERE LibroId IN (1, 2, 3);
    UPDATE dbo.Libros SET Ejemplares = Ejemplares - 2 WHERE LibroId IN (5, 6);

    COMMIT TRANSACTION;
END;
GO
