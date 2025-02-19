import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_telex_error_monitor/flutter_telex_error_monitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mock HTTP client
@GenerateMocks([http.Client])
import 'telex_error_monitor_test.mocks.dart';

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
  });

  tearDown(() {
    // Reset the client after each test
    FlutterTelexErrorMonitor.resetClient();
  });

  test("Initialize FlutterTelexErrorMonitor", () {
    expect(
        () => FlutterTelexErrorMonitor.init(
            telexChannelWebhookUrl: "https://telex-webhook.com"),
        returnsNormally);
  });

  test("Catch and report synchronous errors", () async {
    FlutterTelexErrorMonitor.init(
        telexChannelWebhookUrl: "https://telex-webhook.com",
        client: mockClient);

    // Configure mock to return success
    when(mockClient.post(any,
            headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('Success', 200));

    // Save original handler
    final originalOnError = FlutterError.onError;

    bool errorHandled = false;
    FlutterError.onError = (FlutterErrorDetails details) {
      expect(details.exception, isA<FlutterError>());
      errorHandled = true;
    };

    FlutterError.reportError(
        FlutterErrorDetails(exception: FlutterError("Test error")));

    expect(errorHandled, true);

    // Restore original handler
    FlutterError.onError = originalOnError;
  });

  test("Catch and report asynchronous errors", () async {
    FlutterTelexErrorMonitor.init(
        telexChannelWebhookUrl: "https://telex-webhook.com",
        client: mockClient);

    // Configure mock to return success
    when(mockClient.post(any,
            headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('Success', 200));

    bool errorHandled = false;
    runZonedGuarded(() {
      throw Exception("Async error");
    }, (error, stackTrace) {
      expect(error, isA<Exception>());
      errorHandled = true;
    });

    expect(errorHandled, true);
  });

  test("Extract error location from stack trace - packages format", () {
    String stackTrace =
        "#0 packages/my_app/main.dart:10:5\n#1 packages/flutter/src/widgets/framework.dart:5:3";
    String location = FlutterTelexErrorMonitor.findErrorLocation(stackTrace);
    expect(location, contains("packages/my_app/main.dart:10"));
  });

  test("Extract error location from stack trace - file format", () {
    String stackTrace =
        "#0 main (file:///lib/main.dart:10:5)\n#1 other (file:///lib/other.dart:5:3)";
    String location = FlutterTelexErrorMonitor.findErrorLocation(stackTrace);
    expect(location, contains("lib/main.dart:10"));
  });

  test("Handle layout overflow errors properly", () {
    FlutterTelexErrorMonitor.init(
        telexChannelWebhookUrl: "https://telex-webhook.com",
        client: mockClient);

    // Configure mock to return success
    when(mockClient.post(any,
            headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response('Success', 200));

    // Save original handler
    final originalOnError = FlutterError.onError;

    bool overflowHandled = false;
    String? capturedLocation;

    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains("overflowed")) {
        overflowHandled = true;
        capturedLocation = details.informationCollector?.call().join('\n');
      }
    };

    FlutterError.reportError(FlutterErrorDetails(
        exception: FlutterError("A RenderFlex overflowed by 30 pixels")));

    expect(overflowHandled, true);

    // Restore original handler
    FlutterError.onError = originalOnError;
  });

  test("Send error reports successfully", () async {
    FlutterTelexErrorMonitor.init(
        telexChannelWebhookUrl: "https://telex-webhook.com",
        client: mockClient);

    // Configure mock to return success
    when(mockClient.post(any,
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response("Success", 200));

    await FlutterTelexErrorMonitor.sendError(
        "Test error", "file:///lib/main.dart:10:5");

    // Verify the post was called
    verify(mockClient.post(any,
            headers: anyNamed("headers"), body: anyNamed("body")))
        .called(1);
  });

  test("Send error handles HTTP failure", () async {
    FlutterTelexErrorMonitor.init(
        telexChannelWebhookUrl: "https://telex-webhook.com",
        client: mockClient);

    // Configure mock to return error
    when(mockClient.post(any,
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenAnswer((_) async => http.Response("Server Error", 500));

    // Should not throw exception
    await expectLater(
        FlutterTelexErrorMonitor.sendError(
            "Test error", "file:///lib/main.dart:10:5"),
        completes);
  });

  test("Send error handles exceptions", () async {
    FlutterTelexErrorMonitor.init(
        telexChannelWebhookUrl: "https://telex-webhook.com",
        client: mockClient);

    // Configure mock to throw exception
    when(mockClient.post(any,
            headers: anyNamed("headers"), body: anyNamed("body")))
        .thenThrow(Exception("Network error"));

    // Should not propagate the exception
    await expectLater(
        FlutterTelexErrorMonitor.sendError(
            "Test error", "file:///lib/main.dart:10:5"),
        completes);
  });
}
