String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'El email no puede estar vacío';
  }

  // Expresión regular básica para email
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Introduce un email válido';
  }

  return null; // válido
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'La contraseña no puede estar vacía';
  }

  // Al menos 8 caracteres
  if (value.length < 8) {
    return 'Debe tener al menos 8 caracteres';
  }

  // Al menos una mayúscula
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Debe contener al menos una letra mayúscula';
  }

  // Al menos un número
  if (!RegExp(r'\d').hasMatch(value)) {
    return 'Debe contener al menos un número';
  }

  return null; // ✅ válida
}
