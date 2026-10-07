# Dapper Biblioteca DESAEA8

Aplicación ASP.NET Core MVC desarrollada para el laboratorio de la semana 08 de Desarrollo de Aplicaciones Empresariales Avanzadas. Administra libros y socios y permite consultar préstamos por intervalo de fechas mediante Dapper y procedimientos almacenados de SQL Server.

La solución reutiliza la estructura y los datos de `BibliotecaDB` del laboratorio 07. Todo el código web se encuentra en un único proyecto llamado `Biblioteca.Web`, como solicita el enunciado.

## Tecnologías

- .NET 10 y ASP.NET Core MVC
- Razor Views
- Dapper
- Microsoft.Data.SqlClient
- SQL Server 2022
- Docker Desktop para ejecutar SQL Server en macOS
- Bootstrap 5

## Por qué se utiliza Docker en macOS

SQL Server y SQL Server LocalDB no se ejecutan de forma nativa en macOS. El laboratorio 07 utilizaba `(localdb)\MSSQLLocalDB`, una instancia disponible únicamente en Windows. Para reutilizar `BibliotecaDB` desde una Mac se ejecuta SQL Server 2022 dentro de un contenedor de Docker.

Docker no cambia la arquitectura solicitada por el laboratorio. Solamente proporciona el servidor de base de datos local. La aplicación continúa conectándose a SQL Server con `Microsoft.Data.SqlClient`, y los repositorios ejecutan procedimientos almacenados mediante Dapper.

En Windows se puede prescindir de Docker y utilizar LocalDB o una instancia local de SQL Server, cambiando la cadena de conexión en `Biblioteca.Web/appsettings.json`.

## Requisitos en macOS

