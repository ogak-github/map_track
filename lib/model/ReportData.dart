class ReportData {
  int no;
  String driver;
  String dateTime;
  String roadName;
  double latitude;
  double longitude;
  String ign;
  int speed;
  int heading;
  int satellite;
  String eventName;
  int reportId;
  double odometer;
  double hourmeter;
  int input;
  int output;

  ReportData({
    required this.no,
    required this.driver,
    required this.dateTime,
    required this.roadName,
    required this.latitude,
    required this.longitude,
    required this.ign,
    required this.speed,
    required this.heading,
    required this.satellite,
    required this.eventName,
    required this.reportId,
    required this.odometer,
    required this.hourmeter,
    required this.input,
    required this.output,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      no: json['No'],
      driver: json['Driver'],
      dateTime: json['Date_Time'],
      roadName: json['Road_Name'],
      latitude: json['Latitude'],
      longitude: json['Longitude'],
      ign: json['IGN'],
      speed: json['Speed'],
      heading: json['Heading'],
      satellite: json['Satellite'],
      eventName: json['Event_Name'],
      reportId: json['Report_id'],
      odometer: json['Odometer'],
      hourmeter: json['Hourmeter'],
      input: json['Input'],
      output: json['Output'],
    );
  }

  Map<String, dynamic> toJson() => {
        'No': no,
        'Driver': driver,
        'Date_Time': dateTime,
        'Road_Name': roadName,
        'Latitude': latitude,
        'Longitude': latitude,
        'IGN': ign,
        'Speed': speed,
        'Heading': heading,
        'Satellite': satellite,
        'Event_Name': eventName,
        'Report_Id': reportId,
        'Odometer': odometer,
        'Hourmeter': hourmeter,
        'Input': input,
        'Output': output,
      };
}
