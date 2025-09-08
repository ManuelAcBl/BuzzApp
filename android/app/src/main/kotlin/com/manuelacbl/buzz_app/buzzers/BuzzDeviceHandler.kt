package com.manuelacbl.buzz_app.buzzers

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.ContentValues.TAG
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbManager
import android.hardware.usb.UsbRequest
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import androidx.core.content.ContextCompat.registerReceiver
import com.google.gson.Gson
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.nio.ByteBuffer
import java.util.LinkedList
import java.util.Queue
import java.util.concurrent.ConcurrentHashMap

class BuzzDeviceHandler : FlutterPlugin, EventChannel.StreamHandler, BroadcastReceiver(), MethodChannel.MethodCallHandler {
    private lateinit var context: Context
    private lateinit var ACTION_USB_PERMISSION: String
    private lateinit var manager: UsbManager

    private var eventSink: EventChannel.EventSink? = null

    private val jobs = ConcurrentHashMap<BuzzDevice, Job>()
    private val connections = ConcurrentHashMap<BuzzDevice, UsbDeviceConnection>()

    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        EventChannel(binding.binaryMessenger, "usb_events").setStreamHandler(this)
        MethodChannel(binding.binaryMessenger, "usb_commands").setMethodCallHandler(this)

        context = binding.applicationContext
        ACTION_USB_PERMISSION = "${context.packageName}.USB_PERMISSION"
        manager = context.getSystemService(Context.USB_SERVICE) as UsbManager

        checkConnectedDevices()

        val filter = IntentFilter().apply {
            addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
            addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
            addAction(ACTION_USB_PERMISSION)
        }

        registerReceiver(
            context, this, filter, ContextCompat.RECEIVER_NOT_EXPORTED
        )
    }

    private fun checkConnectedDevices() {
        Log.d(TAG, "CONNECTED DEVICES:")

        manager.deviceList.values.forEach { device ->
            Log.d(TAG, "CONNECTED DEVICE: ${device.deviceName}")

            if (manager.hasPermission(device)) {
                startReading(device)
            } else {
                requestPermission(device)
            }
        }
    }

    private fun requestPermission(device: UsbDevice) {
        Log.d(TAG, "Requesting permission for device '${device.deviceName}'...")

        val intent = PendingIntent.getBroadcast(
            context, 0, Intent(ACTION_USB_PERMISSION).setPackage(context.packageName), PendingIntent.FLAG_MUTABLE,
        )

        manager.requestPermission(device, intent)
    }

    private fun stopReadingAll() {
        jobs.apply {
            values.forEach { it.cancel() }
            clear()
        }

        connections.clear()
    }

    private fun stopReading(device: UsbDevice) {
        device.apply {
            eventSink?.success(
                Gson().toJson(
                    BuzzDeviceDetachedPacket(
                        detached = BuzzId(id = deviceId)
                    )
                )
            )
        }

        jobs.keys.firstOrNull { it.id == device.deviceId }?.let {
            jobs[it]?.cancel()
            jobs.remove(it)
            connections.remove(it)
        }

    }

    private fun write(deviceId: Int, data: ByteArray): Boolean {
        val device = manager.deviceList.values.firstOrNull { it.deviceId == deviceId } ?: return false
        val buzz = connections.keys.firstOrNull { it.id == deviceId } ?: return false



        CoroutineScope(Dispatchers.IO).launch {

            val connection = connections[buzz] ?: return@launch

            for (i in 0 until device.interfaceCount) {
                val usbInterface = device.getInterface(i)
                for (j in 0 until usbInterface.endpointCount) {
                    val endpoint = usbInterface.getEndpoint(j)
                    when (endpoint.direction) {
                        UsbConstants.USB_DIR_IN -> {
                            Log.d(TAG, "INPUT: Interface: ${i}, Endpoint: $j")
                        }

                        UsbConstants.USB_DIR_OUT -> {
                            Log.d(TAG, "OUTPUT: Interface: ${i}, Endpoint: $j")
                        }
                    }
                }
            }

            val usbInterface = device.getInterface(0)

            if (!connection.claimInterface(usbInterface, true)) {
                connection.close()
                return@launch
            }

            val endpoint = usbInterface.getEndpoint(0)

            Log.d(TAG, "WRITE DATA: ${
                data.joinToString("") {
                    String.format("%8s", Integer.toBinaryString(it.toInt() and 0xFF)).replace(' ', '0')
                }
            }")

            connection.bulkTransfer(endpoint, data, data.size, 1000)

            val request = UsbRequest()
            request.initialize(connection, endpoint)
            request.queue(ByteBuffer.wrap(data), data.size)
            connection.requestWait()
        }

        return true
    }

    private fun startReading(device: UsbDevice) {
        val buzz = BuzzDevice(
            device.deviceId,
            device.vendorId,
            device.productId,
            device.serialNumber,
        )

        eventSink?.success(
            Gson().toJson(
                BuzzDeviceAttachedPacket(
                    attached = buzz
                )
            )
        )

        jobs[buzz] = CoroutineScope(Dispatchers.IO).launch {
            val connection = manager.openDevice(device) ?: return@launch
            val usbInterface = device.getInterface(0)
            val endpoint = usbInterface.getEndpoint(0) ?: return@launch

            if (!connection.claimInterface(usbInterface, true)) {
                connection.close()
                return@launch
            }

            connections[buzz] = connection

            val buffer = ByteArray(endpoint.maxPacketSize)

            try {
                while (isActive) {
                    val bytesRead = connection.bulkTransfer(endpoint, buffer, buffer.size, 100) // Timeout de 100ms
                    if (bytesRead > 0) {
                        val data = buffer.copyOfRange(0, bytesRead).apply { reverse() }

                        val binaryString = data.joinToString("") {
                            String.format("%8s", Integer.toBinaryString(it.toInt() and 0xFF)).replace(' ', '0')
                        }

                        withContext(Dispatchers.Main) {
                            eventSink?.success(
                                Gson().toJson(
                                    BuzzDeviceInputPacket(Input(device.deviceId, binaryString))
                                )
                            )
                        }
                    }
                }
            } finally {
                connection.releaseInterface(usbInterface)
                connection.close()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        binding.applicationContext.unregisterReceiver(this)
        stopReadingAll()
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events

        jobs.forEach {
            eventSink?.success(
                Gson().toJson(
                    BuzzDeviceAttachedPacket(
                        attached = it.key
                    )
                )
            )
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        stopReadingAll()
    }

    override fun onReceive(context: Context, intent: Intent) {
        val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
        } else {
            @Suppress("DEPRECATION") intent.getParcelableExtra(UsbManager.EXTRA_DEVICE) as UsbDevice?
        } ?: return

        Log.d(TAG, "ONRECEIVE: ${intent.action}")

        when (intent.action) {
            UsbManager.ACTION_USB_DEVICE_ATTACHED -> {
                if (manager.hasPermission(device)) {
                    startReading(device)
                } else {
                    requestPermission(device)
                }
            }

            UsbManager.ACTION_USB_DEVICE_DETACHED -> stopReading(device)

            ACTION_USB_PERMISSION -> {
                if (!manager.hasPermission(device)) {
                    Log.d(TAG, "USB DEVICE PERMISSION DENIED")
                    return
                }

                startReading(device)
            }

            else -> Log.d(TAG, "UNKNOWN ACTION: ${intent.action}")
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "output" -> {
                val deviceId = call.argument<Int>("id") ?: return
                val data = call.argument<ByteArray>("bytes") ?: return

                val write = write(deviceId, data)
                result.success(write)
            }

            else -> result.notImplemented()
        }
    }
}
