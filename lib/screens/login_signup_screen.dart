import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_signup_bloc/signup_login_bloc.dart';
import 'map_screen.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool _showOtpCard = false; // Toggle between login/signup and OTP screen
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String otp = "";
  String phoneNumber = "";




  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _toggleScreen() {
    setState(() {
      _showOtpCard = !_showOtpCard;
    });
  }

  Future<String> _generateOtp() async { final random = Random(); return (100000 + random.nextInt(900000)).toString(); }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/landing.jpg'),
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
                      height: 200,
                    ),
                    SizedBox(height: 50),
                    BlocConsumer<SignupLoginBloc, SignupLoginState>(
                      listener: (context, state) {
                        final messenger = ScaffoldMessenger.of(context);
                        if (state is SignupLoginLoading) {
                          // show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          );
                        } else if (state is SignupLoginError) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.error)),
                          );
                          print("Error: ${state.error}");
                        } else if (state is OTPRequested) {
                          Navigator.pop(context);
                          messenger.showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                          setState(() => _showOtpCard = true);
                        } else if (state is UserConfirmed) {
                          Navigator.pop(context);
                          messenger.hideCurrentSnackBar();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => MapScreen(phoneNumber: phoneNumber,)));
                        }
                      },
                      builder: (context, state) {
                        return _showOtpCard
                            ? _OtpCard(
                          otpController: _otpController,
                          onBack: _toggleScreen,
                          otp: otp,
                          onConfirm: () {
                            if(_otpController.text == otp) {
                              context.read<SignupLoginBloc>().add(
                                ConfirmUserRequested(
                                    phoneNumber: _phoneController.text
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Invalid OTP")),
                              );
                            }
                          },
                        )
                            : _LoginSignupCard(
                          phoneController: _phoneController,
                          onProceed: () async {
                            otp = await _generateOtp();
                            phoneNumber = _phoneController.text;
                            print("OTP: $otp");
                            context.read<SignupLoginBloc>().add(
                              SignInRequested(
                                phoneNumber: _phoneController.text,
                                otp: otp,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginSignupCard extends StatefulWidget {
  final VoidCallback onProceed;
  final TextEditingController phoneController;
  const _LoginSignupCard({
    super.key,
    required this.onProceed,
    required this.phoneController,
  });

  @override
  State<_LoginSignupCard> createState() => _LoginSignupCardState();
}

class _LoginSignupCardState extends State<_LoginSignupCard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                const Text(
                  "Connect to",
                  style: TextStyle(

                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF005A66)),
                ),
                const Text(
                  "WayFinder",
                  style: TextStyle(

                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF005A66)),
                ),
              ],
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: widget.phoneController,
                validator: (value) => (value == null || value.length != 11) ? 'Contact number must be 11 digits' : null,
                maxLength: 11,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Enter contact number"),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onProceed();
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005A66)),
              child: const Text("Proceed", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpCard extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onConfirm;
  final String otp;
  final TextEditingController otpController;
  const _OtpCard({
    super.key,
    required this.onBack,
    required this.onConfirm,
    required this.otp,
    required this.otpController,
  });

  @override
  State<_OtpCard> createState() => _OtpCardState();
}

class _OtpCardState extends State<_OtpCard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005A66)),
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: widget.otpController,
                validator: (value) => (value == null || value.length != 6) ? 'OTP must be 6 digits' : (value != widget.otp) ? 'Invalid OTP' : null,
                maxLength: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("One Time Password"),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: widget.onBack, child: const Text("Back")),
                ElevatedButton(
                  onPressed:() {
                    if (_formKey.currentState!.validate()) {
                      widget.onConfirm();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005A66)),
                  child:
                  const Text("Confirm", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
