import 'package:flutter/material.dart';
import 'package:fluttertest/db_service.dart';
import 'package:fluttertest/gmap.dart';
import 'package:fluttertest/replay_timeline.dart';

import 'model/ReportData.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbService = DbService();
  List<ReportData> myList = [];
  @override
  void initState() {
    //dbService.getData();
    dbService.getAllReport();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String title = "Flutter Test";
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text(
                "Records Data",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16.0),
              _dataBuilder(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.replay),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ReplayTimeline(list: myList)),
          );
        },
      ),
    );
  }

  Widget _dataBuilder() {
    return FutureBuilder(
      future: dbService.getAllReport(),
      builder: (context, AsyncSnapshot<List<ReportData>> snapshot) {
        if (snapshot.hasData) {
          List<ReportData> reportListData = snapshot.data ?? [];
          return listReport(reportListData);
        } else if (snapshot.hasError) {
          return const Text("Oops");
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget listReport(List<ReportData> data) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 1,
      itemBuilder: (context, int index) {
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Gmap(tracker: data)));
          },
          child: ListTile(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(data[0].driver),
            subtitle: Text(data[0].dateTime),
          ),
        );
      },
    );
  }
}
