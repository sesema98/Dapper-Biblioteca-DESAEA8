using System.Data;
using Biblioteca.Web.Models;
using Dapper;
using Microsoft.Data.SqlClient;

namespace Biblioteca.Web.Repositorios;

public class LibroRepositorio : ILibroRepositorio
{
    private readonly string _connectionString;

    public LibroRepositorio(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("BibliotecaDB")
            ?? throw new InvalidOperationException("No se configuró la conexión BibliotecaDB.");
    }

    public async Task<IEnumerable<Libro>> ListarAsync(string? titulo)
    {
        using var connection = new SqlConnection(_connectionString);
        var procedimiento = string.IsNullOrWhiteSpace(titulo)
            ? "usp_Libros_ListarActivos"
            : "usp_Libros_BuscarPorTitulo";
        var parametros = string.IsNullOrWhiteSpace(titulo) ? null : new { Titulo = titulo.Trim() };
        return await connection.QueryAsync<Libro>(procedimiento, parametros,
            commandType: CommandType.StoredProcedure);
    }

    public async Task<Libro?> ObtenerPorIdAsync(int libroId)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryFirstOrDefaultAsync<Libro>("usp_Libros_ObtenerPorId",
            new { LibroId = libroId }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<Autor>> ListarAutoresAsync()
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<Autor>("usp_Autores_ListarActivos",
            commandType: CommandType.StoredProcedure);
    }

    public async Task InsertarAsync(Libro libro)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.ExecuteAsync("usp_Libros_Insertar",
            new { libro.Titulo, libro.ISBN, libro.AutorId, libro.Ejemplares },
            commandType: CommandType.StoredProcedure);
    }

    public async Task ActualizarAsync(Libro libro)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.ExecuteAsync("usp_Libros_Actualizar",
            new { libro.LibroId, libro.Titulo, libro.ISBN, libro.AutorId, libro.Ejemplares },
            commandType: CommandType.StoredProcedure);
    }

    public async Task EliminarAsync(int libroId)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.ExecuteAsync("usp_Libros_Eliminar",
            new { LibroId = libroId }, commandType: CommandType.StoredProcedure);
    }
}
