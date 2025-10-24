import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:way_finders/models/device_info_model.dart';

import '../ip_address.dart';

class DeviceRepository {
  final String baseUrl = IpAddress.ipAddress;

  Future<Map<String, dynamic>> connectDevice(
      String name,
      String phoneNumber,
      String deviceNumber,
      String password,
      File? imageFile,
      ) async {
    final uri = Uri.parse('$baseUrl/connect-device');
    final request = http.MultipartRequest('POST', uri);

    // add fields
    request.fields['name'] = name.isEmpty ? "Stick" : name.trim();
    request.fields['phoneNumber'] = phoneNumber.trim();
    request.fields['deviceNumber'] = deviceNumber.trim();
    request.fields['password'] = password.trim();

    // add image if available
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );
    }

    // send request
    final response = await request.send();

    // convert streamed response to normal response
    final responseBody = await http.Response.fromStream(response);
    print("RESPONSE (${response.statusCode}): ${responseBody.body}");

    if (response.statusCode == 200) {
      return jsonDecode(responseBody.body);
    } else {
      throw Exception('Failed to connect device: ${responseBody.body}');
    }
  }

  Future<List<DeviceInfoModel>> getUserDevices(String phoneNumber) async {
    try {
      print("Trying Getting user devices");
      final response = await http.post(
        Uri.parse('$baseUrl/get-devices'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'phoneNumber': phoneNumber}),
      );

      print("RESPONSE (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 202) {
        final decoded = jsonDecode(response.body);

        final List<dynamic> data = decoded is List
            ? decoded
            : (decoded['devices'] ?? []); // fallback if wrapped inside an object

        return data.map((json) => DeviceInfoModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get devices (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print("Error in getUserDevices: $e");
      rethrow;
    }
  }


  Future<Map<String, dynamic>> editDevice(
      int id,
      String name,
      File? imageFile,
      ) async {
    final uri = Uri.parse('$baseUrl/edit-device');
    final request = http.MultipartRequest('PUT', uri);

    // add fields
    request.fields['id'] = id.toString();
    request.fields['name'] = name.trim();

    // add image if available
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );
    }

    // send request
    final response = await request.send();

    // convert streamed response to normal response
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      return jsonDecode(responseBody.body);
    } else {
      throw Exception('Failed to edit device: ${responseBody.body}');
    }
  }


  Future<Map<String, dynamic>> disconnectDevice(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete-device'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'id': id}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to disconnect device: ${response.body}');
    }
  }
}
