using System.ComponentModel.DataAnnotations;

namespace Biblioteca.Web.Models;

public class Socio
{
    public int SocioId { get; set; }

    [Required(ErrorMessage = "El DNI es obligatorio.")]
    [StringLength(15, MinimumLength = 8, ErrorMessage = "El DNI debe tener entre 8 y 15 caracteres.")]
    public string DNI { get; set; } = string.Empty;

    [Required(ErrorMessage = "El nombre es obligatorio.")]
    [StringLength(140)]
    public string Nombre { get; set; } = string.Empty;

    [Required(ErrorMessage = "El correo es obligatorio.")]
    [StringLength(180)]
    [EmailAddress(ErrorMessage = "Ingrese un correo válido.")]
    [DataType(DataType.EmailAddress)]
    public string Email { get; set; } = string.Empty;

    public bool Activo { get; set; }
}
