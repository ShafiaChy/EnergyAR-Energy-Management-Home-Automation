import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'dart:math' as math;

import 'consts.dart';

Widget multiChart(jsonData1, jsonData2, jsonData3, int mode) {
  LabelLayoutStrategy? xContainerLabelLayoutStrategy;
  ChartData chartData;
  List<double> runtime1 = [];
  List<String> xAxis1 = [];
  List<double> runtime2 = [];
  List<String> xAxis2 = [];
  List<double> runtime3 = [];
  List<String> xAxis3 = [];
  List<String> xAxis = [];

  ChartOptions chartOptions = const ChartOptions();
  chartOptions = ChartOptions(
    iterativeLayoutOptions: const IterativeLayoutOptions(labelTiltRadians: -math.pi / 2, multiplyLabelSkip: 5),
    dataContainerOptions: DataContainerOptions(
      gridLinesColor: Colors.grey.shade200,
      startYAxisAtDataMinRequested: false,
    ),
  );

  void addToList(List<double> runtime, List<String> xAxis, List<int> temp, String key, String label) {
    var raw = key.split("-");
    if (temp.isNotEmpty) {
      int sum = 0;
      for (var value in temp) {
        sum += value;
      }
      int load = 0;
      if (label == "Light") {
        load = lightWatt;
      } else if (label == "Fan") {
        load = fanWatt;
      } else if (label == "Fridge") {
        load = freezeWatt;
      }
      double avg = ((sum / temp.length) / 3600) * load;
      runtime.add(avg);
      if (mode == 2) {
        xAxis.add("${raw[1]}-${raw[2]}");
      } else if (mode == 3) {
        xAxis.add("20${raw[2]}");
      }
    }
  }

  void makeChart(Map<String, dynamic> map, List<double> runtime, List<String> xAxis, String label) {
    if (mode == 1) {
      map.forEach((key, value) {
        xAxis.add(key);
        int load = 0;
        if (label == "Light") {
          load = lightWatt;
        } else if (label == "Fan") {
          load = fanWatt;
        } else if (label == "Fridge") {
          load = freezeWatt;
        }
        runtime.add((value / 3600) * load);
      });
    } else if (mode == 2) {
      String prevMonth = "";
      List<int> temp = [];
      map.forEach((key, value) {
        var raw = key.split("-");
        if (raw[1] == prevMonth) {
          temp.add(value);
        } else {
          addToList(runtime, xAxis, temp, key, label);
          prevMonth = raw[1];
          temp.clear();
        }
      });
      addToList(runtime, xAxis, temp, map.entries.last.key, label);
    } else if (mode == 3) {
      String prevYear = "";
      List<int> temp = [];
      map.forEach((key, value) {
        var raw = key.split("-");
        if (raw[2] == prevYear) {
          temp.add(value);
        } else {
          addToList(runtime, xAxis, temp, key, label);
          prevYear = raw[2];
          temp.clear();
        }
      });
      addToList(runtime, xAxis, temp, map.entries.last.key, label);
    }
  }

  if (jsonData1 != null && jsonData1 != "null") {
    Map<String, dynamic> map1 = jsonData1;
    map1 =
        Map.fromEntries(map1.entries.toList()..sort((e1, e2) => e1.key.split("-")[1].compareTo(e2.key.split("-")[1])));
    makeChart(map1, runtime1, xAxis1, "Light");
  }

  if (jsonData2 != null && jsonData2 != "null") {
    Map<String, dynamic> map2 = jsonData2;
    map2 =
        Map.fromEntries(map2.entries.toList()..sort((e1, e2) => e1.key.split("-")[1].compareTo(e2.key.split("-")[1])));
    makeChart(map2, runtime2, xAxis2, "Fan");
  }

  if (jsonData3 != null && jsonData3 != "null") {
    Map<String, dynamic> map3 = jsonData3;
    map3 =
        Map.fromEntries(map3.entries.toList()..sort((e1, e2) => e1.key.split("-")[1].compareTo(e2.key.split("-")[1])));
    makeChart(map3, runtime3, xAxis3, "Fridge");
  }

  if (xAxis1.length >= xAxis2.length && xAxis1.length >= xAxis3.length) {
    xAxis = xAxis1;
    int extra = xAxis1.length - xAxis2.length;
    for (int i = 0; i < extra; i++) {
      runtime2.add(0);
    }
    extra = xAxis1.length - xAxis3.length;
    for (int i = 0; i < extra; i++) {
      runtime3.add(0);
    }
  } else if (xAxis2.length >= xAxis1.length && xAxis2.length >= xAxis3.length) {
    xAxis = xAxis2;
    int extra = xAxis2.length - xAxis1.length;
    for (int i = 0; i < extra; i++) {
      runtime1.add(0);
    }
    extra = xAxis2.length - xAxis3.length;
    for (int i = 0; i < extra; i++) {
      runtime3.add(0);
    }
  } else if (xAxis3.length >= xAxis1.length && xAxis3.length >= xAxis2.length) {
    xAxis = xAxis3;
    int extra = xAxis3.length - xAxis1.length;
    for (int i = 0; i < extra; i++) {
      runtime1.add(0);
    }
    extra = xAxis3.length - xAxis1.length;
    for (int i = 0; i < extra; i++) {
      runtime2.add(0);
    }
  }

  chartData = ChartData(
    dataRows: [runtime1, runtime2, runtime3],
    xUserLabels: xAxis,
    dataRowsLegends: const ['Light', 'Fan', 'Fridge'],
    chartOptions: chartOptions,
  );

  var lineChartAnchor = LineChartTopContainer(
    chartData: chartData,
    xContainerLabelLayoutStrategy: xContainerLabelLayoutStrategy,
  );

  var lineChart = LineChart(
    painter: LineChartPainter(
      lineChartContainer: lineChartAnchor,
    ),
  );
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: lineChart,
    ),
  );
}
