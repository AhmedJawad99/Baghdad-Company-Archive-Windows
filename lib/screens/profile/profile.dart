import 'dart:convert';
import 'dart:io';

import 'package:baghdadcompany/screens/profile/editProfile.dart';
import 'package:baghdadcompany/screens/profile/profileWidgets/addAccount.dart';
import 'package:baghdadcompany/screens/profile/profileWidgets/archive.dart';
import 'package:baghdadcompany/screens/profile/profileWidgets/archiveDeleted.dart';
import 'package:baghdadcompany/screens/profile/profileWidgets/employees.dart';
import 'package:baghdadcompany/screens/profile/profileWidgets/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'profileWidgets/leftSide.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<void> _checkUserAccount() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // No user is logged in, perform logout or handle accordingly
      await FirebaseAuth.instance.signOut();
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(
      //     builder: (context) => LoginScreen(),
      //   ),
      // );
      // Navigate to login screen or show a message
    } else if (user.email == 'test@go.com') {
      await FirebaseAuth.instance.signOut();
    } else {
      // User is logged in
      // You can handle what happens when a user is logged in here
    }
  }

  int _selectedIndex = 5;
  String? localVersion;

  Future<void> loadJsonData() async {
    try {
      final String response = await rootBundle.loadString('localcheck/v.json');
      final data = json.decode(response);
      setState(() {
        localVersion = data['version'];
      });
    } catch (e) {
      print("Error loading local JSON data: $e");
    }
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const Editprofile(),
    //const InboxWidget(),
    const SettingsWidget(),
    const SettingsWidget(),
    const Addaccount(),
    const Employees(),
    const Archive(),
    const ArchiveDeleted()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkUserAccount();
    loadJsonData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _widgetOptions.elementAt(_selectedIndex),
            //inboxWidget(),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lastUpdate')
                  .doc('update')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.hasData && snapshot.data != null) {
                  final docData = snapshot.data!.data() as Map<String, dynamic>;
                  final version = docData['version'];
                  if (version != localVersion) {
                    showDialogIfNeeded(context, version);
                  }
                  //return Center(child: Text('Current Version: $version'));
                }

                return const SizedBox();
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('email',
                      isEqualTo: FirebaseAuth.instance.currentUser!.email)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  //return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.hasData && snapshot.data != null) {
                  final docs = snapshot.data!.docs;
                  if (docs.isNotEmpty) {
                    final docData = docs.first.data() as Map<String, dynamic>;
                    final isActive = docData['is_active'];
                    if (!isActive) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                'الحساب معطل',
                                textAlign: TextAlign.right,
                              ),
                              content: const Text(
                                'تم تعطيل حسابك',
                                textAlign: TextAlign.right,
                                style: TextStyle(color: Colors.black87),
                              ),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () {
                                      FirebaseAuth.instance.signOut();
                                    },
                                    child: const Text('تسجيل الخروج'))
                              ],
                            );
                          },
                        );
                      });
                    } else {
                      Navigator.of(context).canPop();
                    }
                  }
                }

                return const SizedBox();
              },
            ),

            LeftSide(
              onItemTapped: _onItemTapped,
            ),
          ],
        ),
      ),
    );
  }

  void showDialogIfNeeded(BuildContext context, String version) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('تحديث'),
            content: Text(
              'يتوجب عليك تنزيل التحديث الجديد: $version',
              style: TextStyle(color: Colors.black87),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: const Text('اغلاق التطبيق'))
            ],
          );
        },
      );
    });
  }
}
