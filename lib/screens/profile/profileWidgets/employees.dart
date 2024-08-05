import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class Employees extends StatefulWidget {
  const Employees({super.key});

  @override
  State<Employees> createState() => _EmployeesState();
}

class _EmployeesState extends State<Employees> {
  String imageUrl = '';
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();

  //var _enteredName = 'لم يتم ادخال اسم';

  File? _selectedImage;
  Uint8List? webImage;
  Future<void> _pickImage(String userId) async {
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
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: 'تم تحديث الصورة',
          ),
        );
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
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: 'تم تحديث الصورة',
          ),
        );
      } else {
        print('No Image has been picked!');
      }
    }
  }

  List<String> departments = [
    'قسم التدقيق',
    'قسم القانونية',
    'قسم المالية',
    'قسم المساهمين',
    'القسم الاداري',
    'مكتب المدير',
    'القسم التجاري',
  ];

  bool? _isSwitched;

  void _toggleSwitch(bool value) {
    setState(() {
      _isSwitched = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: SizedBox(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              //key: _fromKey,
              child: Column(
                children: [
                  title('مكتب المدير'),
                  const Divider(),
                  getDepartment('مكتب المدير'),
                  const SizedBox(height: 40),
                  title('القسم الاداري'),
                  const Divider(),
                  getDepartment('القسم الاداري'),
                  const SizedBox(height: 40),
                  title('قسم المساهمين'),
                  const Divider(),
                  getDepartment('قسم المساهمين'),
                  const SizedBox(height: 40),
                  title('قسم المالية'),
                  const Divider(),
                  getDepartment('قسم المالية'),
                  const SizedBox(height: 40),
                  title('قسم القانونية'),
                  const Divider(),
                  getDepartment('قسم القانونية'),
                  const SizedBox(height: 40),
                  title('القسم التجاري'),
                  const Divider(),
                  getDepartment('القسم التجاري'),
                  const SizedBox(height: 40),
                  title('قسم التدقيق'),
                  const Divider(),
                  getDepartment('قسم التدقيق'),
                  const SizedBox(height: 40),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> getDepartment(String department) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('department', isEqualTo: department)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('لا يوجد'));
        }

        var users = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.0,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          padding: const EdgeInsets.all(10.0),
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];
            return InkWell(
              onTap: () async {
                String selectedDepartment = user['department'];
                String name = user['name'];
                bool _isSwitched = user['is_admin'];
                bool _isActive = user['is_active'];

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: AlertDialog(
                        title: const Text('تعديل'),
                        content: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Form(
                                key: _fromKey,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          await _pickImage(user.id);
                                        },
                                        child: _selectedImage == null &&
                                                webImage == null
                                            ? Container(
                                                width: 120,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.blueAccent,
                                                      width: 2),
                                                ),
                                                child: ClipOval(
                                                  child: user['image_url'] !=
                                                              null &&
                                                          user['image_url']
                                                              .isNotEmpty
                                                      ? Image.network(
                                                          user['image_url'],
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
                                                      color: Colors.blueAccent,
                                                      width: 2),
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
                                      const SizedBox(height: 20),
                                      TextFormField(
                                        style: const TextStyle(
                                            color: Colors.black),
                                        initialValue: name,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'اسم الموظف',
                                          suffixIcon: Icon(Icons.person),
                                        ),
                                        validator: (val) {
                                          if (val == null ||
                                              val.isEmpty ||
                                              val.trim().isEmpty) {
                                            return '';
                                          }
                                          return null;
                                        },
                                        onChanged: (val) {
                                          name = val;
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        style: const TextStyle(
                                            color: Colors.black),
                                        initialValue: user['email'],
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'الايميل',
                                          suffixIcon: Icon(Icons.email),
                                        ),
                                        validator: (val) {
                                          if (val == null ||
                                              val.isEmpty ||
                                              val.trim().isEmpty) {
                                            return '';
                                          }
                                          return null;
                                        },
                                        onChanged: (val) {
                                          // Update the name or any other variable as needed
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      DropdownButton<String>(
                                        hint: const Text('اختر قسم'),
                                        value: selectedDepartment,
                                        icon: const Icon(
                                          Icons.arrow_downward,
                                          color: Colors.black54,
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedDepartment = newValue!;
                                          });
                                        },
                                        items: departments
                                            .map<DropdownMenuItem<String>>(
                                                (String department) {
                                          return DropdownMenuItem<String>(
                                            value: department,
                                            child: Text(
                                              department,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                _isSwitched
                                                    ? 'صلاحية الادمن مفعلة'
                                                    : 'صلاحية الادمن غير مفعلة',
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              Switch(
                                                value: _isSwitched,
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    _isSwitched = value;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                _isActive
                                                    ? 'الحساب فعال'
                                                    : 'الحساب معطل',
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              Switch(
                                                value: _isActive,
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    _isActive = value;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      var vaild =
                                          _fromKey.currentState!.validate();
                                      if (vaild) {
                                        if (name != user['name']) {
                                          print('object');
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.id)
                                              .update({'name': name});
                                        }
                                        if (selectedDepartment !=
                                            user['department']) {
                                          print('object');
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.id)
                                              .update({
                                            'department': selectedDepartment
                                          });
                                        }
                                        if (_isActive != user['is_active']) {
                                          print('object');
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.id)
                                              .update({'is_active': _isActive});
                                        }
                                        if (_isSwitched != user['is_admin']) {
                                          print('object');
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.id)
                                              .update(
                                                  {'is_admin': _isSwitched});
                                        }
                                      }
                                    },
                                    child: Text(
                                      'تعديل',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inverseSurface,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'الغاء',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: Image.network(
                        user['image_url'],
                        // Adjust according to your data structure
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          !user['is_active']
                              ? Icon(
                                  Icons.person_off,
                                  color: Colors.red,
                                )
                              : const SizedBox(),
                          user['is_admin']
                              ? Icon(
                                  Icons.admin_panel_settings,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 33,
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                        )),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          user['name'] ??
                              'اسم غير مسجل', // Adjust according to your data structure
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Padding title(String titleOf) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        titleOf,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
