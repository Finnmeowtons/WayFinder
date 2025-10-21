import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:way_finders/ip_address.dart';
import 'local_storage_repository.dart';

class AuthRepository {
  final String baseUrl = IpAddress.ipAddress;
  final LocalStorageRepository _localStorage = LocalStorageRepository();

  Future<Map<String, dynamic>> signIn(String phoneNumber, String otp) async {
    print("Sign in called");
    print("Signing in with phone number: $phoneNumber, $otp");
    final response = await http.post(
      Uri.parse('$baseUrl/auth'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'phoneNumber': phoneNumber, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sign in: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> confirmUser(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/confirm'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'phoneNumber': phoneNumber}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _localStorage.saveToken(data['token']);
      await _localStorage.savePhoneNumber(phoneNumber);
      return data;
    } else {
      throw Exception('Failed to confirm user: ${response.body}');
    }
  }
}
