import 'package:flutter/material.dart';
import 'package:flutter_telex_error_monitor/flutter_telex_error_monitor.dart';
import 'package:http/http.dart' as http;

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

// Triggering Different Error Types

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

// Layout Overflow Example

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
