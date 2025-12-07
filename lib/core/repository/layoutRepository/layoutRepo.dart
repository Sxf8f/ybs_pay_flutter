// lib/repositories/layout_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ybs_pay/core/const/assets_const.dart';
import '../../models/authModels/userModel.dart';

class LayoutRepository {
  final String apiUrl = "${AssetsConst.apiBase}layout-settings/api/all/"; // replace with actual


  Future<List<LayoutModel>> fetchLayouts() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      print('11');
      final data = json.decode(response.body);
      final layouts = (data['layouts'] as List)
          .map((e) => LayoutModel.fromJson(e))
          .toList();
      return layouts;
    } else {
      print('1e1');

      throw Exception("Failed to load layouts");
    }
  }
}
