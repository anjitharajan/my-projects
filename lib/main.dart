import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:virmedo/MyProject/Admin/Homepage/adminhome.dart';
import 'package:virmedo/MyProject/Hospital/Hospitalhome/hospitalhome.dart';
import 'package:virmedo/MyProject/User/Bottomnavigation/account/medicalrcd.dart';
import 'package:virmedo/MyProject/User/Userscreen/home/userdashb.dart';
import 'package:virmedo/MyProject/signup/bloc/loginbloc_bloc.dart';
import 'package:virmedo/MyProject/signup/login/loginpage.dart';
import 'package:virmedo/MyProject/signup/signupscreen/signupscreen.dart';
import 'package:virmedo/MyProject/splash/splashlogo.dart';
import 'package:virmedo/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VIRMEDO',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SplashScreen(),
      ),
    );
  }
}
