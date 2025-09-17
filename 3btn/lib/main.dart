import 'package:flutter/material.dart';

import 'screens/qr_code_screen.dart';
import 'screens/my_doc_screen.dart';
import 'screens/other_doc_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Playfair Display',
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Text(
                'LMBpultd',
                style: TextStyle(
                  fontSize: 90,
                  fontFamily: 'UnifrakturMaguntia',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              Container(
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.0,
                ),
                child: const Text(
                  'Lince Binu Mattathil',
                  style: TextStyle(
                    fontSize: 50,
                    fontFamily: 'UnifrakturMaguntia',
                    color: Color.fromARGB(255, 255, 0, 0),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 1),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  textStyle: const TextStyle(
                    fontFamily: 'UnifrakturMaguntia',
                    fontSize: 40,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QrCodeScreen()),
                  );
                },
                child: const Text('My Upi QR Code'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  textStyle: const TextStyle(
                    fontFamily: 'UnifrakturMaguntia',
                    fontSize: 40,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyDocScreen()),
                  );
                },
                child: const Text('My Documents'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  textStyle: const TextStyle(
                    fontFamily: 'UnifrakturMaguntia',
                    fontSize: 40,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OtherDocScreen()),
                  );
                },
                child: const Text('Other Documents'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
