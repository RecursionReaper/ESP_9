// screens/prediction_screen.dart
import 'package:aqi/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({Key? key}) : super(key: key);

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  late List<AQIData> _pastData;
  late List<AQIData> _forecastData;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Fetch data (mock in this case)
    _pastData = AQIData.getPastWeekData();
    _forecastData = AQIData.getForecastData();
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AQI Forecast'),
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrendSummary(),
                const SizedBox(height: 24),
                _buildAQIChart(),
                const SizedBox(height: 24),
                _buildDataTable(),
                const SizedBox(height: 24),
                _buildForecastInsights(),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTrendSummary() {
    // Calculate if the trend is improving or worsening
    final firstDayAQI = _pastData.first.aqi;
    final lastDayAQI = _pastData.last.aqi;
    final latestChange = lastDayAQI - firstDayAQI;
    final isImproving = latestChange < 0;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AQI Trend Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  isImproving ? Icons.trending_down : Icons.trending_up,
                  color: isImproving ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isImproving ? 'Improving Air Quality' : 'Worsening Air Quality',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isImproving ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Change of ${latestChange.abs()} AQI points in the last week',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAQIChart() {
    final allData = [..._pastData, ..._forecastData];
    final maxAQI = allData.map((data) => data.aqi).reduce((a, b) => a > b ? a : b) * 1.2;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Air Quality Index (AQI)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Past 7 days and 3-day forecast',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.white.withOpacity(0.8),
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            final data = spot.x < _pastData.length 
                                ? _pastData[spot.x.toInt()]
                                : _forecastData[(spot.x - _pastData.length).toInt()];
                                
                            final date = '${data.timestamp.day}/${data.timestamp.month}';
                            final isForecast = spot.x >= _pastData.length;
                            
                            return LineTooltipItem(
                              '${isForecast ? "Forecast: " : ""}AQI: ${spot.y.toInt()}\n$date',
                              TextStyle(
                                color: AQIUtils.getAQIColor(spot.y.toInt()),
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      horizontalInterval: 50,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < allData.length) {
                                  final date = allData[index].timestamp;
                                  return Text(
                                    '${date.day}/${date.month}',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 50,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),

                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    minX: 0,
                    maxX: allData.length - 1.0,
                    minY: 0,
                    maxY: maxAQI,
                    lineBarsData: [
  // Past data line
                      LineChartBarData(
                        spots: List.generate(
                          _pastData.length,
                          (index) => FlSpot(
                            index.toDouble(),
                            (_pastData[index].aqi * _animation.value).toDouble(),
                          ),
                        ),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [Theme.of(context).primaryColor],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor.withOpacity(0.3),
                              Theme.of(context).primaryColor.withOpacity(0.0),
                            ],
                            stops: [0.5, 1.0],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Forecast data line (dashed)
                      LineChartBarData(
                        spots: List.generate(
                          _forecastData.length,
                          (index) => FlSpot(
                            (_pastData.length + index).toDouble(),
                            (_forecastData[index].aqi * _animation.value).toDouble(),
                          ),
                        ),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [Theme.of(context).colorScheme.secondary],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        dashArray: [5, 5],
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                              Theme.of(context).colorScheme.secondary.withOpacity(0.0),
                            ],
                            stops: [0.5, 1.0],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],

                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  Theme.of(context).primaryColor,
                  'Historical',
                  false,
                ),
                const SizedBox(width: 24),
                _buildLegendItem(
                  Theme.of(context).colorScheme.secondary,
                  'Forecast',
                  true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String label, bool isDashed) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: isDashed
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: color,
                      width: 3,
                    ),
                  ),
                )
              : BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1.5),
                ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
  
  Widget _buildDataTable() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detailed AQI Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exporting data...')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                headingRowColor: MaterialStateProperty.all(
                  Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('AQI')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Type')),
                ],
                rows: [
                  ..._pastData.map(
                    (data) => _buildDataRow(
                      date: '${data.timestamp.day}/${data.timestamp.month}',
                      aqi: data.aqi,
                      type: 'Historical',
                    ),
                  ),
                  ..._forecastData.map(
                    (data) => _buildDataRow(
                      date: '${data.timestamp.day}/${data.timestamp.month}',
                      aqi: data.aqi,
                      type: 'Forecast',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  DataRow _buildDataRow({
    required String date,
    required int aqi,
    required String type,
  }) {
    final category = AQIUtils.getAQICategory(aqi);
    final color = AQIUtils.getAQIColor(aqi);
    
    return DataRow(
      cells: [
        DataCell(Text(date)),
        DataCell(
          Text(
            aqi.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        DataCell(
          Text(
            category,
            style: TextStyle(color: color),
          ),
        ),
        DataCell(
          Text(
            type,
            style: TextStyle(
              fontStyle: type == 'Forecast' ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildForecastInsights() {
    // Simple forecast insight based on the data
    final forecastTrend = _forecastData.last.aqi > _forecastData.first.aqi
        ? 'worsening'
        : 'improving';
    
    final forecastAvg = _forecastData
        .map((data) => data.aqi)
        .reduce((a, b) => a + b) / _forecastData.length;
    
    final forecastCategory = AQIUtils.getAQICategory(forecastAvg.toInt());
    final forecastColor = AQIUtils.getAQIColor(forecastAvg.toInt());
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forecast Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Over the next 3 days, the air quality in Delhi is expected to be $forecastTrend, with an average AQI of ${forecastAvg.toInt()}.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Expected category: ',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  forecastCategory,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: forecastColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Prediction model: Machine Learning using historical data, weather patterns, and seasonal trends.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
