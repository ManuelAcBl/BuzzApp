package com.manuelacbl.buzz_app.buzzers

data class BuzzDeviceAttachedPacket(
    val attached: BuzzDevice,
)

data class BuzzDevice(
    val id: Int,
    val vendorId: Int,
    val productId: Int,
    val serial: String?
)

data class BuzzDeviceDetachedPacket(
    val detached: BuzzId,
)

data class BuzzId(
    val id: Int,
)

data class BuzzDeviceInputPacket(
    val input: Input,
)

data class Input(
    val device: Int,
    val bytes: String,
)
