import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import '../models/valve_model.dart';

class DashboardController with ChangeNotifier {
  final String brokerAddress;
  final int brokerPort;

  late MqttServerClient _client;
  bool _isConnected = false;
  Map<int, Valve> valves = {};
  String _connectionStatus = 'Disconnected';
  String? _errorMessage;

  // Subscription topics
  static const String statusTopic = 'tank/valve/+/status';
  static const String humidityTopic = 'tank/valve/+/humidity';
  static const String batteryTopic = 'tank/valve/+/battery';
  static const String flowTopic = 'tank/valve/+/flow';

  DashboardController({
    this.brokerAddress = '192.168.1.100',
    this.brokerPort = 1883,
  }) {
    _initializeMqtt();
  }

  bool get isConnected => _isConnected;
  String get connectionStatus => _connectionStatus;
  String? get errorMessage => _errorMessage;

  void _initializeMqtt() {
    _client = MqttServerClient(
        brokerAddress, 'flutter_app_${DateTime.now().millisecondsSinceEpoch}');
    _client.port = brokerPort;
    _client.keepAlivePeriod = 20;
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    _client.pongCallback = _onPong;
  }

  Future<void> connect() async {
    try {
      _setStatus('Connecting...');
      await _client.connect();
    } catch (e) {
      _setStatus('Connection failed');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _onConnected() {
    _isConnected = true;
    _setStatus('Connected');
    _errorMessage = null;
    _subscribeToTopics();
    notifyListeners();
  }

  void _onDisconnected() {
    _isConnected = false;
    _setStatus('Disconnected');
    notifyListeners();
  }

  void _onSubscribed(String topic) {
    debugPrint('Subscribed to: $topic');
  }

  void _onPong() {
    debugPrint('MQTT Pong received');
  }

  void _subscribeToTopics() {
    _client.subscribe(statusTopic, MqttQos.atLeastOnce);
    _client.subscribe(humidityTopic, MqttQos.atLeastOnce);
    _client.subscribe(batteryTopic, MqttQos.atLeastOnce);
    _client.subscribe(flowTopic, MqttQos.atLeastOnce);

    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (var message in messages) {
        _handleMessage(message);
      }
    });
  }

  void _handleMessage(MqttReceivedMessage<MqttMessage> message) {
    final MqttPublishMessage recMess = message.payload as MqttPublishMessage;
    final payload = utf8.decode(recMess.payload.message);

    debugPrint('Received on ${message.topic}: $payload');

    _parseAndUpdateValve(message.topic, payload);
  }

  void _parseAndUpdateValve(String topic, String payload) {
    // Example topics: tank/valve/3/status, tank/valve/3/humidity, etc.
    final parts = topic.split('/');
    if (parts.length < 4) return;

    try {
      final valveId = int.parse(parts[2]);
      final dataType = parts[3];

      if (!valves.containsKey(valveId)) {
        valves[valveId] = Valve(id: valveId);
      }

      final valve = valves[valveId]!;

      switch (dataType) {
        case 'status':
          valve.status = payload;
          valve.isConnected = true;
          break;
        case 'humidity':
          valve.humidity = double.tryParse(payload) ?? 0.0;
          break;
        case 'battery':
          valve.batteryLevel = double.tryParse(payload) ?? 0.0;
          break;
        case 'flow':
          valve.flowRate = double.tryParse(payload) ?? 0.0;
          break;
      }

      valve.lastUpdate = DateTime.now();
      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing message: $e');
    }
  }

  Future<void> sendCommand(int valveId, String command) async {
    if (!_isConnected) {
      _errorMessage = 'Not connected to MQTT broker';
      notifyListeners();
      return;
    }

    final topic = 'tank/valve/$valveId/cmd';
    final builder = MqttClientPayloadBuilder();
    builder.addString(command);
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    debugPrint('Sent command "$command" to valve $valveId');
  }

  Future<void> setFlowRate(int valveId, double flowRate) async {
    if (!_isConnected) {
      _errorMessage = 'Not connected to MQTT broker';
      notifyListeners();
      return;
    }

    final topic = 'tank/valve/$valveId/flow';
    final builder = MqttClientPayloadBuilder();
    builder.addString(flowRate.toStringAsFixed(1));
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    debugPrint('Set flow rate to $flowRate for valve $valveId');
  }

  Future<void> openValve(int valveId) => sendCommand(valveId, 'OPEN');
  Future<void> closeValve(int valveId) => sendCommand(valveId, 'CLOSE');

  void _setStatus(String status) {
    _connectionStatus = status;
  }

  Future<void> disconnect() async {
    _client.disconnect();
  }

  @override
  void dispose() {
    _client.disconnect();
    super.dispose();
  }
}
