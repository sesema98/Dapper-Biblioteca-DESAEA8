using Biblioteca.Web.Models;
using Biblioteca.Web.Repositorios;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace Biblioteca.Web.Controllers;

public class LibrosController : Controller
{
    private readonly ILibroRepositorio _repositorio;
    public LibrosController(ILibroRepositorio repositorio) => _repositorio = repositorio;

    public async Task<IActionResult> Index(string? titulo)
    {
        ViewData["TituloBuscado"] = titulo;
        return View(await _repositorio.ListarAsync(titulo));
    }

    public async Task<IActionResult> Details(int id)
    {
        var libro = await _repositorio.ObtenerPorIdAsync(id);
        return libro is null ? NotFound() : View(libro);
    }

    public async Task<IActionResult> Create()
    {
        await CargarAutoresAsync();
        return View();
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(Libro libro)
    {
        if (!ModelState.IsValid)
        {
            await CargarAutoresAsync(libro.AutorId);
            return View(libro);
        }

        await _repositorio.InsertarAsync(libro);
        TempData["Mensaje"] = "Libro registrado correctamente.";
        return RedirectToAction(nameof(Index));
    }

    public async Task<IActionResult> Edit(int id)
    {
        var libro = await _repositorio.ObtenerPorIdAsync(id);
        if (libro is null) return NotFound();
        await CargarAutoresAsync(libro.AutorId);
        return View(libro);
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, Libro libro)
    {
        if (id != libro.LibroId) return BadRequest();
        if (!ModelState.IsValid)
        {
            await CargarAutoresAsync(libro.AutorId);
            return View(libro);
        }

        await _repositorio.ActualizarAsync(libro);
        TempData["Mensaje"] = "Libro actualizado correctamente.";
        return RedirectToAction(nameof(Index));
    }

    public async Task<IActionResult> Delete(int id)
    {
        var libro = await _repositorio.ObtenerPorIdAsync(id);
        return libro is null ? NotFound() : View(libro);
    }

    [HttpPost, ActionName("Delete"), ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteConfirmed(int id)
    {
        await _repositorio.EliminarAsync(id);
        TempData["Mensaje"] = "Libro eliminado de forma lógica.";
        return RedirectToAction(nameof(Index));
    }

    private async Task CargarAutoresAsync(int? seleccionado = null)
    {
        ViewData["Autores"] = new SelectList(await _repositorio.ListarAutoresAsync(),
            nameof(Autor.AutorId), nameof(Autor.Nombre), seleccionado);
    }
}
