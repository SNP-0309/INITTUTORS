import '../domain/institute.dart';
import 'institute_api.dart';

class InstituteRepository {
  InstituteRepository(this._api);

  final InstituteApi _api;

  Future<Institute> createInstitute(Map<String, dynamic> data) async {
    final raw = await _api.createInstitute(data);
    return Institute.fromJson(raw);
  }

  Future<Institute> updateInstitute(String id, Map<String, dynamic> data) async {
    final raw = await _api.updateInstitute(id, data);
    return Institute.fromJson(raw);
  }

  Future<Institute> getInstitute(String id) async {
    final raw = await _api.getInstitute(id);
    return Institute.fromJson(raw);
  }

  Future<List<Institute>> listInstitutes() async {
    final rawList = await _api.listInstitutes();
    return rawList.map((e) => Institute.fromJson(e as Map<String, dynamic>)).toList();
  }
}
