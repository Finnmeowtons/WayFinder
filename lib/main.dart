import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:way_finders/bloc/device_bloc/device_bloc.dart';
import 'package:way_finders/bloc/login_signup_bloc/signup_login_bloc.dart';
import 'package:way_finders/repository/auth_repository.dart';
import 'package:way_finders/repository/device_repository.dart';
import 'package:way_finders/screens/splash_screen.dart';
import 'package:way_finders/services/mqtt_manager.dart';

import 'bloc/mqtt_bloc/mqtt_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<SignupLoginBloc>(create: (context) => SignupLoginBloc(AuthRepository())),
          BlocProvider<DeviceBloc>(create: (context) => DeviceBloc(DeviceRepository(), MqttManager())),
          BlocProvider<MqttBloc>(create: (context) => MqttBloc(context.read<DeviceBloc>())),
        ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          ),
          home: const SplashScreen()

      ),
    );
  }
}
