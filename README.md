# Flutter Telex Error Monitor

A Flutter package that automatically captures application errors and exceptions at runtime and forwards them to Telex channels. By integrating with a FastAPI backend, it provides real-time error monitoring and reporting for Flutter applications, helping developers quickly identify and resolve issues through their Telex workspace.

## Features

- Automatic capture of Flutter framework errors through `FlutterError.onError`
- Capture of asynchronous errors using `runZonedGuarded`
- Specialized handling of layout overflow errors with detailed diagnostics
- Intelligent error location extraction from stack traces
- Custom handling for network-related errors (SocketException, ClientException, DNS errors)
- Automatic error reporting to Telex channels

## Getting Started

1. Before installing the package, you need to set up a Telex channel:
    - Create an account with [telex.im](https://telex.im)
    - Click on the first tab with your initials to create an organization
    - Go to the "Channels" tab and add a channel
    - In your channel, click the arrow-down button beside your channel name
    - Select "Webhook Configuration"
    - Copy your webhook URL - you'll need this for initialization

2. Add the package to your `pubspec.yaml`:
```yaml
dependencies:
  flutter_telex_error_monitor: ^0.0.4
```

3. Run:
```bash
flutter pub get
```

4. Import and initialize in your main.dart:
```dart
import 'package:flutter_telex_error_monitor/flutter_telex_error_monitor.dart';

void main() {
  FlutterTelexErrorMonitor.init(
    telexChannelWebhookUrl: "YOUR_TELEX_WEBHOOK_URL",
    appName: "YOUR_FLUTTER_APP_NAME", // Optional
  );
  runApp(MyApp());
}
```

## Usage

The package works automatically after initialization. When errors occur in your application, they'll be captured and sent to your configured Telex channel.

For more details, see:
- [Installation Guide](https://pub.dev/packages/flutter_telex_error_monitor/install)
- [Example Usage](https://pub.dev/packages/flutter_telex_error_monitor/example)
- [Changelog](https://pub.dev/packages/flutter_telex_error_monitor/changelog)

## Error Types Handled

- Flutter framework errors
- Asynchronous errors outside the widget tree
- Layout overflow errors (with enhanced diagnostics)
- Network and HTTP errors
- Type errors and null safety violations

## Technical Requirements

- Flutter SDK
- HTTP package for network requests
- Internet permission in your Android/iOS app
- A Telex channel with webhook URL

## Limitations

- Requires an active network connection to report errors
- Some system-level errors may not be captured

## Support

For issues and feature requests, please file an issue on the GitHub repository.