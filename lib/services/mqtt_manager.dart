import 'dart:async';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:way_finders/ip_address.dart';

class MqttManager {
  static final MqttManager _instance = MqttManager._internal();
  factory MqttManager() => _instance;
  MqttManager._internal();

  MqttServerClient? client;
  bool isConnected = false;
  final String server = IpAddress.ipAddress.replaceAll("http://", "").split(":")[0];
  final int port = 1884;
  final String clientId = 'wayfinder_client_${DateTime.now().millisecondsSinceEpoch}';

  final Set<String> _subscribedTopics = {};
  final List<String> _pendingSubscriptions = [];
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<void> initialize() async {
    print("Server: $server, Port: $port, Client ID: $clientId");
    client = MqttServerClient.withPort(server, clientId, port);
    client!.logging(on: false);
    client!.keepAlivePeriod = 20;
    client!.autoReconnect = true;
    client!.resubscribeOnAutoReconnect = true;
    client!.onConnected = _onConnected;
    client!.onDisconnected = _onDisconnected;
    await _connect();

    client!.updates.listen(_onMessage);
  }

  Future<void> _connect() async {
    try {
      print('Connecting to MQTT broker...');
      await client!.connect();
      isConnected = true;
      print('✅ MQTT Connected!');
    } catch (e) {
      print('❌ MQTT Connection failed: $e');
      isConnected = false;
    }
  }

  void _onConnected() {
    print('🔄 MQTT Connected/Reconnected');
    isConnected = true;

    // subscribe to any queued topics
    for (var topic in _pendingSubscriptions) {
      subscribe(topic); // this time it will succeed
    }
    _pendingSubscriptions.clear();
  }

  void _onDisconnected() {
    print('⚠️ MQTT Disconnected');
    isConnected = false;
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage?>>? messages) {
    final recMess = messages![0].payload as MqttPublishMessage;
    final topic = messages[0].topic;
    final payload = MqttUtilities.bytesToStringAsString(recMess.payload.message!);

    print('📩 [$topic] $payload');

    try {
      final data = jsonDecode(payload);
      _messageController.add({
        'topic': topic,
        'data': data,
      });
    } catch (e) {
      print('Error decoding MQTT message: $e');
    }
  }

  void publish(String topic, String message) {
    if (isConnected) {
      final builder = MqttPayloadBuilder();
      builder.addString(message);
      client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    }
  }

  void subscribe(String topic) {
    if (_subscribedTopics.contains(topic)) return;

    if (isConnected) {
      client!.subscribe(topic, MqttQos.atLeastOnce);
      _subscribedTopics.add(topic);
      print("🟢 Subscribed to $topic");
    } else {
      // queue the subscription for later
      _pendingSubscriptions.add(topic);
      print("⏳ Queued subscription: $topic");
    }
  }

  void disconnect() {
    client?.disconnect();
    isConnected = false;
    print("🔌 MQTT Disconnected");
  }
}
