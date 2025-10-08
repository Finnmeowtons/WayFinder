import 'package:flutter/material.dart';

import 'map_screen.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool _showOtpCard = false; // Toggle between login/signup and OTP screen

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/landing.jpg'), // background image
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 64.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icons/logo_name_white.png',
                      fit: BoxFit.fitWidth,
                      // width: 300,
                      height: 200,
                    ),
                    SizedBox(height: 50),
                    _showOtpCard ? _OtpCard(onBack: _toggleScreen) : _LoginSignupCard(onProceed: _toggleScreen),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleScreen() {
    setState(() {
      _showOtpCard = !_showOtpCard;
    });
  }
}

class _LoginSignupCard extends StatelessWidget {
  final VoidCallback onProceed;
  const _LoginSignupCard({super.key, required this.onProceed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 380,
        height: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Login / Sign Up",
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF005A66)),
            ),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Enter contact number"),
              ),
              keyboardType: TextInputType.number,
              // TODO: add controller and validation
            ),
            ElevatedButton(
              onPressed: onProceed, // TODO: trigger OTP generation/login
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005A66)),
              child: const Text("Proceed", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpCard extends StatelessWidget {
  final VoidCallback onBack;
  const _OtpCard({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 380,
        height: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Enter Your OTP",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF005A66)),
            ),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text("One Time Password"),
              ),
              keyboardType: TextInputType.number,
              // TODO: add controller
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: onBack,
                  child: const Text("Back"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: verify OTP and navigate to HomePage
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MapScreen()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("OTP verified")),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005A66)),
                  child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
