import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_telex_error_monitor/config.dart';
import 'package:http/http.dart' as http;

/// A utility class for catching and reporting Flutter runtime errors to an external API.
class FlutterTelexErrorMonitor {
  /// The server endpoint URL to which error logs are sent.
  static const String _errorLogUrl = "$backendURL/api/v1/submit-error";

  /// Add Telex channel Webhook URL configuration
  static String? _telexChannelWebhookUrl;

  /// Add App Name configuration
  static String? _appName;

  /// HTTP client for making requests - can be injected for testing
  static http.Client _client = http.Client();

  /// Initializes the error checker by setting up global error handlers.
  static void init({
    required String telexChannelWebhookUrl,
    String? appName,
    http.Client? client,
  }) {
    // Store the organization's Telex channel Webhook URL
    _telexChannelWebhookUrl = telexChannelWebhookUrl;
    // Store the Application Name and fallback to "Flutter App" if not provided
    _appName = appName ?? 'My Flutter App';
    // Set custom HTTP client if provided (for testing)
    if (client != null) {
      _client = client;
    }

    // Set up the error handler for Flutter framework errors.
    FlutterError.onError = (FlutterErrorDetails details) {
      // Start with a default error location.
      String errorLocation = 'Location not found';
      // Convert the caught exception to a string message.
      String errorMessage = details.exceptionAsString();

      // Special handling for layout overflow errors
      if (details.exception is FlutterError &&
          errorMessage.contains('overflowed')) {
        errorLocation =
            'Layout Overflow - Check your Row/Column/Container widgets for unbounded width/height in your current initialized screen';

        // Extract overflow amount
        final RegExp overflowRegex = RegExp(r'overflowed by ([\d.]+) pixels');
        final match = overflowRegex.firstMatch(errorMessage);
        if (match != null) {
          final overflowAmount = match.group(1);
          errorLocation += '\nOverflow amount: $overflowAmount pixels';
        }
      } else {
        // Extract error location from stack trace
        errorLocation = findErrorLocation(details.stack.toString());
      }

      // Send error to server
      sendError(errorMessage, errorLocation);
    };

    // Set up a global error handler for asynchronous errors.
    runZonedGuarded<void>(
      () => {},
      (error, stackTrace) {
        // Convert the caught error into a string message.
        String errorMessage = error.toString();
        // Determine the error location from the stack trace.
        String errorLocation = findErrorLocation(stackTrace.toString());

        // Customize error message for specific error types
        if (error is SocketException) {
          errorMessage = 'Network Error: ${error.message}';
        } else if (error is http.ClientException) {
          errorMessage = 'HTTP Error: ${error.toString()}';
        } else if (errorMessage.contains('Failed host lookup')) {
          errorMessage = 'DNS Error: Unable to resolve host';
        }

        // Refine error location from stack trace
        final stackLines = stackTrace.toString().split('\n');
        for (var line in stackLines) {
          // Look for app code in stack trace
          if (line.contains('packages/') &&
              !line.contains('packages/flutter/') &&
              !line.contains('packages/http/') &&
              !line.contains('dart-sdk/')) {
            errorLocation = line.trim();
            break;
          }
        }

        // Send the asynchronous error to the server.
        sendError(errorMessage, errorLocation);
      },
    );

    // Log initialization
    if (kDebugMode) {
      debugPrint(
          "FlutterTelexErrorMonitor initialized. Errors will be sent to your Telex's channel.");
    }
  }

  /// Extracts a probable error location from a given [stackTrace] string.
  static String findErrorLocation(String stackTrace) {
    // Split the stack trace into individual lines.
    final lines = stackTrace.split('\n');

    // Check for the first occurrence of the error in `package:test_app`
    for (var line in lines) {
      if (line.contains('package:test_app') && line.contains('.dart:')) {
        // Extract the clean location (remove function names)
        final match = RegExp(r'\((.*\.dart:\d+:\d+)\)').firstMatch(line);
        if (match != null) {
          return match
              .group(1)!; // Extracts only "test_app/home_page.dart:XX:YY"
        }
        return line.trim(); // Fallback
      }
    }

    // If no direct package location is found, look for `packages/`
    for (var line in lines) {
      if (line.contains('packages/') &&
          !line.contains('packages/flutter/') &&
          !line.contains('packages/http/') &&
          !line.contains('dart-sdk/')) {
        return line.trim();
      }
    }

    // If still no match, try the `file:///` format
    for (var line in lines) {
      if (line.contains('file:///') && line.contains('lib/')) {
        return line.trim();
      }
    }

    return 'Location not found';
  }

  /// Sends the error details to the configured server endpoint.
  static Future<void> sendError(String error, String stackTrace) async {
    try {
      // Standardize the error message format
      String formattedError = formatErrorMessage(error);

      // Check if it's an Overflow Error
      bool isOverflowError = error.contains('overflowed by');

      // Check if it's an HTTP/Network error
      bool isHttpError = error.contains('Failed host lookup') ||
          error.contains('SocketException') ||
          error.contains('HTTP request failed') ||
          error.contains('ClientException');

      // Set location based on error type
      String formattedLocation;
      if (isOverflowError) {
        formattedLocation =
            'Layout Overflow - Check Row/Column/Container widgets for unbounded width/height for the initialized screen';
      } else if (isHttpError) {
        formattedLocation =
            'Network Error - Check API URL, internet connection, or server response';
      } else {
        formattedLocation = findErrorLocation(stackTrace);
      }

      // Prepare the payload for Telex
      final response = await _client.post(
        Uri.parse(_errorLogUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'error': formattedError,
          'app_name': _appName,
          'telex_channel_webhook_Url': _telexChannelWebhookUrl,
          'location': formattedLocation,
        }),
      );

      // Log response status
      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint("✅ Error sent to Telex successfully.");
        }
      } else {
        if (kDebugMode) {
          debugPrint(
              "❌ Failed to send error: ${response.statusCode} - ${response.body}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("❌ Failed to send error: $e");
      }
    }
  }

  /// Formats the error message to ensure consistency across platforms.
  static String formatErrorMessage(String error) {
    // Remove unnecessary prefixes like "Exception: "
    error = error.replaceAll(RegExp(r'Exception: '), '').trim();

    // Remove unwanted quotes from errors like 'John'
    if (error.startsWith("'") && error.endsWith("'")) {
      error = error.substring(1, error.length - 1);
    }

    // Handle JSON errors by keeping only the relevant message
    if (error.contains('JSON')) {
      error = error.split(' at position')[0].trim();
    }

    return error;
  }

  /// For testing: reset the client to default
  @visibleForTesting
  static void resetClient() {
    _client = http.Client();
  }
}
