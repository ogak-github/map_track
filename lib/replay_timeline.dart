import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

import 'model/ReportData.dart';

class ReplayTimeline extends StatelessWidget {
  List<ReportData> list;
  ReplayTimeline({Key? key, required this.list}) : super(key: key);
  ScrollController _scrollController = ScrollController();

  void goToEndList() {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(position,
          duration: const Duration(seconds: 3), curve: Curves.easeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Replay Timeline"),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            final ReportData data = list[index];
            if (list[index] == list.first) {
              return headTimeLine(data);
            }
            if (list[index] == list.last) {
              return endTimeLine(data);
            }
            if (list[index - 1].eventName == data.eventName) {
              return timeLine(data, true);
            }
            return timeLine(data, false);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_downward),
        onPressed: () {
          goToEndList();
        },
      ),
    );
  }

  Widget headTimeLine(ReportData headTimeLine) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.30,
      isFirst: true,
      indicatorStyle: IndicatorStyle(
        width: 30,
        iconStyle: IconStyle(
          color: Colors.white,
          iconData: Icons.calendar_today,
        ),
      ),
      startChild: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: Text(
                headTimeLine.dateTime.substring(0, 10),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget endTimeLine(ReportData endTimeLine) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.30,
      isLast: true,
      startChild: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: Text(
                endTimeLine.dateTime.substring(11, 16),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      endChild: Container(
        child: Column(
          children: [
            ListTile(
              title: Text(endTimeLine.eventName.toTitleCase()),
              subtitle: Text(
                endTimeLine.roadName.toTitleCase(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget timeLine(ReportData data, bool isEventPreviousSame) {
    if (data.eventName == "IGN-OFF") {
      return myTimeLineTile(
        Colors.red,
        data.eventName.replaceRange(0, 4, "Ignition ").toTitleCase(),
        data.roadName,
        data.dateTime,
        false,
      );
    }

    if (data.eventName == "IGN-ON") {
      return myTimeLineTile(
        Colors.blue,
        data.eventName.replaceRange(0, 4, "Ignition ").toTitleCase(),
        data.roadName,
        data.dateTime,
        false,
      );
    }

    if (data.eventName == "TRACKING") {
      return myTimeLineTile(
        Colors.green,
        data.eventName.replaceAll("TRACKING", "MOVING").toTitleCase(),
        data.roadName,
        data.dateTime,
        false,
      );
    }

    if (data.eventName == "POWER LOST") {
      return myTimeLineTile(
        Colors.red,
        data.eventName.toTitleCase(),
        data.roadName,
        data.dateTime,
        false,
      );
    }

    if (data.eventName == "POWER OK") {
      return myTimeLineTile(
        Colors.lightBlue,
        data.eventName.toTitleCase(),
        data.roadName,
        data.dateTime,
        false,
      );
    }

    if (data.eventName == "SLEEP") {
      return myTimeLineTile(
        Colors.blueGrey,
        data.eventName.toTitleCase(),
        data.roadName,
        data.dateTime,
        false,
      );
    }
    if (data.eventName == "CONFIG ERR") {
      return myTimeLineTile(
        Colors.black,
        data.eventName.toTitleCase(),
        data.roadName,
        data.dateTime,
        false,
      );
    }
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.30,
      startChild: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: Text(
                data.dateTime.substring(11, 16),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      endChild: Container(
        child: Column(
          children: [
            ListTile(
              title: Text(data.eventName.toTitleCase()),
              subtitle: Text(
                data.roadName.toTitleCase(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget myTimeLineTile(
    final myColor,
    String eventName,
    String roadName,
    String dateTime,
    bool isFirst,
  ) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      isFirst: false,
      lineXY: 0.30,
      afterLineStyle: LineStyle(color: myColor),
      indicatorStyle: IndicatorStyle(
        color: myColor,
        drawGap: true,
      ),
      startChild: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: Text(
                dateTime.substring(11, 16),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      endChild: SizedBox(
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: Text(eventName),
              subtitle: Text(
                roadName.toTitleCase(),
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.capitalize())
      .join(' ');
}
