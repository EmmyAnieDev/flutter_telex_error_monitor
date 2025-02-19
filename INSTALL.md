# Installation Guide

## Step 1: Set up Telex

Before installing the package, you need to set up a Telex channel:

1. Create an account with [telex.im](https://telex.im)
2. Click on the first tab with your initials to create an organization
3. Go to the "Channels" tab and add a channel
4. In your channel, click the arrow-down button beside your channel name and click on "Webhook Configuration"
5. Copy your webhook URL - you'll need this for initialization

## Step 2: Add the package to your project

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_error_checker: ^0.0.2
```

Then run:

```bash
flutter pub get
```

## Step 3: Configure permissions

### Android

Add the following permission to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS

No additional configuration needed for network permissions.

## Step 4: Initialize the monitor

In your main.dart:

```dart
import 'package:flutter_error_checker/flutter_telex_error_monitor.dart';

void main() {
  // Initialize the error monitor before runApp
  FlutterTelexErrorMonitor.init(
    telexChannelWebhookUrl: "YOUR_TELEX_WEBHOOK_URL", // From Step 1
    appName: "YOUR_FLUTTER_APP_NAME",  // Optional
  );
  
  runApp(MyApp());
}
```

## Step 5: Verify installation

1. Run your application
2. Trigger a test error (for example, try to access a null value)
3. Check your Telex channel - you should see the error report appear

## Configuration Options

The `init` method accepts the following parameters:

- `telexChannelWebhookUrl` (required): Your Telex channel webhook URL
- `appName` (optional): Custom name to identify your app in error reports

## Environment Variables (Optional)

For better security, consider storing your webhook URL as an environment variable:

```dart
FlutterTelexErrorMonitor.init(
  telexChannelWebhookUrl: const String.fromEnvironment('TELEX_WEBHOOK_URL'),
  appName: const String.fromEnvironment('APP_NAME', defaultValue: 'My Flutter App'),
);
```

## Troubleshooting

If errors aren't appearing in your Telex channel:

1. Verify your webhook URL is correct
2. Check internet connectivity
3. Ensure you've initialized the monitor before `runApp()`
4. Verify your Telex channel and organization are active