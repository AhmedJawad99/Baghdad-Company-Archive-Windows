import 'package:baghdadcompany/screens/profile/profileWidgets/archiveList.dart';
import 'package:baghdadcompany/screens/profile/profileWidgets/screensSort/sortArchive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class Archive extends StatefulWidget {
  const Archive({super.key});

  @override
  State<Archive> createState() => _ArchiveState();
}

class _ArchiveState extends State<Archive> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _keyEditTitle = GlobalKey<FormState>();
  String newTitleEdit = '';

  List<Map<String, dynamic>> folderDataList = [];

  Future getFoldersDataList() async {
    print(' == = $myDep');
    try {
      folderDataList.clear();
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('archive')
          .doc(myDep)
          .collection('archiveDep')
          .where('deleted', isEqualTo: false)
          .orderBy('index')
          .orderBy('createdAtindex', descending: true)
          .get();

      for (var doc in querySnapshot.docs) {
        var item = doc.data() as Map<String, dynamic>;
        Timestamp createdAtTimestamp = item['createdAt'] as Timestamp;
        DateTime createdAtDateTime = createdAtTimestamp.toDate();
        String finalDate = formatDate(
            DateTime(createdAtDateTime.year, createdAtDateTime.month,
                createdAtDateTime.day),
            [yyyy, '-', mm, '-', dd]);

        folderDataList.add({
          'id': doc.id,
          'folderName': item['folderName'],
          'createdBy': item['createdBy'],
          'department': myDep,
          'createdAtindex': item['createdAtindex'],
          'index': item['index'],
          'finalDate': finalDate,
        });
      }
    } catch (e) {
      print("Error fetching folders: $e");
    }
  }

  String folderName = '';
  String formattedDate = '';

  DateTime? selectedDate;

  String myDep = '';
  String myName = '';
  bool isAdmin = false;

  getUserInfo() async {
    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((val) {
      val.docs.forEach((val2) {
        setState(() {
          myDep = val2.data()['department'];
          myName = val2.data()['name'];
          isAdmin = val2.data()['is_admin'];
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  String formatDateLocal(DateTime date) {
    int year = date.year;
    int month = date.month;
    int day = date.day;

    String monthStr = month < 10 ? '0$month' : '$month';
    String dayStr = day < 10 ? '0$day' : '$day';

    return '$year/$monthStr/$dayStr';
  }

  void _showTextFieldsBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('اسم المجلد'),
            content: SizedBox(
              width: 600,
              child: Form(
                key: _fromKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      onChanged: (val) {
                        folderName = val;
                      },
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length < 2) {
                          return '';
                        }
                        return null;
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'اسم المجلد الجديد',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  final valid = _fromKey.currentState!.validate();
                  if (!valid) {
                    return;
                  }

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const PopScope(
                        child: Dialog(
                          backgroundColor: Colors.transparent,
                          child: Center(
                            child: SpinKitRotatingCircle(
                              color: Colors.white,
                              size: 50.0,
                            ),
                          ),
                        ),
                      );
                    },
                  );

                  try {
                    if (folderName.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('archive')
                          .doc(myDep) // Adjust this as needed
                          .collection('archiveDep')
                          .add({
                        'folderName': folderName,
                        'createdAt': Timestamp.now(),
                        'createdAtindex': Timestamp.now(),
                        'createdBy': myName, // Adjust this as needed
                        'createdByEmail':
                            FirebaseAuth.instance.currentUser!.email,
                        'department': myDep,
                        'deleted': false,
                        'index': 0,
                      });
                    }
                  } finally {
                    Navigator.of(context).pop(); // Close the loading dialog
                    Navigator.of(context).pop(); // Close the form dialog
                  }
                },
                child: Text(
                  'اضافة',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
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
                      color: Theme.of(context).colorScheme.secondaryContainer),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _dateController.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Column(
        children: [
          isAdmin
              ? Card(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text('ارشيف جميع الاقسام'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          titleOfDep(
                            context,
                            'قسم التدقيق',
                          ),
                          titleOfDep(context, 'قسم القانونية'),
                          titleOfDep(context, 'قسم المالية'),
                        ],
                      ),
                      Row(
                        children: [
                          titleOfDep(context, 'قسم المساهمين'),
                          titleOfDep(context, 'القسم الاداري'),
                          titleOfDep(context, 'القسم التجاري'),
                          titleOfDep(context, 'مكتب المدير'),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: const InputDecoration(
                  labelText: 'بحث',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
          departmentArchive(),
        ],
      ),
    );
  }

  Card departmentArchive() {
    return Card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text('ارشيف $myDep'),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 100,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _showTextFieldsBox,
                              label: const Text('انشاء مجلد'),
                              icon: Icon(Icons.drive_folder_upload_outlined),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                await getFoldersDataList();
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (ctx) {
                                  return SortArchive(
                                    folderDataList: folderDataList,
                                    isFolder: true,
                                  );
                                }));
                              },
                              label: const Text('تعديل الترتيب'),
                              icon: Icon(Icons.format_list_numbered_rtl),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                myDep == ''
                    ? const CircularProgressIndicator()
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('archive')
                            .doc(myDep)
                            .collection('archiveDep')
                            .where('deleted', isEqualTo: false)
                            .orderBy('index')
                            .orderBy('createdAtindex', descending: true)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('لا يوجد'));
                          }

                          var users = snapshot.data!.docs.where((doc) {
                            var data = doc.data() as Map<String, dynamic>;
                            var folderName = data['folderName'] as String;
                            return folderName.contains(
                              _searchController.text,
                            );
                          }).toList();

                          return ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8.0),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              var user =
                                  users[index].data() as Map<String, dynamic>;

                              // Convert Timestamp to DateTime
                              Timestamp createdAtTimestamp = user['createdAt'];
                              DateTime createdAtDateTime =
                                  createdAtTimestamp.toDate();
                              String finalDate = formatDate(
                                  DateTime(
                                      createdAtDateTime.year,
                                      createdAtDateTime.month,
                                      createdAtDateTime.day),
                                  [yyyy, '-', mm, '-', dd]);

                              return foldersList(
                                context,
                                users[index].id,
                                user['folderName'],
                                user['createdBy'],
                                user['createdByEmail'],
                                user['department'],
                                finalDate, // Pass the DateTime object instead of Timestamp
                              );
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded titleOfDep(BuildContext context, String department) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            myDep = department;
          });
        },
        child: Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(child: Text(department)),
          ),
        ),
      ),
    );
  }

  Padding foldersList(BuildContext context, String id, String title,
      String createdBy, String createdByEmail, String depName, var createdAt) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => Archivelist(
                          id: id,
                          date: createdAt.toString(),
                          folderName: title,
                          depOf: depName,
                          nameOfUser: myName,
                        )));
              },
              leading: const Icon(Icons.folder),
              title: Text(title),
              subtitle: Text(createdAt.toString()),
              trailing: Text('بواسطة $createdBy'),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onSelected: (String value) async {
              switch (value) {
                case 'حذف':
                  // Handle delete action
                  if (createdByEmail ==
                      FirebaseAuth.instance.currentUser!.email) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'حذف',
                            textAlign: TextAlign.right,
                          ),
                          content: const Text(
                              'حذف المجلد سيؤدي لحذف جميع المفات بداخله',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Colors.black87)),
                          actions: <Widget>[
                            TextButton(
                              child: const Text(
                                'الغاء',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            ElevatedButton(
                              child: const Text('حذف'),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await FirebaseFirestore.instance
                                    .collection('archive')
                                    .doc(myDep)
                                    .collection('archiveDep')
                                    .doc(id)
                                    .update({
                                  'deleted': true,
                                  'deletedBy': myName,
                                  'deleatedAt': Timestamp.now()
                                }).then((_) async {
                                  print("successfully deleted!");
                                  await FirebaseFirestore.instance
                                      .collection('archive')
                                      .doc(myDep)
                                      .collection('archiveDep')
                                      .doc(id)
                                      .collection('files')
                                      .get()
                                      .then((val) async {
                                    for (var item in val.docs) {
                                      await FirebaseFirestore.instance
                                          .collection('archive')
                                          .doc(myDep)
                                          .collection('archiveDep')
                                          .doc(id)
                                          .collection('files')
                                          .doc(item.id)
                                          .update({
                                        'deleted': true,
                                        'deletedBy': myName,
                                        'deleatedAt': Timestamp.now()
                                      });
                                    }
                                  });
                                }).catchError((error) {
                                  print("Error removing document: $error");
                                });
                              },
                            ),
                          ],
                        );
                      },
                    );
                    break;
                  } else {
                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.info(
                        message: 'لا يمكنك حذف مجلد لم تنشئه بنفسك',
                      ),
                    );
                  }
                  break;
                case 'تعديل':
                  // Handle edit action

                  if (createdByEmail ==
                      FirebaseAuth.instance.currentUser!.email) {
                    // Your edit action code here
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            title: const Text('تعديل'),
                            content: SizedBox(
                              height: 110,
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Form(
                                key: _keyEditTitle,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 10),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      style:
                                          const TextStyle(color: Colors.black),
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'اسم المجلد الجديد',
                                        suffixIcon: Icon(Icons.folder),
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
                                        newTitleEdit = val;
                                      },
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                            actions: [
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      var vaild = _keyEditTitle.currentState!
                                          .validate();
                                      if (vaild) {
                                        await FirebaseFirestore.instance
                                            .collection('archive')
                                            .doc(myDep)
                                            .collection('archiveDep')
                                            .doc(id)
                                            .update({
                                          'folderName': newTitleEdit,
                                        });

                                        Navigator.of(context).pop();
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
                        );
                      },
                    );
                    print("Edit action");
                  } else {
                    showTopSnackBar(
                      Overlay.of(context),
                      const CustomSnackBar.info(
                        message: 'لا يمكنك تعديل مجلد لم تنشئه بنفسك',
                      ),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return {'حذف', 'تعديل'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
                    textAlign: TextAlign.right,
                  ),
                );
              }).toList();
            },
          )
        ],
      ),
    );
  }
}
