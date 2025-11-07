// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'NETO';

  @override
  String get loginTitle => 'Inicia sesión';

  @override
  String get registerTitle => 'Registrate';

  @override
  String get password => 'Contraseña';

  @override
  String get repeatpassword => 'Repetir contraseña';

  @override
  String get forgotPassword => 'Olvidé la contaseña';

  @override
  String get sendNewPasswordtittLe => 'Restablecer la contraseña';

  @override
  String get sendNewPasswordMsg =>
      'Introduce la dirección de correo electrónico asociada a la cuenta y te enviaremos un enlace para restablecer la contraseña';

  @override
  String get passwordRuleMinLength => 'Mínimo 8 caracteres';

  @override
  String get passwordRuleMinNumber => 'Mínimo 1 número';

  @override
  String get passwordRuleMinUppercase => 'Mínimo 1 mayúscula';

  @override
  String get passwordRuleMatch => 'Las contraseñas coinciden';

  @override
  String get homeTitle => 'Resumen';

  @override
  String get reportsTitle => 'Informes';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get sectionRecents => 'Movimientos Recientes';

  @override
  String get totalIncome => 'Ingreso Total';

  @override
  String get totalExpense => 'Gasto Total';

  @override
  String get netBalance => 'Balance Neto';

  @override
  String get newTransactionTitle => 'Añadir Movimiento';

  @override
  String get amountLabel => 'Monto';

  @override
  String get descriptionLabel => 'Descripción (Opcional)';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get frequencyLabel => 'Frecuencia';

  @override
  String get buttonSave => 'Guardar';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonSingUp => 'Registrarse';

  @override
  String get buttonSingIn => 'Iniciar sesión';

  @override
  String get buttonResetPwd => 'Restablecer contraseña';

  @override
  String get typeIncome => 'Ingreso';

  @override
  String get typeExpense => 'Gasto';

  @override
  String get freqSingle => 'Único';

  @override
  String get freqMonthly => 'Mensual';

  @override
  String get freqAnnual => 'Anual';

  @override
  String get validationRequired => 'Este campo es obligatorio.';

  @override
  String get errorGeneric => 'Ocurrió un error. Inténtalo de nuevo.';
}
