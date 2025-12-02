import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🔑 Importar Provider
import 'package:neto_app/provider/reports_provider.dart'; // 🔑 Importar ReportsProvider
// import 'package:neto_app/controllers/reports_controller.dart'; // ❌ Eliminado
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';

class ReportCreatePage extends StatefulWidget {
  const ReportCreatePage({super.key});

  @override
  State<ReportCreatePage> createState() => _ReportCreatePageState();
}

class _ReportCreatePageState extends State<ReportCreatePage> {
  //########################################################################
  // VARIABLES
  //########################################################################

  // ❌ Eliminado: ReportsController reportsController = ReportsController();

  //########################################################################
  // CONTROLLERS
  //########################################################################
  TextEditingController nameReportController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //########################################################################
  // FUNCIONES
  //########################################################################
  String? nameReportValidator(String? value) {
    // 1. Comprueba si el valor es nulo
    if (value == null) {
      return 'El nombre del informe es obligatorio.';
    }

    // 2. Comprueba si el valor está vacío (después de eliminar espacios en blanco)
    if (value.trim().isEmpty) {
      return 'El nombre del informe no puede estar vacío.';
    }
    return null;
  }

  //########################################################################
  // BUILD
  //########################################################################

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    // 🔑 Obtener el Provider para ejecutar la acción (listen: false)
    final reportsProvider = context.read<ReportsProvider>();

    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Crear informe", style: textTheme.titleSmall),
            const SizedBox(height: 30),
            StandarTextField(
              controller: nameReportController,
              validator: nameReportValidator,
              filled: true,
              filledColor: colorScheme.surface,
              enable: true,
              hintText: "Título del informe",
              textInputAction: TextInputAction.done,
            ),
            const Spacer(),
            StandarButton(
              onPressed: () async {
                // 1. Validar el formulario
                if (!(_formKey.currentState?.validate() ?? false)) {
                  debugPrint('ReportCreatePage: name field validation failed');
                  return;
                }
                debugPrint("Crear informe: ${nameReportController.text}");

                // 2. Crear el modelo con los datos
                final newReport = ReportModel.empty().copyWith(
                  name: nameReportController.text.trim(),
                  dateCreated: DateTime.now(),
                );

                // 3. 🔑 Llamar al Provider para crear y actualizar la lista
                // El Provider se encarga de llamar al Controller y luego a loadInitialReports()
                await reportsProvider.createReportAndUpdate(
                  context: context,
                  newReport: newReport,
                );

                if (!context.mounted) return;
                nameReportController.dispose();
                Navigator.pop(context);
              },
              text: "Crear informe",
              radius: 50,
            ),
          ],
        ),
      ),
    );
  }
}
