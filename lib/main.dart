import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pl_project/screens/chat.dart';
import 'package:pl_project/screens/createGroup.dart';
import 'package:pl_project/screens/home.dart';
import 'package:pl_project/screens/login.dart';
import 'package:pl_project/screens/settings.dart';
import 'package:pl_project/screens/signup.dart';
import 'package:pl_project/screens/splashScreen.dart';
import 'package:pl_project/screens/userList.dart';
import 'package:pl_project/services/authServices.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthServices>(
          create: (_) => AuthServices(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<AuthServices>().authChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        initialRoute: 'Splash Screen',
        debugShowCheckedModeBanner: false,
        routes: {
          'Splash Screen': (context) => const SplashScreen(),
          'Login Screen': (context) => const Login(),
          'SignUp Screen': (context) => const Signup(),
          'UserList Screen': (context) => const UserList(),
          'Chat Screen': (context) => const ChatScreen(),
          'Create Group': (context) => const CreateGroup(),
          'Home Screen': (context) => const HomeScreen(),
          'Setting Screen': (context) => const SettingsScreen(),
        },
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Colors.amberAccent,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.amberAccent),
          appBarTheme: const AppBarTheme(
              centerTitle: true,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
              backgroundColor: Colors.amberAccent,
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 5,
              shadowColor: Colors.black),
          bottomAppBarTheme: const BottomAppBarThemeData(
            elevation: 5,
            color: Color(0xffc46210),
            shape: CircularNotchedRectangle(),
          ),
          useMaterial3: true,
        ),
      ),
    );
  }
}
