import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:neto_app/constants/app_utils.dart';
// Asegúrate de que esta ruta es correcta para tu proyecto
// import 'package:neto_app/models/networth_model.dart';

class AssetPieChart extends StatelessWidget {
  final Map<String, double> typeTotals;
  final double totalNetWorth;
  final ColorScheme colorScheme;

  //  Paleta de colores consistente para el gráfico y la leyenda
  final List<Color> chartColors;

  AssetPieChart({
    super.key,
    required this.typeTotals,
    required this.totalNetWorth,
    required this.colorScheme,
  }) : chartColors = chartColorsStatic;

  // Helper para generar los datos de las secciones del gráfico (PieChartSectionData)
  List<PieChartSectionData> _showingSections() {
    int i = 0;

    //Ajuste 1: Aumentamos el radio de la porción a 20 para que el anillo sea más grueso.
    const double desiredRadius = 13;

    return typeTotals.entries.map((entry) {
      final color = chartColors[i % chartColors.length];
      i++;

      // Solo mostramos secciones con valor positivo
      if (entry.value <= 0) {
        return PieChartSectionData(value: 0); // Sección vacía
      }

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '', // Dejamos el título vacío, el valor se muestra en el centro
        radius: desiredRadius, //Nuevo radio más grueso
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const double widgetSize = 155;
    const double newCenterSpaceRadius = widgetSize / 2 - 10; // 55.0

    return SizedBox(
      width: widgetSize,
      height: widgetSize,
      child: totalNetWorth <= 0
          ? Container(
              // Estado para cuando no hay activos
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 30),
              ),
              alignment: Alignment.center,
              // El tamaño de fuente puede necesitar ajustarse si el widget es mucho más grande
              child: Text(
                '0.00',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                // 1. Gráfico Circular de fl_chart
                PieChart(
                  PieChartData(
                    sections: _showingSections(),
                    sectionsSpace: 0,
                    centerSpaceRadius: newCenterSpaceRadius,
                    startDegreeOffset: 270,
                    borderData: FlBorderData(show: false),
                  ),
                ),

                // 2. Texto Central (overlay)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Es posible que necesites aumentar el tamaño de fuente si el gráfico es mucho más grande
                    Text(
                      AppFormatters.getFormatedNumber(
                        totalNetWorth.toString(),
                        totalNetWorth,
                      ),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        // Aumentado a titleMedium para llenar el espacio
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text('Total', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
    );
  }
}
