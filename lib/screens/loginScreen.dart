import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _enteredEmail = '';
  var _enteredPass = '';
  var _isUploading = false;

  void submit() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }
    _formKey.currentState!
        .save(); // Save the form state before using the values

    try {
      setState(() {
        _isUploading = true;
      });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _enteredEmail,
        password: _enteredPass,
      );

      // Save user data to SharedPreferences
      //final prefs = await SharedPreferences.getInstance();
      //await prefs.setString('email', _enteredEmail);
    } on FirebaseAuthException catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: e.message ?? 'Failed',
        ),
      );
    }

    log(_enteredPass);
    log(_enteredEmail);
    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SingleChildScrollView(
          child: Card(
            child: Column(
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  width: 400,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Email Address'),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          onSaved: (val) => _enteredEmail = val!,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          onSaved: (val) => _enteredPass = val!,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        if (_isUploading) const CircularProgressIndicator(),
                        if (!_isUploading)
                          ElevatedButton(
                            onPressed: submit,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            child: const Text('Login'),
                          ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
