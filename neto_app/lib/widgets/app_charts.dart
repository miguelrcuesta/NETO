import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/models/networth_model.dart';
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

class TransactionBarChart extends StatelessWidget {
  final List<double> incomes;
  final List<double> expenses;
  final ColorScheme colorScheme;

  const TransactionBarChart({
    super.key,
    required this.incomes,
    required this.expenses,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxValue() * 1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = [
                  'E',
                  'F',
                  'M',
                  'A',
                  'M',
                  'J',
                  'J',
                  'A',
                  'S',
                  'O',
                  'N',
                  'D',
                ];
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    months[value.toInt()],
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(12, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: incomes[i],
                color: Colors.greenAccent.shade700,
                width: 7,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: expenses[i],
                color: Colors.redAccent,
                width: 7,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }

  double _getMaxValue() {
    double max = 0;
    for (var v in incomes) {
      if (v > max) max = v;
    }
    for (var v in expenses) {
      if (v > max) max = v;
    }
    return max == 0 ? 100 : max;
  }
}

class AssetEvolutionChart extends StatelessWidget {
  final List<BalanceHistory> history;
  final ColorScheme colorScheme;

  const AssetEvolutionChart({
    super.key,
    required this.history,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    // Si hay menos de 2 puntos, el gráfico no aporta información visual de evolución
    if (history.length < 2) return const SizedBox.shrink();

    // Invertimos el historial: el gráfico de fl_chart dibuja de X=0 (izquierda) a X=N (derecha)
    // Queremos que el punto más antiguo esté a la izquierda.
    final List<BalanceHistory> sortedHistory = history.reversed.toList();

    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: sortedHistory.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.balance);
              }).toList(),
              isCurved: true,
              curveSmoothness: 0.4,
              color: colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(
                show: false,
              ), // Ocultamos puntos para un look limpio
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary.withOpacity(0.3),
                    colorScheme.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
