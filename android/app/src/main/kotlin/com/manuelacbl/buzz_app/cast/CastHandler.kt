package com.manuelacbl.buzz_app.cast

import android.app.Presentation
import android.content.Context
import android.content.Context.DISPLAY_SERVICE
import android.content.Intent
import android.hardware.display.DisplayManager
import android.hardware.display.DisplayManager.DisplayListener
import android.media.MediaRouter
import android.os.Bundle
import android.provider.Settings
import android.view.Display
import android.widget.FrameLayout
import com.google.gson.Gson
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class CastHandler(private val context: Context) : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler,
    DisplayListener {
    private lateinit var router: MediaRouter
    private lateinit var manager: DisplayManager

    private var sink: EventChannel.EventSink? = null

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private var presentations: MutableMap<Int, FlutterPresentation> = mutableMapOf()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext

        router = context.getSystemService(Context.MEDIA_ROUTER_SERVICE) as MediaRouter
        manager = context.getSystemService(DISPLAY_SERVICE) as DisplayManager

        val messenger = binding.binaryMessenger
        val parent: CastHandler = this

        methodChannel = MethodChannel(messenger, "cast_methods").apply { setMethodCallHandler(parent) }
        eventChannel = EventChannel(messenger, "cast_events").apply { setStreamHandler(parent) }
    }

    private fun start(display: Display) {
        presentations += display.displayId to FlutterPresentation(
            plugin = this,
            context = context,
            display = display
        ).apply { show() }
    }

    private fun stop(display: Display) {
        presentations[display.displayId]?.dismiss()
        presentations.remove(display.displayId)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        manager.unregisterDisplayListener(this)

        for (presentation in presentations.values) presentation.dismiss()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "list" -> {
                result.success(
                    Gson().toJson(
                        DisplayListPacket(
                            list = manager.displays.filter { it.displayId != 0 }.map {
                                DisplayPacket(
                                    id = it.displayId,
                                    name = it.name,
                                    width = it.mode.physicalWidth,
                                    height = it.mode.physicalHeight,
                                    active = presentations.containsKey(it.displayId),
                                )
                            },
                        )
                    )
                )
            }

            "start" -> {
                val displayId: Int = call.argument<Int>("displayId")!!

                if (presentations.containsKey(displayId)) {
                    result.error("PRESENTATION_ACTIVE", "Presentation active", null)
                    return
                }

                val display = manager.getDisplay(displayId)

                if (display == null) {
                    result.error("DISPLAY_NOT_FOUND", "Display not found", null)
                    return
                }

                start(display)

                onDisplayChanged(displayId)

                result.success(true)
            }

            "stop" -> {
                val displayId: Int = call.argument<Int>("displayId")!!

                if (!presentations.containsKey(displayId)) {
                    result.error("PRESENTATION_NOT_FOUND", "Presentation not found", null)
                    return
                }

                stop(manager.getDisplay(displayId))

                onDisplayChanged(displayId)

                result.success(true)
            }

            "settings" -> context.startActivity(Intent(Settings.ACTION_CAST_SETTINGS))

            "data" -> sink?.success(Gson().toJson(DataPacket(data = call.arguments)))

            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {


        sink = events

        manager.registerDisplayListener(this, null)

        sink?.success(Gson().toJson(DisplayListPacket(
            list = manager.displays.filter { it.displayId != 0 }.map {
                DisplayPacket(
                    id = it.displayId,
                    name = it.name,
                    width = it.mode.physicalWidth,
                    height = it.mode.physicalHeight,
                    active = presentations.containsKey(it.displayId),
                )
            },
        )
        )
        )
    }

    override fun onCancel(arguments: Any?) {
        sink = null
        manager.unregisterDisplayListener(this)
    }

    override fun onDisplayAdded(displayId: Int) {
        val display = manager.getDisplay(displayId) ?: return

        sink?.success(
            Gson().toJson(
                DisplayAddPacket(
                    add = DisplayPacket(
                        id = display.displayId,
                        name = display.name,
                        width = display.mode.physicalWidth,
                        height = display.mode.physicalHeight,
                        active = presentations.containsKey(displayId)
                    )
                )
            )
        )

    }

    override fun onDisplayRemoved(displayId: Int) {
        val display = manager.getDisplay(displayId) ?: return

        sink?.success(Gson().toJson(DisplayRemovePacket(remove = display.displayId)))
    }

    override fun onDisplayChanged(displayId: Int) {
        val display = manager.getDisplay(displayId) ?: return

        sink?.success(
            Gson().toJson(
                DisplayChangePacket(
                    change = DisplayPacket(
                        id = display.displayId,
                        name = display.name,
                        width = display.mode.physicalWidth,
                        height = display.mode.physicalHeight,
                        active = presentations.containsKey(displayId)
                    )
                )
            )
        )
    }
}

data class DataPacket(
    val data: Any?
)

data class DisplayChangePacket(
    val change: DisplayPacket,
)

data class DisplayRemovePacket(
    val remove: Int,
)

data class DisplayAddPacket(
    val add: DisplayPacket,
)

data class DisplayListPacket(
    val list: List<DisplayPacket>,
)

data class DisplayPacket(
    val id: Int, val name: String, val width: Int, val height: Int, val active: Boolean,
)

class FlutterPresentation(private val plugin: CastHandler, context: Context, display: Display) : Presentation(context, display) {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val engine = FlutterEngine(context).apply {
            val path = FlutterInjector.instance().flutterLoader().findAppBundlePath()

            val entrypoint = DartExecutor.DartEntrypoint(path, "castMain")

            plugins.add(plugin)

            dartExecutor.executeDartEntrypoint(entrypoint)
            lifecycleChannel.appIsResumed()

            FlutterEngineCache.getInstance().put("presentation", this)
        }

        val frame = FrameLayout(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            )

            addView(FlutterView(context).apply { attachToFlutterEngine(engine) })
        }

        setContentView(frame)
    }
}