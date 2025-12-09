package com.example.news_reader

object ReadAloudConstants {
    const val CHANNEL_NAME = "readaloud"

    const val METHOD_SPEAK = "speak"
    const val METHOD_STOP = "stop"
    const val METHOD_IS_SPEAKING = "isSpeaking"
    const val METHOD_DISPOSE = "dispose"

    const val PARAM_TEXT = "text"

    const val ERROR_INVALID_ARGUMENTS = "INVALID_ARGUMENTS"
    const val ERROR_TTS_NOT_INITIALIZED = "TTS_NOT_INITIALIZED"
    const val ERROR_SPEAK_FAILED = "SPEAK_FAILED"
    const val ERROR_EXCEPTION = "EXCEPTION"

    const val ERROR_MSG_INVALID_ARGUMENTS = "Text is required"
    const val ERROR_MSG_TTS_NOT_INITIALIZED = "TextToSpeech is not initialized"
    const val ERROR_MSG_SPEAK_FAILED = "Failed to speak text"

    const val UTTERANCE_ID = "utteranceId"
}