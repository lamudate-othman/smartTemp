import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the generated Firebase options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        
      ),
      debugShowCheckedModeBanner:false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  String _ledState = "OFF";
  double _temperature = 0.0;
  double _humidity = 0.0;

  @override
  void initState() {
    super.initState();
    _listenToSensorData();
  }

  /// Listens to sensor data changes in Firebase.
  void _listenToSensorData() {
    try {
       _dbRef.child('ledState').onValue.listen((event) {
      final data = event.snapshot.value as String;
      setState(() {
        log(data.toString());
        _ledState=data;
      });
    });
    _dbRef.child('sensorData').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      setState(() {
        _temperature = (data?['temperature'] as num?)?.toDouble() ?? 0.0;
        _humidity = (data?['humidity'] as num?)?.toDouble() ?? 0.0;
      });
    });
    } catch (e) {
      log(e.toString());
    }
    
  }

  /// Toggles the LED state in Firebase.
  void _toggleLED() {
    _ledState = _ledState == "OFF" ? "ON" : "OFF";
    _dbRef.child('ledState').set(_ledState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SMART TEMP"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Temperature Card
            _buildSensorCard(
              title: "Temperature",
              value: "$_temperature°C",
              icon: Icons.thermostat_outlined,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            // Humidity Card
            _buildSensorCard(
              title: "Humidity",
              value: "$_humidity%",
              icon: Icons.water_drop,
              color: Colors.blue,
            ),
            SizedBox(height: 32),
            // LED Control Button
            ElevatedButton.icon(
              onPressed: _toggleLED,
              icon: Icon(
                _ledState == "ON" ? Icons.lightbulb : Icons.lightbulb_outline,
              ),
              label: Text("Turn LED $_ledState"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: _ledState == "ON" ? Colors.yellow : Colors.grey, padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a card for sensor data
  Widget _buildSensorCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(
                icon,
                color: color,
                size: 36,
              ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
