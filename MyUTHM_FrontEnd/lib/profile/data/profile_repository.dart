import 'dart:convert';
import 'package:http/http.dart' as http;
import 'profile_model.dart';

class ProfileRepository {
  // 用手机测试时换成你电脑的 IP，例如 http://192.168.1.5:8000
  static const String _baseUrl = 'http://127.0.0.1:8000';

  Future<ProfileModel> getProfile(String matricNo) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/profile/$matricNo'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ProfileModel.fromJson(json);
    } else if (response.statusCode == 404) {
      throw Exception('Student not found');
    } else {
      throw Exception('Failed to load profile');
    }
  }
}