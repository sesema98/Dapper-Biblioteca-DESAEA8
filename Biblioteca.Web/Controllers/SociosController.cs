using Biblioteca.Web.Models;
using Biblioteca.Web.Repositorios;
using Microsoft.AspNetCore.Mvc;

namespace Biblioteca.Web.Controllers;

public class SociosController : Controller
{
    private readonly ISocioRepositorio _repositorio;
    public SociosController(ISocioRepositorio repositorio) => _repositorio = repositorio;

    public async Task<IActionResult> Index() => View(await _repositorio.ListarAsync());

    public IActionResult Create() => View();

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(Socio socio)
    {
        if (!string.IsNullOrWhiteSpace(socio.DNI) && await _repositorio.ExisteDniAsync(socio.DNI))
            ModelState.AddModelError(nameof(Socio.DNI), "Ya existe un socio con ese DNI.");

        if (!ModelState.IsValid) return View(socio);

        await _repositorio.InsertarAsync(socio);
        TempData["Mensaje"] = "Socio registrado correctamente.";
        return RedirectToAction(nameof(Index));
    }
}
