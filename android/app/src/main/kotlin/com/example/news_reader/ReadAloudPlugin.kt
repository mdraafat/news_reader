package com.example.news_reader

import android.content.Context
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.util.*

class ReadAloudPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var textToSpeech: TextToSpeech? = null
    private var isTtsInitialized = false
    private var isSpeaking = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, ReadAloudConstants.CHANNEL_NAME)
        channel.setMethodCallHandler(this)

        initializeTts()
    }

    private fun initializeTts() {
        textToSpeech = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) {
                isTtsInitialized = true
                textToSpeech?.setLanguage(Locale.ENGLISH)
                textToSpeech?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                    override fun onStart(utteranceId: String?) {
                        isSpeaking = true
                    }

                    override fun onDone(utteranceId: String?) {
                        isSpeaking = false
                    }

                    override fun onError(utteranceId: String?) {
                        isSpeaking = false
                    }
                })
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            ReadAloudConstants.METHOD_SPEAK -> {
                val text = call.argument<String>(ReadAloudConstants.PARAM_TEXT)

                if (text == null) {
                    result.error(
                        ReadAloudConstants.ERROR_INVALID_ARGUMENTS,
                        ReadAloudConstants.ERROR_MSG_INVALID_ARGUMENTS,
                        null
                    )
                    return
                }

                speak(text, result)
            }
            ReadAloudConstants.METHOD_STOP -> {
                stop(result)
            }
            ReadAloudConstants.METHOD_IS_SPEAKING -> {
                result.success(isSpeaking)
            }
            ReadAloudConstants.METHOD_DISPOSE -> {
                dispose(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun speak(text: String, result: MethodChannel.Result) {
        if (!isTtsInitialized) {
            result.error(
                ReadAloudConstants.ERROR_TTS_NOT_INITIALIZED,
                ReadAloudConstants.ERROR_MSG_TTS_NOT_INITIALIZED,
                null
            )
            return
        }

        try {
            val speakResult = textToSpeech?.speak(
                text,
                TextToSpeech.QUEUE_FLUSH,
                null,
                ReadAloudConstants.UTTERANCE_ID
            )

            if (speakResult == TextToSpeech.SUCCESS) {
                result.success(true)
            } else {
                result.error(
                    ReadAloudConstants.ERROR_SPEAK_FAILED,
                    ReadAloudConstants.ERROR_MSG_SPEAK_FAILED,
                    null
                )
            }
        } catch (e: Exception) {
            result.error(ReadAloudConstants.ERROR_EXCEPTION, e.message, null)
        }
    }

    private fun stop(result: MethodChannel.Result) {
        try {
            val stopResult = textToSpeech?.stop()
            isSpeaking = false
            result.success(stopResult == TextToSpeech.SUCCESS)
        } catch (e: Exception) {
            result.error(ReadAloudConstants.ERROR_EXCEPTION, e.message, null)
        }
    }

    private fun dispose(result: MethodChannel.Result) {
        try {
            textToSpeech?.stop()
            textToSpeech?.shutdown()
            textToSpeech = null
            isTtsInitialized = false
            isSpeaking = false
            result.success(null)
        } catch (e: Exception) {
            result.error(ReadAloudConstants.ERROR_EXCEPTION, e.message, null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        textToSpeech?.shutdown()
    }
}