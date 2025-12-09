import 'package:flutter/services.dart';
import 'readaloud_constants.dart';

class ReadAloud {
  static const MethodChannel _channel = MethodChannel(ReadAloudConstants.channelName);

  static Future<bool> speak({required String text}) async {
    try {
      final result = await _channel.invokeMethod(ReadAloudConstants.methodSpeak, {
        ReadAloudConstants.paramText: text,
      });
      return result as bool;
    } catch (e) {
      print('Error speaking: $e');
      return false;
    }
  }

  static Future<bool> stop() async {
    try {
      final result = await _channel.invokeMethod(ReadAloudConstants.methodStop);
      return result as bool;
    } catch (e) {
      print('Error stopping: $e');
      return false;
    }
  }

  static Future<bool> isSpeaking() async {
    try {
      final result = await _channel.invokeMethod(ReadAloudConstants.methodIsSpeaking);
      return result as bool;
    } catch (e) {
      print('Error checking speaking state: $e');
      return false;
    }
  }

  static Future<void> dispose() async {
    try {
      await _channel.invokeMethod(ReadAloudConstants.methodDispose);
    } catch (e) {
      print('Error disposing: $e');
    }
  }
}