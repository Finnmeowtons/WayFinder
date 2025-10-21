import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:way_finders/models/device_info_model.dart';

import '../ip_address.dart';

class DeviceRepository {
  final String baseUrl = IpAddress.ipAddress;

  Future<Map<String, dynamic>> connectDevice(
      String phoneNumber, String deviceNumber, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/connect-device'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'phoneNumber': phoneNumber,
        'deviceNumber': deviceNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to connect device: ${response.body}');
    }
  }

  Future<List<DeviceInfoModel>> getUserDevices(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get-devices'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'phoneNumber': phoneNumber}),
    );
    print("RESPONSE: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 202) {
      print("DATA: ${response.body}");

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DeviceInfoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get devices: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> disconnectDevice(
      String phoneNumber, String deviceNumber) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete-device'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'phoneNumber': phoneNumber, 'deviceNumber': deviceNumber}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to disconnect device: ${response.body}');
    }
  }
}
