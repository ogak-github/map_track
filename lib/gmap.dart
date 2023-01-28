import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertest/main.dart';
import 'package:fluttertest/replay_timeline.dart';
import 'package:fluttertest/utils.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'model/ReportData.dart';

class Gmap extends StatefulWidget {
  List<ReportData> tracker;
  Gmap({Key? key, required this.tracker}) : super(key: key);

  @override
  State<Gmap> createState() => _GmapState();
}

class _GmapState extends State<Gmap> {
  //late GoogleMapController googleMapController;
  late Completer<GoogleMapController> googleMapController = Completer();
  List<ReportData> _tracker = [];
  final GoogleMapPolyline _googleMapPolyline =
      GoogleMapPolyline(apiKey: Utils.googleApiKey);
  int _polyLineCount = 1;
  final Map<PolylineId, Polyline> _polyLines = <PolylineId, Polyline>{};
  int currentIndex = 0;
  //
  final List<Marker> _marker = [];
  late BitmapDescriptor currentIcon;
  //
  bool _stop = false;
  bool _fForward = false;
  bool _fRewind = false;
  Timer? time;
  int nSkip = 10;
  int nFast = 500;
  Duration defaultSpeed = const Duration(milliseconds: 1000);
  void _onGoogleMapCreated(GoogleMapController controller) {
    googleMapController.complete(controller);
  }

  void _fastForward() {
    time = Timer.periodic(Duration(milliseconds: nFast), (timer) {
      if (currentIndex >= _tracker.length) {
        currentIndex = 0;
        setState(() {
          _fForward = false;
          _stop = false;
          _pause();
        });
        debugPrint("You are at the end of timeline");
      } else {
        currentIndex++;
        setState(() {
          debugPrint(currentIndex.toString());
          getCurrentLocation();
        });
      }
    });

    if (currentIndex >= _tracker.length) {
      _pause();
    }
  }

  void _fastBackward() {
    time = Timer.periodic(
      Duration(milliseconds: nFast),
      (timer) {
        if (currentIndex <= 0) {
          currentIndex = 0;
          setState(() {
            _fRewind = false;
            _stop = false;
            _pause();
          });
          debugPrint("You are at the beginning timeline");
        } else {
          currentIndex--;
          setState(() {
            debugPrint(currentIndex.toString());
            getCurrentLocation();
          });
        }
      },
    );

    if (currentIndex == 0) {
      _pause();
    }
  }

  void _play() {
    time = Timer.periodic(defaultSpeed, (timer) {
      currentIndex++;
      setState(() {
        debugPrint(currentIndex.toString());
        getCurrentLocation();
      });
    });

    if (currentIndex == _tracker.length) {
      _pause();
    }
  }

  void _pause() {
    time!.cancel();
  }

  void _skip() {
    if (currentIndex + nSkip >= _tracker.length) {
      currentIndex = _tracker.length - 1;
      setState(() {
        currentIndex = 0;
      });
      debugPrint("You are at the end of timeline");
    } else {
      currentIndex = currentIndex + nSkip;
      setState(() {
        debugPrint(currentIndex.toString());
        getCurrentLocation();
      });
    }
  }

  void _skipBack() {
    if (currentIndex - nSkip <= 0) {
      currentIndex = 0;
      setState(() {
        currentIndex = 0;
      });
      debugPrint("You are at the end of timeline");
    } else {
      currentIndex = currentIndex - nSkip;
      setState(() {
        debugPrint(currentIndex.toString());
        getCurrentLocation();
      });
    }
  }
  /////

  /*
  getCurrentIcon() async {
    currentIconMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(12, 12)),
        "assets/image/current_location.png");
  }

  getStartIcon() async {
    startIconMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(12, 12)), "assets/image/start.png");
  }

  getDestinationIcon() async {
    destinationIconMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(12, 12)),
        "assets/image/destination.png");
  }

  */

