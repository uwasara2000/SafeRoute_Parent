import 'dart:js_interop';

@JS('window.SAFEROUTE_GOOGLE_MAPS_READY')
external JSBoolean? get _googleMapsReady;

bool get isGoogleMapsApiAvailable => _googleMapsReady?.toDart ?? false;
