import 'package:flutter/material.dart';
import 'package:neto_app/controllers/reports_controller.dart';
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

  ReportsController reportsController = ReportsController();

  //########################################################################
  // CONTROLLERS
  //########################################################################
  TextEditingController nameReportController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //########################################################################
  // FUNCIONES
  //########################################################################
  String? nameReportValidator(String? value) {
    // 1. Comprueba si el valor es nulo (siempre devuelve nulo si el campo es nulo)
    if (value == null) {
      return 'El nombre del informe es obligatorio.';
    }

    // 2. Comprueba si el valor está vacío (después de eliminar espacios en blanco)
    if (value.trim().isEmpty) {
      return 'El nombre del informe es obligatorio.';
    }

    // 3. Si el valor es válido, devuelve null.
    // Devolver null indica que la validación ha pasado.
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      height: 300,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 50),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text("Crea un nuevo informe", style: textTheme.titleSmall),
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
            Spacer(),
            StandarButton(
              onPressed: () async {
                // Validate the form before creating the report
                if (!(_formKey.currentState?.validate() ?? false)) {
                  debugPrint('ReportCreatePage: name field validation failed');
                  return;
                }
                debugPrint("Crear informe: ${nameReportController.text}");

                ReportModel reportModel = ReportModel.empty();

                reportModel = reportModel.copyWith(
                  name: nameReportController.text.trim(),
                  dateCreated: DateTime.now(),
                );

                await reportsController.createReport(
                  context: context,
                  report: reportModel,
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
