import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();

  String? nameOfUser;
  String imageUrl = '';

  //var _enteredName = 'لم يتم ادخال اسم';

  File? _selectedImage;
  Uint8List? webImage;

  final List<Map<String, dynamic>> profileData = [];
  String userId = FirebaseAuth.instance.currentUser!.uid;

  getDataOfUser() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((val) {
      if (val.exists && val.data() != null) {
        setState(() {
          profileData.add({
            'name': val.data()!['name'] ?? '',
            'image_url': val.data()!['image_url'] ?? '',
            'department': val.data()!['department'] ?? '',
            'is_admin': val.data()!['is_admin'] ?? false,
          });
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getDataOfUser();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    if (!kIsWeb) {
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          _selectedImage = selected;
        });
        // Upload image to Firebase Storage
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('$userId.jpg');

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
            .doc(userId)
            .update({
          'image_url': imageUrl,
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
        // Upload image to Firebase Storage
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('$userId.jpg');

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
            .doc(userId)
            .update({
          'image_url': imageUrl,
        });
        print('web');
      } else {
        print('No Image has been picked!');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _fromKey;
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return Expanded(
      flex: 3,
      child: SizedBox(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Form(
                child: FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(
                          child: Text('No user data found!'),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error!'),
                        );
                      }

                      var userData =
                          snapshot.data!.data() as Map<String, dynamic>;

                      return Form(
                        key: _fromKey,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Text('الملف الشخصي'),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            InkWell(
                              onTap: _pickImage,
                              child: _selectedImage == null && webImage == null
                                  ? Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.blueAccent, width: 2),
                                      ),
                                      child: ClipOval(
                                        child: userData['image_url'] != null &&
                                                userData['image_url'].isNotEmpty
                                            ? Image.network(
                                                userData['image_url'],
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'images/user.jpg',
                                                fit: BoxFit.cover,
                                              ),
                                      ),
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
                              decoration:
                                  const InputDecoration(labelText: 'الاسم'),
                              initialValue: userData['name'] ?? '',
                              readOnly: true,
                              // onChanged: (val) => _enteredName = val,
                              // validator: (value) {
                              //   if (value == null || value.trim().length < 4) {
                              //     return '';
                              //   }
                              //   if (value == userData['name']) {
                              //     return 'لا يوجد تغيير بالاسم';
                              //   }
                              // },
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'العنوان الوظيفي'),
                              readOnly: true,
                              initialValue: userData['department'] ?? '',
                              validator: (value) {
                                if (value == null || value.trim().length < 4) {
                                  return 'Please enter at least 4 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 28,
                            ),
                            // ElevatedButton.icon(
                            //   onPressed: () {
                            //     final valid = _fromKey.currentState!.validate();
                            //     if (!valid) {
                            //       return;
                            //     }
                            //     FirebaseFirestore.instance
                            //         .collection('users')
                            //         .doc(userId)
                            //         .update({
                            //       'name': _enteredName,
                            //     }).then((_) {
                            //       showTopSnackBar(
                            //         Overlay.of(context),
                            //         const CustomSnackBar.success(
                            //           message: 'تم تعديل الاسم',
                            //         ),
                            //       );
                            //     });
                            //   },
                            //   icon: const Icon(Icons.save),
                            //   label: const Text('حفظ'),
                            // )
                          ],
                        ),
                      );
                    })),
          ),
        ),
      ),
    );
  }
}
