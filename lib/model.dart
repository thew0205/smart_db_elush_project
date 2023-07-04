// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:elushade_project/time_slot.dart';

String stateToString(int? state) {
  switch (state) {
    case 0:
      return "OFF";
    case 1:
      return "ON";
    default:
      return "INVALID";
  }
}

class ChannelModel {
  final int channel;
  final int state;

  ChannelModel(this.channel, this.state);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'channel': channel,
      'state': state,
    };
  }

  factory ChannelModel.fromMapEntry(MapEntry<String, dynamic> entry) {
    return ChannelModel(
      int.parse(entry.key),
      entry.value as int,
    );
  }

  factory ChannelModel.fromMap(Map<String, dynamic> map) {
    return ChannelModel(
      map['channel'] as int,
      map['state'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChannelModel.fromJson(String source) =>
      ChannelModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class ApiTemplate {
  final String ip;
  final List<ChannelModel> channels;
  final double currentReading;
  final bool userMode;
  final int currentTimeSlot;

  const ApiTemplate(
    this.ip,
    this.channels,
    this.currentReading,
    this.userMode,
    this.currentTimeSlot,
  );

  ApiTemplate copyWith({
    String? ip,
    List<ChannelModel>? channels,
    double? currentReading,
    bool? userMode,
    int? currentTimeSlot,
  }) {
    return ApiTemplate(
      ip ?? this.ip,
      channels ?? this.channels,
      currentReading ?? this.currentReading,
      userMode ?? this.userMode,
      currentTimeSlot ?? this.currentTimeSlot,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ip': ip,
      'channels': channels.map((x) => x.toMap()).toList(),
      'currentReading': currentReading,
      'userMode': userMode,
      'currentTimeSlot': currentTimeSlot,
    };
  }

  factory ApiTemplate.fromMap(Map<String, dynamic> map) {
    return ApiTemplate(
      map['ip'] as String,
      List<ChannelModel>.from(
        (map['channels'] as List<int>).map<ChannelModel>(
          (x) => ChannelModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      map['currentReading'] as double,
      map['userMode'] as bool,
      map['currentTimeSlot'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiTemplate.fromJson(String source) =>
      ApiTemplate.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ApiTemplate(ip: $ip, channels: $channels, currentReading: $currentReading, userMode: $userMode, currentTimeSlot: $currentTimeSlot)';
  }

  @override
  bool operator ==(covariant ApiTemplate other) {
    if (identical(this, other)) return true;

    return other.ip == ip &&
        listEquals(other.channels, channels) &&
        other.currentReading == currentReading &&
        other.userMode == userMode &&
        other.currentTimeSlot == currentTimeSlot;
  }

  @override
  int get hashCode {
    return ip.hashCode ^
        channels.hashCode ^
        currentReading.hashCode ^
        userMode.hashCode ^
        currentTimeSlot.hashCode;
  }
}

class ApiTemplateProvider extends StateNotifier<ApiTemplate> {
  ApiTemplateProvider(super.state);
  WebSocketChannel? channel;
  Future<bool> getConnection() async {
    try {
      final value =
          await http.get(Uri.parse("http://${state.ip}/get_channel_state"));
      final channelReadings = jsonDecode(value.body) as Map<String, dynamic>;
      state = state.copyWith(
          channels: channelReadings
              .cast<String, int>()
              .entries
              .map((entry) => ChannelModel.fromMapEntry(entry))
              .toList());
      if (value.statusCode == 200) {
        final wsUrl = Uri.parse('ws://${state.ip}:81');
        channel = WebSocketChannel.connect(wsUrl);
        channel?.stream.listen((message) {
          // channel.sink.add('received!');
          for (int i = 0; i < 6; i++) {
            // Serial.printf("time: %d:%d\t %d\r\n", timeSlots[i].from.hour, timeSlots[i].from.min, timeSlots[i].accumulatedUsage);
            // Serial.printf("time: %d:%d\t\r\n", getTimeBuff[2], getTimeBuff[1]);
            //  Serial.printf("time: %d:%d\t\r\n",getTimeBuff[2], getTimeBuff[1]);
            final date = DateTime.now();
            if (timeSlots[i]
                .timeInTimeSlot(TimeOfDay(min: date.minute, hour: date.hour))) {
              if (i != state.currentTimeSlot) {
                timeSlots[state.currentTimeSlot].accumulatedUsage = 0;
                state = state.copyWith(currentTimeSlot: i);
                timeSlots[state.currentTimeSlot].accumulatedUsage = 0;
              }
              if (timeSlots[state.currentTimeSlot].accumulatedUsage >
                  timeSlots[state.currentTimeSlot].nominalUsage) {
                changeState(255, 0);
              }
              // Serial.printf("time: %d:%d\t %d\r\n", timeSlots[i].from.hour, timeSlots[i].from.min, timeSlots[i].accumulatedUsage);
              // Serial.printf("time: %d:%d\t\r\n", getTimeBuff[2], getTimeBuff[1]);
              break;
            }
          }
          try {
            final readings = (jsonDecode(message) as Map<String, dynamic>);
            final channelReadings = readings["channel"] as Map<String, dynamic>;
            state = state.copyWith(
                currentReading: readings["reading"] as double,
                channels: channelReadings
                    .cast<String, int>()
                    .entries
                    .map((entry) => ChannelModel.fromMapEntry(entry))
                    .toList());
          } catch (e) {}

          print(message);
          timeSlots[state.currentTimeSlot].increaseUsage(state.currentReading);
          // channel.sink.close(goingAway);
        });
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  void close() {
    channel?.sink.close();
    setIp("");
  }

  void changeMode(bool userMode) {
    state = state.copyWith(userMode: userMode);
  }

  void setIp(String ip) {
    state = state.copyWith(ip: ip);
  }

  void changeState(int channel, int mode) async {
    try {
      final res = await http.post(Uri.parse(
          "http://${state.ip}/control_relays?channel=$channel&mode=$mode"));
      state = state.copyWith(
          channels: (jsonDecode(res.body) as Map<String, dynamic>)
              .cast<String, int>()
              .entries
              .map((entry) => ChannelModel.fromMapEntry(entry))
              .toList());
    } catch (e) {}
  }
}

final apiProvider =
    StateNotifierProvider.autoDispose<ApiTemplateProvider, ApiTemplate>((ref) {
  final provider = ApiTemplateProvider(const ApiTemplate("", [], 0, false, 0));
  ref.onDispose(() {
    provider.dispose();
  });
  return provider;
});
