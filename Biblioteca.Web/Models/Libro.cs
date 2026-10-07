using System.ComponentModel.DataAnnotations;

namespace Biblioteca.Web.Models;

public class Libro
{
    public int LibroId { get; set; }

    [Required(ErrorMessage = "El título es obligatorio.")]
    [StringLength(180, ErrorMessage = "El título admite hasta 180 caracteres.")]
    public string Titulo { get; set; } = string.Empty;

    [Required(ErrorMessage = "El ISBN es obligatorio.")]
    [StringLength(20, ErrorMessage = "El ISBN admite hasta 20 caracteres.")]
    [Display(Name = "ISBN")]
    public string ISBN { get; set; } = string.Empty;

    [Range(1, int.MaxValue, ErrorMessage = "Seleccione un autor.")]
    [Display(Name = "Autor")]
    public int AutorId { get; set; }

    [Range(0, 10000, ErrorMessage = "Los ejemplares deben estar entre 0 y 10000.")]
    public int Ejemplares { get; set; }

    public bool Activo { get; set; }
    public string AutorNombre { get; set; } = string.Empty;
}
