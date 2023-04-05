import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:transcribe_mate/ui/LoginPage.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    List<AuthProvider> providers = [EmailAuthProvider()];
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "ProductSans"
      ),
      // home: const HomePage(),
      home: const LoginPage(),
      routes: {
        '/signIn': (context) {
          return SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, 'availableModels');
              })
            ],
          );
        },
        '/loginPage':(context) => const LoginPage()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
