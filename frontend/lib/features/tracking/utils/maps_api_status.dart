import 'maps_api_status_stub.dart'
    if (dart.library.js_interop) 'maps_api_status_web.dart' as platform;

bool get isGoogleMapsApiAvailable => platform.isGoogleMapsApiAvailable;
