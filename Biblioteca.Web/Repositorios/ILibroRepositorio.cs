using Biblioteca.Web.Models;

namespace Biblioteca.Web.Repositorios;

public interface ILibroRepositorio
{
    Task<IEnumerable<Libro>> ListarAsync(string? titulo);
    Task<Libro?> ObtenerPorIdAsync(int libroId);
    Task<IEnumerable<Autor>> ListarAutoresAsync();
    Task InsertarAsync(Libro libro);
    Task ActualizarAsync(Libro libro);
    Task EliminarAsync(int libroId);
}
