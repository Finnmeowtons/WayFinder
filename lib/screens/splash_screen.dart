import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:way_finders/screens/login_signup_screen.dart';
import 'package:way_finders/screens/map_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    checkToken();
  }

  void checkToken() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('auth_token');
    final phoneNumber = sharedPreferences.getString('phone_number');
    print('Token: $token');
    try {
      if (token == null || Jwt.isExpired(token)) {
        print('Token is expired or null');
        await sharedPreferences.remove('auth_token');
        await sharedPreferences.remove('phone_number');
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginSignupScreen()));
        });
      } else {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MapScreen(phoneNumber: phoneNumber!)));
        });
      }
    } catch (e) {
      print('Error: $e');
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginSignupScreen()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF407076),
              Color(0xFF1A3D41),
            ],
            center: Alignment.center,
            radius: 0.8,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/icons/logo_name_white.png'),
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            // SizedBox(height: 20), // Add spacing
            // Text(
            //   'Splash Screen',
            //   style: TextStyle(color: Colors.white, fontSize: 35),
            // ),
          ],
        ),
      ),
    );
  }
}