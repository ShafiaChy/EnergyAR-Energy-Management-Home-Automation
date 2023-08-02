import 'package:augmented_home_control/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'dart:math' as math;

Widget singleChart(jsonData, int mode, String label) {
  LabelLayoutStrategy? xContainerLabelLayoutStrategy;
  ChartData chartData;
  List<double> runtime = [];
  List<String> xAxis = [];

  if (jsonData == null || jsonData == "null") {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Center(child: Text("No Data Found!", style: TextStyle(fontSize: 20))),
      ),
    );
  }

  void addToList(List<int> temp, String key) {
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

  Map<String, dynamic> map = jsonData;
  map = Map.fromEntries(map.entries.toList()..sort((e1, e2) => e1.key.split("-")[1].compareTo(e2.key.split("-")[1])));

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
        addToList(temp, key);
        prevMonth = raw[1];
        temp.clear();
      }
    });
    addToList(temp, map.entries.last.key);
  } else if (mode == 3) {
    String prevYear = "";
    List<int> temp = [];
    map.forEach((key, value) {
      var raw = key.split("-");
      if (raw[2] == prevYear) {
        temp.add(value);
      } else {
        addToList(temp, key);
        prevYear = raw[2];
        temp.clear();
      }
    });
    addToList(temp, map.entries.last.key);
  }

  ChartOptions chartOptions = const ChartOptions();
  chartOptions = ChartOptions(
    iterativeLayoutOptions: const IterativeLayoutOptions(labelTiltRadians: -math.pi / 2, multiplyLabelSkip: 5),
    dataContainerOptions: DataContainerOptions(
      gridLinesColor: Colors.grey.shade200,
      startYAxisAtDataMinRequested: false,
    ),
  );

  chartData = ChartData(
    dataRows: [runtime],
    xUserLabels: xAxis,
    dataRowsLegends: [label],
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