1. [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0).
2. [Docker Desktop](https://www.docker.com/products/docker-desktop/).
3. Git.

Para confirmar la instalación de .NET:

```bash
dotnet --version
dotnet --list-sdks
```

Para confirmar que Docker Desktop está abierto y funcionando:

```bash
docker info
```

## Ejecución en macOS

La primera ejecución tarda más porque Docker debe descargar la imagen de SQL Server, de aproximadamente 600 MB comprimida y varios GB una vez instalada. El tiempo depende de la conexión y normalmente ocurre una sola vez. En las siguientes ejecuciones Docker reutiliza la imagen y el volumen existentes, por lo que el inicio suele tardar solamente unos segundos.

El equipo debe tener al menos 10 GB libres para que Docker pueda descargar, descomprimir y ejecutar SQL Server sin errores.

### 1. Abrir Docker Desktop

Inicia Docker Desktop y espera hasta que el motor de Docker esté listo. Si no está abierto, `docker compose` mostrará un error indicando que no puede conectarse al Docker daemon.

### 2. Entrar en el repositorio

```bash
cd ~/Documents/DEAEA8
```

### 3. Restaurar las dependencias

```bash
dotnet restore
```

### 4. Crear y ejecutar SQL Server

```bash
docker compose up -d
```

En la primera ejecución Docker descarga la imagen de SQL Server, por lo que puede tardar varios minutos. El servicio `db` mantiene SQL Server en ejecución y `db-init` ejecuta automáticamente `01-crear-base.sql`.

El script crea `BibliotecaDB`, sus tablas, los datos de prueba y los procedimientos almacenados del laboratorio 08. Puede comprobarse con:

```bash
docker compose logs db-init
docker compose ps
```

El contenedor `biblioteca-db` debe aparecer como `healthy`. `biblioteca-db-init` puede aparecer como `Exited (0)` porque su única función es ejecutar el script y finalizar.

### 5. Ejecutar la aplicación web

```bash
dotnet run --project Biblioteca.Web --launch-profile http
```

Después abre [http://localhost:5231](http://localhost:5231). Para detener la aplicación presiona `Ctrl+C`.

## Ejecución en Windows

En Windows no es obligatorio usar Docker. Se puede ejecutar `BibliotecaDB` con SQL Server LocalDB, SQL Server Express o una instalación completa de SQL Server.

### 1. Instalar los requisitos

- [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0).
- [SQL Server Express](https://www.microsoft.com/sql-server/sql-server-downloads) con LocalDB.
- [SQL Server Management Studio](https://learn.microsoft.com/sql/ssms/install/install) para ejecutar el script cómodamente.
- Git.

### 2. Clonar el repositorio

```powershell
git clone https://github.com/sesema98/Dapper-Biblioteca-DESAEA8.git
cd Dapper-Biblioteca-DESAEA8
```

### 3. Crear la base de datos

Abre SQL Server Management Studio y conéctate a:

```text
(localdb)\MSSQLLocalDB
```

Después abre `01-crear-base.sql` y selecciona **Ejecutar**. El script crea `BibliotecaDB`, las tablas, los datos de prueba y todos los procedimientos almacenados.

### 4. Configurar la conexión de Windows

En `Biblioteca.Web/appsettings.json`, reemplaza la cadena `BibliotecaDB` por:

```json
"BibliotecaDB": "Server=(localdb)\\MSSQLLocalDB;Database=BibliotecaDB;Integrated Security=True;TrustServerCertificate=True"
```

Si se utiliza SQL Server Express en lugar de LocalDB, el servidor normalmente será `localhost\\SQLEXPRESS`. La cadena debe ajustarse al nombre de la instancia instalada.

### 5. Restaurar y ejecutar

```powershell
dotnet restore
dotnet run --project Biblioteca.Web --launch-profile http
```

Después abre [http://localhost:5231](http://localhost:5231).

## Reproducción rápida después de la primera instalación

En macOS, cuando la imagen y la base ya existen:

```bash
cd ~/Documents/DEAEA8
docker compose up -d
dotnet run --project Biblioteca.Web --launch-profile http
```

En Windows con LocalDB, solo es necesario entrar en el repositorio y ejecutar:

```powershell
dotnet run --project Biblioteca.Web --launch-profile http
```

No es necesario volver a ejecutar el script SQL en cada inicio. Solo debe repetirse si se quiere recrear la base de datos o si se agregaron procedimientos almacenados nuevos.

## Configuración de la base de datos

Docker publica SQL Server en `localhost:1433` con estos datos:

| Dato | Valor |
| --- | --- |
| Servidor | `localhost,1433` |
| Base de datos | `BibliotecaDB` |
| Usuario | `sa` |
| Contraseña | `BibliotecaDemo_2026` |

La cadena de conexión se encuentra en `Biblioteca.Web/appsettings.json` y se obtiene mediante `IConfiguration`; no está escrita directamente en los repositorios ni en los controladores.

## Comandos útiles de Docker

Ver los contenedores del proyecto:

```bash
docker compose ps
```

Consultar los registros de SQL Server y del inicializador:

```bash
docker compose logs db
docker compose logs db-init
```

Detener los contenedores conservando la base de datos:

```bash
docker compose down
```

Eliminar los contenedores y el volumen para recrear la base desde cero:

```bash
docker compose down -v
docker compose up -d
```

El comando con `-v` elimina los datos locales de la base y debe usarse solamente cuando se quiera reiniciar completamente el entorno.

## Funcionalidades

- Listado de libros activos con el nombre del autor.
- Búsqueda de libros por título.
- Detalle, creación, edición y eliminación lógica de libros.
- Lista desplegable de autores activos.
- Listado y creación de socios.
- Validación del DNI duplicado mediante `ModelState.AddModelError`.
- Reporte de préstamos por intervalo de fechas.
- Mensajes de confirmación con `TempData` y patrón Post/Redirect/Get.
- Vista parcial `_LibroRow` reutilizada en el listado de libros.
- Acceso asíncrono a datos con `async` y `await`.

## Estructura

- `01-crear-base.sql`: tablas, datos de prueba y procedimientos almacenados.
- `docker-compose.yml`: SQL Server y ejecución automática del script.
- `Biblioteca.Web/Models`: modelos y validaciones DataAnnotations.
- `Biblioteca.Web/Repositorios`: acceso asíncrono a SQL Server con Dapper.
- `Biblioteca.Web/Controllers`: acciones MVC, validaciones y redirecciones.
- `Biblioteca.Web/Views`: vistas Razor fuertemente tipadas y vista parcial de libros.
- `Biblioteca.Web/appsettings.json`: cadena de conexión.

## Recorrido de una petición

En `GET /Libros?titulo=amor`, el enrutamiento convencional ejecuta `LibrosController.Index`. El controlador recibe el texto de búsqueda y llama de forma asíncrona a `LibroRepositorio.ListarAsync`. El repositorio abre la conexión y ejecuta `usp_Libros_BuscarPorTitulo` con Dapper y `CommandType.StoredProcedure`.

El procedimiento consulta los libros activos y sus autores mediante `INNER JOIN`. El resultado regresa al controlador y `Views/Libros/Index.cshtml` recibe un `IEnumerable<Libro>` como modelo. Finalmente, la vista reutiliza `_LibroRow.cshtml` para representar cada fila.

El listado se envía mediante el modelo porque es el contenido principal y fuertemente tipado. El término de búsqueda se conserva con `ViewData["TituloBuscado"]` por ser información auxiliar de la interfaz. Después de crear, editar o eliminar se utiliza `TempData["Mensaje"]`, ya que el mensaje debe sobrevivir a la redirección del patrón Post/Redirect/Get.

## Observaciones y conclusiones

Los controladores no contienen SQL ni crean conexiones. Todas las operaciones de acceso a datos utilizan `async/await`. La eliminación de libros es lógica mediante `Activo = 0`; no se ejecuta `DELETE`. La separación entre controladores y repositorios facilita el mantenimiento y permite que las vistas se concentren en la presentación.

En macOS, Docker permite reproducir el mismo comportamiento de SQL Server requerido por el laboratorio sin depender de LocalDB. El código de la aplicación no depende de Docker: puede conectarse a cualquier instancia compatible modificando únicamente la cadena de conexión.
