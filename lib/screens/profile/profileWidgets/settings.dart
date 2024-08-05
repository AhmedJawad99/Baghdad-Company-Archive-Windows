import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  void resetPassword(BuildContext context) async {
    String? user = FirebaseAuth.instance.currentUser!.email;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: user!.trim(),
      );
      // Show a success message or navigate to a success screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reset email: ${e.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? userEmail = user?.email ?? 'No email found';
    return Expanded(
      flex: 3,
      child: SizedBox(
        // height: MediaQuery.of(context).size.height * 0.96,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text('الاعدادات'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'البريد الالكتروني'),
                    readOnly: true,
                    initialValue: userEmail,
                    // onSaved: (val) => _enteredUsername = val!,
                    validator: (value) {
                      if (value == null || value.trim().length < 4) {
                        return 'Please enter at least 4 characters';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'كلمة المرور'),
                    obscureText: true,
                    readOnly: true,
                    initialValue: '1234512345',
                    //onSaved: (val) => _enterdPass = val!,
                    validator: (value) {
                      if (value == null || value.trim().length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => resetPassword(context),
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('تغيير كلمة المرور'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
