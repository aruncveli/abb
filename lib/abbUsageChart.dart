import 'package:abb/usage.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AbbUsageChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final String connectionType;
  final String packageName;

  AbbUsageChart(this.seriesList,
      {this.animate, this.connectionType, this.packageName});

  factory AbbUsageChart.getUsageChart(
      balance, downloaded, uploaded, connectionType, packageName) {
    return new AbbUsageChart(
      _getUsageData(balance, downloaded, uploaded),
      connectionType: connectionType,
      packageName: packageName,
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(
      seriesList,
      animate: animate,
      defaultRenderer: new charts.ArcRendererConfig(arcRendererDecorators: [
        new charts.ArcLabelDecorator(
            labelPosition: charts.ArcLabelPosition.auto)
      ]),
      behaviors: [
        new charts.ChartTitle('Plan: $packageName',
            titleStyleSpec:
                new charts.TextStyleSpec(fontSize: 30, lineHeight: 2),
            subTitle: connectionType,
            subTitleStyleSpec:
                new charts.TextStyleSpec(fontSize: 20, lineHeight: 1),
            behaviorPosition: charts.BehaviorPosition.top)
      ],
    );
  }

  static List<charts.Series<Usage, String>> _getUsageData(
      balance, downloaded, uploaded) {
    final data = [
      new Usage("Balance", balance),
      new Usage("Downloaded", downloaded),
      new Usage("Uploaded", uploaded)
    ];

    return [
      new charts.Series<Usage, String>(
          id: 'Usage',
          domainFn: (Usage usage, _) => usage.category,
          measureFn: (Usage usage, _) => usage.octets,
          data: data,
          labelAccessorFn: (Usage usage, _) =>
              '${usage.category}: ${(usage.octets / 1024).toStringAsFixed(1)} GB')
    ];
  }
}
