import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class Addaccount extends StatefulWidget {
  const Addaccount({super.key});

  @override
  State<Addaccount> createState() => _AddaccountState();
}

class _AddaccountState extends State<Addaccount> {
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredName = '';
  var _enterdPass = '';
  File? _selectedImage;
  Uint8List? webImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    if (!kIsWeb) {
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          _selectedImage = selected;
        });
        print('mobile');
      } else {
        print('No Image has been picked!');
      }
    } else {
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
        });
        print('web');
      } else {
        print('No Image has been picked!');
      }
    }
  }

  void _resetForm() {
    setState(() {
      _fromKey.currentState?.reset(); // Reset form fields
      _selectedImage = null; // Clear selected image
      webImage = null; // Clear web image data
      _enteredEmail = ''; // Clear email field
      _enteredName = ''; // Clear name field
      _enterdPass = ''; // Clear password field
    });
  }

  @override
  void dispose() {
    super.dispose();
    _fromKey;
  }

  String? selectedDepartment;

  List<String> departments = [
    'قسم التدقيق',
    'قسم القانونية',
    'قسم المالية',
    'قسم المساهمين',
    'القسم الاداري',
    'مكتب المدير',
    'القسم التجاري',
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: SizedBox(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              key: _fromKey,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text('اضافة موظف'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: _pickImage,
                    child: _selectedImage == null && webImage == null
                        ? const CircleAvatar(
                            radius: 60,
                            child: Icon(Icons.camera_alt,
                                size: 50, color: Colors.white),
                          )
                        : Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.blueAccent, width: 2),
                            ),
                            child: ClipOval(
                              child: kIsWeb
                                  ? Image.memory(
                                      webImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'اسم الموظف'),
                    onChanged: (val) {
                      _enteredName = val;
                    },
                    validator: (value) {
                      if (value == null || value.trim().length < 4) {
                        return '';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'البريد الالكتروني'),
                    onChanged: (val) => _enteredEmail = val,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          !value.contains('@')) {
                        return '';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'كلمة المرور'),
                    obscureText: true,
                    onChanged: (val) => _enterdPass = val,
                    validator: (value) {
                      if (value == null || value.trim().length < 6) {
                        return 'كلمة المرور يجب ان تكون اكثر من 6 حروف';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  DropdownButton<String>(
                    hint: Text(
                      'اختر قسم',
                      style: TextStyle(
                          color: Colors.grey[200]), // لون النص الأساسي
                    ),
                    value: selectedDepartment,
                    icon: const Icon(
                      Icons.arrow_downward,
                    ), // لون السهم
                    dropdownColor: Theme.of(context)
                        .colorScheme
                        .outline, // لون خلفية القائمة المنسدلة

                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDepartment = newValue!;
                      });
                    },
                    items: departments
                        .map<DropdownMenuItem<String>>((String department) {
                      return DropdownMenuItem<String>(
                        value: department,
                        child: Text(
                          department,
                          style: const TextStyle(
                              color: Colors.white), // لون النص في العناصر
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  !_isUploading
                      ? ElevatedButton.icon(
                          onPressed: () async {
                            final valid = _fromKey.currentState!.validate();
                            if (!valid) {
                              return;
                            }
                            if (_selectedImage == null && webImage == null) {
                              showTopSnackBar(
                                Overlay.of(context),
                                const CustomSnackBar.error(
                                  message: 'يتوجب عليك وضع صورة شخصية',
                                ),
                              );
                              return;
                            }
                            if (selectedDepartment == null) {
                              showTopSnackBar(
                                Overlay.of(context),
                                const CustomSnackBar.error(
                                  message: 'يتوجب عليك اختيار قسم  ',
                                ),
                              );
                              return;
                            }

                            FirebaseApp? secondaryApp;
                            UserCredential? userCredential;

                            try {
                              setState(() {
                                _isUploading = true;
                              });
                              // Initialize secondary Firebase app
                              secondaryApp = await Firebase.initializeApp(
                                name: 'Secondary',
                                options: Firebase.app().options,
                              );

                              // Create user using FirebaseAuth instance for secondary app
                              userCredential = await FirebaseAuth.instanceFor(
                                      app: secondaryApp)
                                  .createUserWithEmailAndPassword(
                                      email: _enteredEmail,
                                      password: _enterdPass);

                              // Upload image to Firebase Storage
                              final Reference storageRef = FirebaseStorage
                                  .instance
                                  .ref()
                                  .child('user_images')
                                  .child('${userCredential.user!.uid}.jpg');

                              String imageUrl;
                              if (kIsWeb) {
                                await storageRef.putData(webImage!);
                              } else {
                                await storageRef.putFile(_selectedImage!);
                              }
                              imageUrl = await storageRef.getDownloadURL();
                              log(imageUrl);

                              // Store user data in Firestore
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userCredential.user!.uid)
                                  .set({
                                'name': _enteredName,
                                'email': _enteredEmail,
                                'image_url': imageUrl,
                                'is_admin': false,
                                'is_active': true,
                                'department': selectedDepartment,
                              });
                            } on FirebaseAuthException catch (e) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.message ?? 'Failed')),
                              );
                            } finally {
                              // Ensure cleanup of secondary Firebase app
                              if (secondaryApp != null) {
                                await secondaryApp.delete();
                              }

                              setState(() {
                                _isUploading = false;
                              });
                              _resetForm();
                            }
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('اضافة'),
                        )
                      : const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
