# saferoute_parent

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


go run in browser

flutter pub get
flutter run -d chrome

This is a Flutter widget-lifecycle assertion, not a Firebase credentials or backend .env error. It means Flutter tried to remove an inherited widget while another widget still depended on it.

In the app you launched, navigation is handled in two places: the auth-state gate in main.dart reacts to sign-in/sign-out, while login_screen.dart and profile_screen.dart also change routes manually. Those overlapping route changes are a possible trigger, but the screenshot doesn’t include enough of the stack trace to confirm the exact cause.

Please share the full error output below that red message and what you were doing when it appeared—such as tapping a tab, logging in, or signing out. That will identify the specific widget or navigation call responsible.