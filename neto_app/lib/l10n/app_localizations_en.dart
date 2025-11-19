// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'NETO';

  @override
  String get loginTitle => 'Login';

  @override
  String get registerTitle => 'Sing Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get initSession => 'Create Account';

  @override
  String get password => 'Password';

  @override
  String get repeatpassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get sendNewPasswordtittLe => 'Reset Password';

  @override
  String get sendNewPasswordMsg =>
      'Enter the email address associated with your account, and we will send you a link to reset your password';

  @override
  String get passwordRuleMinLength => 'Minimum 8 characters';

  @override
  String get passwordRuleMinNumber => 'Minimum 1 number';

  @override
  String get passwordRuleMinUppercase => 'Minimum 1 uppercase letter';

  @override
  String get passwordRuleMatch => 'Passwords match';

  @override
  String get homeTitle => 'Overview';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionRecents => 'Recent Transactions';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get selectACategoryTxt => 'Select category';

  @override
  String get netBalance => 'Net Balance';

  @override
  String get newTransactionTitle => 'Create a transaction';

  @override
  String get amountLabel => 'Amount';

  @override
  String get descriptionLabel => 'Description (Optional)';

  @override
  String get categoryLabel => 'Category';

  @override
  String get frequencyLabel => 'Frequency';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonNext => 'Next';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonSingUp => 'Sign Up';

  @override
  String get buttonSingIn => 'Sign In';

  @override
  String get buttonResetPwd => 'Reset Password';

  @override
  String get typeIncome => 'Income';

  @override
  String get typeExpense => 'Expense';

  @override
  String get freqSingle => 'Single';

  @override
  String get freqMonthly => 'Monthly';

  @override
  String get freqAnnual => 'Annual';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get errorGeneric => 'An error occurred. Please try again.';
}
