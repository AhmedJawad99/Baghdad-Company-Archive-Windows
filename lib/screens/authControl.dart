import 'package:baghdadcompany/screens/loginScreen.dart';
import 'package:baghdadcompany/screens/profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authcontrol extends StatelessWidget {
  const Authcontrol({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return const Profile();
          } else {
            return const LoginScreen();
          }
        });
  }
}