  @override
  void initState() {
    _tracker = widget.tracker;
    getCurrentLocation();

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)),
            "assets/image/current_location.png")
        .then((value) => currentIcon = value);

    currentIndex;
    _getPolyLineLocation();
    super.initState();
  }

  Future<void> getCurrentLocation() async {
    _marker.clear();

    final GoogleMapController mapController = await googleMapController.future;
    mapController.animateCamera(CameraUpdate.newLatLng(LatLng(
        _tracker[currentIndex].latitude, _tracker[currentIndex].longitude)));
    setState(() {
      _marker.add(
        Marker(
          //icon: currentIcon,
          icon: BitmapDescriptor.defaultMarkerWithHue(40.0),
          markerId: const MarkerId("Driver Current Location"),
          position: LatLng(_tracker[currentIndex].latitude,
              _tracker[currentIndex].longitude),
        ),
      );

      _marker.add(
        Marker(
          //icon: startIconMarker!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          markerId: const MarkerId("Start Location"),
          position: LatLng(_tracker.first.latitude, _tracker.first.longitude),
        ),
      );

      _marker.add(
        Marker(
          //icon: destinationIconMarker!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          markerId: const MarkerId("Destination Location"),
          position: LatLng(_tracker.last.latitude, _tracker.last.longitude),
        ),
      );
    });
  }

  ///Poly-lines
  List<LatLng> coordinates = [];

  List<List<PatternItem>> patterns = <List<PatternItem>>[
    <PatternItem>[], //line
    <PatternItem>[PatternItem.dash(30.0), PatternItem.gap(20.0)], //dash
    <PatternItem>[PatternItem.dot, PatternItem.gap(10.0)], //dot
    <PatternItem>[
      //dash-dot
      PatternItem.dash(30.0),
      PatternItem.gap(20.0),
      PatternItem.dot,
      PatternItem.gap(20.0)
    ],
  ];

  _getPolyLineLocation() async {
    for (var l in _tracker) {
      coordinates.add(
        LatLng(l.latitude, l.longitude),
      );
    }
    setState(() {
      _polyLines.clear();
    });
    _addPolyLine(coordinates);
  }

  _addPolyLine(List<LatLng> coordinates) {
    PolylineId id = PolylineId("poly$_polyLineCount");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blueAccent,
        patterns: patterns[0],
        points: coordinates,
        width: 2,
        onTap: () {});

    setState(() {
      _polyLines[id] = polyline;
      _polyLineCount++;
    });
  }

  @override
  void dispose() {
    time!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MyHomePage()));
          },
          icon: const Icon(Icons.close),
        ),
        title: ListTile(
          title: Text("Teknisi ${_tracker.first.driver}"),
          subtitle: Text(
              "${_tracker.first.dateTime.substring(0, 10)} - ${_tracker.last.dateTime.substring(0, 10)}",
              style: const TextStyle(fontSize: 12)),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            polylines: Set<Polyline>.of(_polyLines.values),
            onMapCreated: _onGoogleMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(_tracker[currentIndex].latitude,
                  _tracker[currentIndex].longitude),
              zoom: 14,
            ),
            markers: Set<Marker>.of(_marker),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: FloatingActionButton(
          child: const Icon(Icons.list_rounded),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReplayTimeline(list: _tracker),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 220,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Slider(
                  value: currentIndex.toDouble(),
                  onChanged: (value) {
                    double c = currentIndex.toDouble();
                    setState(() {
                      c = value;
                    });
                  },
                  min: 0.0,
                  max: _tracker.length.toDouble()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Engine",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _tracker[currentIndex].ign,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        "Speed",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("${_tracker[currentIndex].speed} Km/h",
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        "Event",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                          "${_tracker[currentIndex].reportId}(${_tracker[currentIndex].eventName})",
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        "Sat",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(_tracker[currentIndex].satellite.toString(),
                              style: const TextStyle(fontSize: 13)),
                          iconSignal(_tracker[currentIndex].satellite),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              ListTile(
                leading: iconDriverStatus(_tracker[currentIndex].ign),
                title: Text(
                  _tracker[currentIndex].roadName,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
              _stop != true ? buttonType1() : buttonType2()
            ],
          ),
        ),
      ),
    );
  }

  Widget buttonType1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.undo_outlined),
          onPressed: () {
            setState(() {
              _skipBack();
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () {
            _stop = true;
            setState(() {
              _play();
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: () {
            setState(() {
              _skip();
            });
          },
        ),
      ],
    );
  }

  Widget buttonType2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _fRewind == false
            ? IconButton(
                icon: const Icon(Icons.fast_rewind),
                onPressed: () {
                  _fRewind = true;
                  _fForward = false;
                  setState(() {
                    _pause();
                    _fastBackward();
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.fast_rewind, color: Colors.blueAccent),
                onPressed: () {
                  setState(() {
                    _fRewind = false;
                    _pause();
                    _play();
                  });
                },
              ),
        IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () {
            setState(() {
              _fRewind = false;
              _fForward = false;
              _stop = false;
              _pause();
            });
          },
        ),
        _fForward == false
            ? IconButton(
                icon: const Icon(Icons.fast_forward),
                onPressed: () {
                  _fRewind = false;
                  _fForward = true;
                  setState(() {
                    _pause();
                    _fastForward();
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.fast_forward, color: Colors.blueAccent),
                onPressed: () {
                  setState(() {
                    _fForward = false;
                    _pause();
                    _play();
                  });
                },
              ),
      ],
    );
  }

  Widget iconSignal(int signalStrength) {
    if (signalStrength <= 3) {
      return const Icon(
        Icons.signal_cellular_0_bar,
        size: 12,
      );
    } else {
      return const Icon(
        Icons.signal_cellular_4_bar,
        size: 12,
      );
    }
  }

  Widget iconDriverStatus(String status) {
    if (status == "ON") {
      return const Icon(Icons.navigation, color: Colors.blueAccent);
    } else {
      return const Icon(Icons.pin_drop, color: Colors.red);
    }
  }
}
