using System.Data;
using Biblioteca.Web.Models;
using Dapper;
using Microsoft.Data.SqlClient;

namespace Biblioteca.Web.Repositorios;

public class SocioRepositorio : ISocioRepositorio
{
    private readonly string _connectionString;

    public SocioRepositorio(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("BibliotecaDB")
            ?? throw new InvalidOperationException("No se configuró la conexión BibliotecaDB.");
    }

    public async Task<IEnumerable<Socio>> ListarAsync()
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<Socio>("usp_Socios_ListarActivos",
            commandType: CommandType.StoredProcedure);
    }

    public async Task InsertarAsync(Socio socio)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.ExecuteAsync("usp_Socios_Insertar",
            new { socio.DNI, socio.Nombre, socio.Email }, commandType: CommandType.StoredProcedure);
    }

    public async Task<bool> ExisteDniAsync(string dni)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.ExecuteScalarAsync<int>("usp_Socios_ExisteDNI",
            new { DNI = dni }, commandType: CommandType.StoredProcedure) > 0;
    }

    public async Task<IEnumerable<PrestamoReporte>> ReportePrestamosAsync(DateTime desde, DateTime hasta)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<PrestamoReporte>("usp_Prestamos_ReportePorFechas",
            new { Desde = desde.Date, Hasta = hasta.Date }, commandType: CommandType.StoredProcedure);
    }
}
