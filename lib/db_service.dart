import 'package:fluttertest/app_database.dart';
import 'package:fluttertest/model/ReportData.dart';

class DbService {
  final _appdb = AppDatabase.instance;

  Future<List<ReportData>> getAllReport() async {
    return await _appdb.readReport();
  }

  Future<List<Map>> getData() async {
    return await _appdb.select('data');
  }
}
