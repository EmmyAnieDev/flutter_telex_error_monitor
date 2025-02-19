# Examples

## Basic Initialization

```dart
import 'package:flutter/material.dart';
import 'package:flutter_telex_error_monitor/flutter_telex_error_monitor.dart';

void main() {
  // Initialize error monitoring
  FlutterTelexErrorMonitor.init(
    telexChannelWebhookUrl: "YOUR_TELEX_WEBHOOK_URL",
    appName: "YOUR_FLUTTER_APP_NAME",
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error Monitor Example',
      home: HomePage(),
    );
  }
}
```

## Triggering Different Error Types

```dart
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? nullString;
  
  void _triggerNullError() {
    // This will trigger a null safety error
    print(nullString!.length);
  }
  
  void _triggerAsyncError() async {
    await Future.delayed(Duration(seconds: 1));
    throw Exception('Async error example');
  }
  
  void _triggerNetworkError() async {
    try {
      final response = await http.get(Uri.parse('https://invalid-url.example'));
      print(response.body);
    } catch (e) {
      // Error will be caught and reported automatically
      rethrow;
    }
  }
  
  void _triggerOverflowError() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OverflowErrorPage()),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Error Monitor Examples')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _triggerNullError,
              child: Text('Trigger Null Error'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _triggerAsyncError,
              child: Text('Trigger Async Error'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _triggerNetworkError,
              child: Text('Trigger Network Error'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _triggerOverflowError,
              child: Text('Trigger Layout Overflow'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Layout Overflow Example

```dart
class OverflowErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Overflow Example')),
      body: Container(
        width: 200,
        child: Row(
          children: [
            // This will cause an overflow error
            Text('Very long text that will overflow its container ' * 10),
          ],
        ),
      ),
    );
  }
}
```

## Error Message Format

When an error occurs, you'll see a message like this in your Telex channel:

```
=== Error Report ===
Error: TypeError: "{\"name\": \"John\", \"age\": 25, \"hobbies\": [\"reading\", \"gaming\"]}": type 'String' is not a subtype of type 'User'
Location: packages/test_app/second_screen.dart 35:26  [_triggerError]
==================
```

## Comprehensive Error Testing

```dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_telex_error_monitor/flutter_telex_error_monitor.dart';

void main() {
  FlutterTelexErrorMonitor.init(
    telexChannelWebhookUrl: "YOUR_TELEX_WEBHOOK_URL",
    appName: "YOUR_FLUTTER_APP_NAME",
  );
  
  runApp(MaterialApp(
    home: ErrorTestApp(),
  ));
}

class ErrorTestApp extends StatefulWidget {
  @override
  _ErrorTestAppState createState() => _ErrorTestAppState();
}

class _ErrorTestAppState extends State<ErrorTestApp> {
  int _counter = 0;
  String? nullString;
  
  @override
  void initState() {
    super.initState();
    // Test async init error after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      throw Exception('Async initialization error');
    });
  }
  
  void _incrementAndError() {
    setState(() {
      _counter++;
      
      // Different errors based on counter value
      switch (_counter) {
        case 1:
          // Force exception
          throw Exception('Manual exception');
        
        case 2:
          // Type error
          dynamic notANumber = "123";
          int result = notANumber * 2;
          break;
          
        case 3:
          // Null safety error
          print(nullString!.length);
          break;
          
        case 4:
          // HTTP error
          _fetchInvalidData();
          break;
          
        case 5:
          // JSON parsing error
          json.decode("{invalid: json}");
          break;
          
        case 6:
          // Division by zero
          print(100 ~/ (_counter - 6));
          break;
          
        case 7:
          // Navigate to overflow page
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => OverflowPage()),
          );
          break;
      }
    });
  }
  
  Future<void> _fetchInvalidData() async {
    await http.get(Uri.parse('https://invalid-url.example'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Error Monitor Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Press the button to trigger different errors'),
            Text('Current count: $_counter'),
            Text('Error types: Exception, Type, Null, HTTP, JSON, Division, Overflow'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementAndError,
        child: Icon(Icons.warning),
      ),
    );
  }
}

class OverflowPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100,
        child: Row(
          children: [Text('This text is intentionally very long to cause an overflow ' * 10)],
        ),
      ),
    );
  }
}
```