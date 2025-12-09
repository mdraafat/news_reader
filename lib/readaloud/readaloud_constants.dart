class ReadAloudConstants {
  ReadAloudConstants._();

  static const String channelName = 'readaloud';

  static const String methodSpeak = 'speak';
  static const String methodStop = 'stop';
  static const String methodIsSpeaking = 'isSpeaking';
  static const String methodDispose = 'dispose';

  static const String paramText = 'text';

  static const String errorInvalidArguments = 'INVALID_ARGUMENTS';
  static const String errorTtsNotInitialized = 'TTS_NOT_INITIALIZED';
  static const String errorSpeakFailed = 'SPEAK_FAILED';
  static const String errorException = 'EXCEPTION';

  static const String tooltipStop = 'Stop Reading';
  static const String tooltipRead = 'Read Aloud';
  static const String snackbarFailedStart = 'Failed to start reading';
  static const String snackbarNoDescription = 'No description available to read';
}