import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'consts.dart';
import 'multi_chart.dart';
import 'single_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  dynamic lightData, fanData, freezeData;
  int mode = 1;

  Future<void> fetchData() async {
    try {
      // get light data
      var url = Uri.parse("${host}light.json");
      var response = await http.get(url);
      lightData = jsonDecode(response.body);
      //print(lightData);
      // get light data
      url = Uri.parse("${host}fan.json");
      response = await http.get(url);
      fanData = jsonDecode(response.body);
      //print(fanData);
      // get light data
      url = Uri.parse("${host}freeze.json");
      response = await http.get(url);
      freezeData = jsonDecode(response.body);
      //print(freezeData);
    } catch (ex) {
      //print(ex);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ex.toString()),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  Widget showMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ChoiceChip(
          label: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text("Day"),
          ),
          selected: mode == 1,
          selectedColor: Colors.blueAccent,
          onSelected: (value) => setState(() {
            mode = value ? 1 : mode;
          }),
        ),
        ChoiceChip(
          label: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text("Month"),
          ),
          selected: mode == 2,
          selectedColor: Colors.blueAccent,
          onSelected: (value) => setState(() {
            mode = value ? 2 : mode;
          }),
        ),
        ChoiceChip(
          label: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text("Year"),
          ),
          selected: mode == 3,
          selectedColor: Colors.blueAccent,
          onSelected: (value) => setState(() {
            mode = value ? 3 : mode;
          }),
        ),
      ],
    );
  }

  Widget showChart(String title, data) {
    String label = title.split(" ")[0];
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          width: double.maxFinite,
          child: singleChart(data, mode, label),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget showChartAll(String title, data1, data2, data3) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          width: double.maxFinite,
          child: multiChart(data1, data2, data3, mode),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: FutureBuilder(
        future: fetchData(),
        builder: (context, data) {
          if (data.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  showMode(),
                  const SizedBox(height: 10),
                  const Center(child: Text("X-Axis: Date | Y-Axis: WHrs")),
                  const SizedBox(height: 10),
                  showChart("Light Consumption:", lightData),
                  showChart("Fan Consumption:", fanData),
                  showChart("Fridge Consumption:", freezeData),
                  showChartAll("All Consumption:", lightData, fanData, freezeData)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
