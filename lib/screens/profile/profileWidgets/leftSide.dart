import 'package:baghdadcompany/screens/loginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LeftSide extends StatefulWidget {
  const LeftSide({super.key, required this.onItemTapped});

  final Function(int index) onItemTapped;

  @override
  State<LeftSide> createState() => _LeftSideState();
}

class _LeftSideState extends State<LeftSide> {
  late Stream<DocumentSnapshot> _stream;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    getUserInfo();
    _stream =
        FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }

  bool isAdmin = false;

  getUserInfo() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((val) {
      val.docs.forEach((val2) {
        setState(() {
          // myDep = val2.data()['department'];
          // myName = val2.data()['name'];
          isAdmin = val2.data()['is_admin'];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _stream,
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData) {
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
                        snapshot.data!.data() as Map<String, dynamic>?;
                    return ListTile(
                      leading: ClipOval(
                        child: userData!['image_url'] != null &&
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
                      title: Text(userData['name']),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Card(
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      onTap: () {
                        widget.onItemTapped(0);
                      },
                      leading: Icon(Icons.person),
                      title: const Text(
                        'الملف الشخصي',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Card(
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(6.0),
                  //   ),
                  //   child: ListTile(
                  //     onTap: () {
                  //       widget.onItemTapped(1);
                  //     },
                  //     leading: Icon(Icons.inbox),
                  //     title: const Text(
                  //       'الصندوق الوارد',
                  //       textAlign: TextAlign.center,
                  //     ),
                  //   ),
                  // ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: ListTile(
                      onTap: () {
                        widget.onItemTapped(5);
                      },
                      leading: const Icon(Icons.archive),
                      title: const Text(
                        'الارشيف',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  isAdmin
                      ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: ListTile(
                            onTap: () {
                              widget.onItemTapped(6);
                            },
                            leading: const Icon(Icons.archive_outlined),
                            title: const Text(
                              'محذوفات الارشيف',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const SizedBox(),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: ListTile(
                      onTap: () {
                        widget.onItemTapped(2);
                      },
                      leading: Icon(Icons.settings),
                      title: const Text(
                        'الاعدادات',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  isAdmin
                      ? Card(
                          child: ListTile(
                            onTap: () {
                              widget.onItemTapped(3);
                            },
                            leading: Icon(Icons.person_add),
                            title: const Text(
                              'اضافة موظف',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const SizedBox(),
                  Card(
                    child: ListTile(
                      onTap: () {
                        widget.onItemTapped(4);
                      },
                      leading: Icon(Icons.groups),
                      title: const Text(
                        'الموظفين',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      onTap: () async {
                        FirebaseAuth.instance.signOut();
                        // Remove user data from SharedPreferences
                        // final prefs = await SharedPreferences.getInstance();
                        // await prefs.remove('email');
                      },
                      leading: Icon(Icons.logout_outlined),
                      title: const Text(
                        'تسجيل الخروج',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
