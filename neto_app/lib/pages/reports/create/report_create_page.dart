import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_strings.dart';
import 'package:provider/provider.dart';
import 'package:neto_app/provider/reports_provider.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';

class ReportCreatePage extends StatefulWidget {
  const ReportCreatePage({super.key});

  @override
  State<ReportCreatePage> createState() => _ReportCreatePageState();
}

class _ReportCreatePageState extends State<ReportCreatePage> {
  @override
  void dispose() {
    nameReportController.dispose();
    super.dispose();
  }

  String _selectedEmoji = ''; // Estado inicial del emoji

  TextEditingController nameReportController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? nameReportValidator(String? value) {
    if (value == null) {
      return 'El nombre del informe es obligatorio.';
    }
    if (value.trim().isEmpty) {
      return 'El nombre del informe no puede estar vacío.';
    }
    return null;
  }

  List<Map<String, dynamic>> _filterEmojis(String currentSearchText) {
    if (currentSearchText.isEmpty) {
      return AppEmojis.allEmojis;
    } else {
      final query = currentSearchText.toLowerCase();
      return AppEmojis.allEmojis.where((emoji) {
        final name = (emoji['name'] as String).toLowerCase();
        return name.contains(query);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    final reportsProvider = context.read<ReportsProvider>();

    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Crear informe", style: textTheme.titleSmall),
            const SizedBox(height: 30),

            ClipOval(
              child: GestureDetector(
                onTap: () {
                  _showEmojis(context, textTheme, colorScheme);
                },

                child: Container(
                  alignment: Alignment.center,
                  color: colorScheme.surface,
                  width: 90,
                  height: 90,
                  // child: _selectedEmoji.isEmpty ? Icons :Text(
                  //   _selectedEmoji,
                  //   textAlign: TextAlign.center,
                  //   style: const TextStyle(fontSize: 40, height: 2.0),
                  // ),
                  child: _selectedEmoji.isEmpty
                      ? ClipOval(
                          child: Container(
                            height: 80,
                            width: 80,
                            color: colorScheme.surface,
                            child: Icon(
                              Icons.emoji_emotions_outlined,
                              size: 35,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Text(
                          _selectedEmoji,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 40, height: 2.0),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 20),

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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: StandarButton(
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    return;
                  }

                  final newReport = ReportModel.empty().copyWith(
                    name: nameReportController.text.trim(),
                    emoji: _selectedEmoji,
                    dateCreated: DateTime.now(),
                  );

                  await reportsProvider.createReportAndUpdate(
                    context: context,
                    newReport: newReport,
                  );

                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                text: "Crear informe",
                radius: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _showEmojis(
    BuildContext context,
    TextTheme textTheme,

    ColorScheme colorScheme,
  ) {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext modalContext) {
        String currentSearchText = '';
        List filteredEmojis = _filterEmojis(currentSearchText);
        return StatefulBuilder(
          builder: (BuildContext innerContext, mySetState) {
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                leading: CupertinoButton(
                  onPressed: () => Navigator.pop(modalContext),
                  padding: EdgeInsets.zero,
                  child: Text(
                    "Atrás",
                    style: textTheme.bodySmall!.copyWith(color: Colors.blue),
                  ),
                ),
                backgroundColor: CupertinoColors.white,
                border: const Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey5,
                    width: 0.0,
                  ),
                ),
              ),
              child: Scaffold(
                body: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: CupertinoSearchTextField(
                        onChanged: (value) {
                          mySetState(() {
                            currentSearchText = value;
                            filteredEmojis = _filterEmojis(currentSearchText);
                            //debugPrint(filteredEmojis.toString());
                          });

                          // setState(() {
                          //   currentSearchText = value;
                          //   filteredEmojis = _filterEmojis(currentSearchText);
                          // });
                        },
                        placeholder: 'Buscar emoji por nombre',
                        backgroundColor: colorScheme.outlineVariant.withOpacity(
                          0.5,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          itemCount: filteredEmojis.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                // mainAxisSpacing: 5.0,
                                // crossAxisSpacing: 5.0,
                                // childAspectRatio: 0.5,
                              ),
                          itemBuilder: (context, index) {
                            final emojiData = filteredEmojis[index];
                            final currentEmoji = emojiData["emoji"] as String;

                            return Center(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedEmoji = currentEmoji;
                                  });
                                  Navigator.pop(modalContext);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    currentEmoji,
                                    style: const TextStyle(fontSize: 34),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    if (filteredEmojis.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Text(
                          'No se encontraron emojis.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
