using Biblioteca.Web.Repositorios;
using Microsoft.AspNetCore.Mvc;

namespace Biblioteca.Web.Controllers;

public class PrestamosController : Controller
{
    private readonly ISocioRepositorio _repositorio;
    public PrestamosController(ISocioRepositorio repositorio) => _repositorio = repositorio;

    public async Task<IActionResult> Reporte(DateTime? desde, DateTime? hasta)
    {
        var fechaHasta = (hasta ?? DateTime.Today).Date;
        var fechaDesde = (desde ?? fechaHasta.AddMonths(-1)).Date;
        if (fechaDesde > fechaHasta)
        {
            ModelState.AddModelError(string.Empty, "La fecha desde no puede ser posterior a la fecha hasta.");
            (fechaDesde, fechaHasta) = (fechaHasta, fechaDesde);
        }

        ViewData["Desde"] = fechaDesde.ToString("yyyy-MM-dd");
        ViewData["Hasta"] = fechaHasta.ToString("yyyy-MM-dd");
        return View(await _repositorio.ReportePrestamosAsync(fechaDesde, fechaHasta));
    }
}
