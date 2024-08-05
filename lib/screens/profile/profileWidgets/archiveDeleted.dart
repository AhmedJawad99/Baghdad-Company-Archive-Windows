import 'package:baghdadcompany/screens/profile/profileWidgets/archiveList.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ArchiveDeleted extends StatefulWidget {
  const ArchiveDeleted({super.key});

  @override
  State<ArchiveDeleted> createState() => _ArchiveState();
}

class _ArchiveState extends State<ArchiveDeleted> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();

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
    // TODO: implement initState
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
                    const SizedBox(height: 10),
                    // TextFormField(
                    //   controller: _dateController,
                    //   onChanged: (val) {
                    //     formattedDate = val;
                    //   },
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return '';
                    //     }
                    //     return null;
                    //   },
                    //   style: const TextStyle(color: Colors.black),
                    //   decoration: const InputDecoration(
                    //     border: OutlineInputBorder(),
                    //     labelText: 'التاريخ',
                    //     suffixIcon: Icon(Icons.calendar_today),
                    //   ),
                    //   readOnly: true,
                    //   onTap: () async {
                    //     final DateTime? pickedDate = await showDatePicker(
                    //       context: context,
                    //       initialDate: selectedDate ?? DateTime.now(),
                    //       firstDate: DateTime(2000),
                    //       lastDate: DateTime(2101),
                    //     );
                    //     if (pickedDate != null) {
                    //       setState(() {
                    //         selectedDate = pickedDate;
                    //         _dateController.text = formatDate(pickedDate);
                    //       });
                    //     }
                    //   },
                    // ),
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
                        'createdBy': myName, // Adjust this as needed
                        'createdByEmail':
                            FirebaseAuth.instance.currentUser!.email,
                        'department': myDep,
                        'deleted': false,
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
    // TODO: implement dispose
    super.dispose();
    _fromKey;
    _textController;
    _dateController;
  }

  bool _switchToFiles = false;

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
          const SizedBox(
            height: 10,
          ),
          Stack(
            children: [
              !_switchToFiles ? departmentArchive() : departmentArchiveOfiles(),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.736,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _switchToFiles = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _switchToFiles
                                ? Theme.of(context).colorScheme.onSecondary
                                : Theme.of(context)
                                    .colorScheme
                                    .onInverseSurface,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(
                                    16), // Adjust the radius as needed
                              ),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('الملفات'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _switchToFiles = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !_switchToFiles
                                ? Theme.of(context).colorScheme.onSecondary
                                : Theme.of(context)
                                    .colorScheme
                                    .onInverseSurface,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                    16), // Adjust the radius as needed
                              ),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('المجلدات'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                  height: 50,
                ),
                Text('ارشيف $myDep'),
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
                            .where('deleted', isEqualTo: true)
                            .orderBy('createdAt', descending: true)
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

                          var users = snapshot.data!.docs;

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
                              // --
                              Timestamp deleatedAtTimestamp =
                                  user['deleatedAt'];
                              DateTime deleatedAtDateTime =
                                  deleatedAtTimestamp.toDate();

                              String finalDate = formatDate(
                                  DateTime(
                                      createdAtDateTime.year,
                                      createdAtDateTime.month,
                                      createdAtDateTime.day),
                                  [yyyy, '-', mm, '-', dd]);
                              String finalDateOfDeleted = formatDate(
                                  DateTime(
                                      deleatedAtDateTime.year,
                                      deleatedAtDateTime.month,
                                      deleatedAtDateTime.day,
                                      deleatedAtDateTime.hour,
                                      deleatedAtDateTime.minute),
                                  [
                                    yyyy,
                                    '-',
                                    mm,
                                    '-',
                                    dd,
                                    ' | ',
                                    h,
                                    ':',
                                    nn,
                                    ' ',
                                    am
                                  ]);

                              return foldersList(
                                context,
                                users[index].id,
                                user['folderName'],
                                user['createdBy'],
                                user['createdByEmail'],
                                user['department'],
                                finalDate,
                                finalDateOfDeleted,
                                user['deletedBy'],
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

  Padding foldersList(
      BuildContext context,
      String id,
      String title,
      String createdBy,
      String createdByEmail,
      String depName,
      var createdAt,
      var deletedAt,
      String deletedBy) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: ListTile(
              onTap: () {
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: (ctx) => Archivelist(
                //           id: id,
                //           date: createdAt.toString(),
                //           folderName: title,
                //           depOf: depName,
                //           nameOfUser: myName,
                //         )));
              },
              leading: const Icon(Icons.folder),
              title: Text(title),
              subtitle: Text(createdAt.toString()),
            ),
          ),
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'حذف بواسطة $createdBy',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'بتاريخ $deletedAt',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              )),
          Expanded(
            child: ElevatedButton.icon(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          'اعادة المجلد',
                          textAlign: TextAlign.right,
                        ),
                        content: const Text(
                          'هل تريد اعادة المجلد فقط ام المجلد وجميع ما يحتويه من ملفات؟',
                          style: TextStyle(color: Colors.black87),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('archive')
                                    .doc(depName)
                                    .collection('archiveDep')
                                    .doc(id)
                                    .update({'deleted': false});
                                Navigator.of(context).pop();
                              },
                              child: const Text('فقط المجلد')),
                          ElevatedButton(
                              onPressed: () async {
                                FirebaseFirestore firestore =
                                    FirebaseFirestore.instance;

                                // إنشاء batch
                                WriteBatch batch = firestore.batch();

                                // تحديد المستند الذي ترغب في تعديله
                                DocumentReference doc1 = firestore
                                    .collection('archive')
                                    .doc(depName)
                                    .collection('archiveDep')
                                    .doc(id);

                                // إضافة التعديلات إلى doc1
                                batch.update(doc1, {'deleted': false});

                                try {
                                  // الحصول على جميع المستندات داخل مجموعة 'files'
                                  QuerySnapshot filesSnapshot = await firestore
                                      .collection('archive')
                                      .doc(depName)
                                      .collection('archiveDep')
                                      .doc(id)
                                      .collection('files')
                                      .get();

                                  // إضافة التعديلات إلى batch لكل مستند في مجموعة 'files' بشرط أن تكون قيمة 'deleted' هي true
                                  filesSnapshot.docs
                                      .forEach((DocumentSnapshot doc) {
                                    var data =
                                        doc.data() as Map<String, dynamic>?;
                                    if (data != null &&
                                        data['deleted'] == true) {
                                      batch.update(
                                          doc.reference, {'deleted': false});
                                    }
                                  });

                                  // تنفيذ batch
                                  await batch.commit();
                                  print('All changes committed successfully');
                                } catch (e) {
                                  print('Failed to commit changes: $e');
                                }
                                Navigator.of(context).pop();
                              },
                              child: const Text('المجلد وجميع الملفات')),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.restore_from_trash),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight:
                          Radius.circular(16), // Adjust the radius as needed
                      bottomRight:
                          Radius.circular(16), // Adjust the radius as needed
                    ),
                  ),
                ),
                label: const Text('اعادة')),
          ),
          Expanded(
            child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          'حذف مجلد',
                          textAlign: TextAlign.right,
                        ),
                        content: const Text(
                          '!حذف المجلد سيؤدي لحذف جميع الملفات بداخله',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.black87),
                        ),
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
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await FirebaseFirestore.instance
                                    .collection('archive')
                                    .doc(myDep)
                                    .collection('archiveDep')
                                    .doc(id)
                                    .collection('files')
                                    .get()
                                    .then((val) {
                                  val.docs.forEach((item) async {
                                    String fileUrl = item.data()['fileUrl'];
                                    String idFile = item.id;
                                    await FirebaseFirestore.instance
                                        .collection('archive')
                                        .doc(myDep)
                                        .collection('archiveDep')
                                        .doc(id)
                                        .collection('files')
                                        .doc(idFile)
                                        .delete()
                                        .then((_) async {
                                      await FirebaseStorage.instance
                                          .refFromURL(fileUrl)
                                          .delete();
                                    });
                                  });
                                }).then((_) async {
                                  await FirebaseFirestore.instance
                                      .collection('archive')
                                      .doc(myDep)
                                      .collection('archiveDep')
                                      .doc(id)
                                      .delete();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade800,
                              ),
                              child: const Text(
                                'حذف',
                                style: TextStyle(color: Colors.white),
                              ))
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.delete),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(16), // Adjust the radius as needed
                      bottomLeft:
                          Radius.circular(16), // Adjust the radius as needed
                    ),
                  ),
                ),
                label: const Text('حذف نهائي')),
          ),
        ],
      ),
    );
  }

  //---

  Card departmentArchiveOfiles() {
    return Card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                ),
                Text('ارشيف $myDep'),
                const SizedBox(
                  height: 20,
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('archive')
                      .doc(myDep)
                      .collection('archiveDep')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('لا يوجد'));
                    }

                    String? folderNameDeleted;

                    snapshot.data!.docs.forEach((val) {
                      var data = val.data() as Map<String, dynamic>?;

                      folderNameDeleted = data!['folderName'];
                    });

                    var archiveDocs = snapshot.data!.docs;
                    var docIds = archiveDocs.map((doc) => doc.id).toList();

                    return FutureBuilder<List<List<DocumentSnapshot>>>(
                      future: _fetchFilesForDocs(docIds),
                      builder: (context, snapshot) {
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
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('لا يوجد'));
                        }

                        var files =
                            snapshot.data!.expand((files) => files).toList();

                        return ListView.builder(
                          padding: const EdgeInsets.all(10.0),
                          itemCount: files.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var file = files[index];
                            var user = file.data() as Map<String, dynamic>;

                            bool isPdfFile =
                                user['fileUrl'].toString().contains('pdf');
                            bool isPdfFileFromDoc = false;
                            String getType = 'un';

                            switch (user['type']) {
                              case 'doc':
                              case 'docx':
                              case 'dot':
                              case 'dotx':
                                isPdfFileFromDoc = true;
                                getType = 'doc';
                                break;
                              case 'xls':
                              case 'xlsx':
                              case 'xlsm':
                              case 'xltx':
                              case 'csv':
                                isPdfFileFromDoc = true;
                                getType = 'xlsx';
                                break;
                              case 'pdf':
                                isPdfFileFromDoc = true;
                                getType = 'pdf';
                                break;
                              case 'jpg':
                              case 'jpeg':
                                isPdfFileFromDoc = false;
                                getType = 'jpg';
                                break;
                              case 'png':
                                isPdfFileFromDoc = false;
                                getType = 'png';
                                break;
                              default:
                                isPdfFileFromDoc = true;
                                getType = 'un';
                            }

                            Timestamp createdAtTimestamp = user['date'];
                            DateTime createdAtDateTime =
                                createdAtTimestamp.toDate();
                            String finalDate = formatDate(
                              DateTime(
                                  createdAtDateTime.year,
                                  createdAtDateTime.month,
                                  createdAtDateTime.day),
                              [yyyy, '-', mm, '-', dd],
                            );

                            Timestamp deletedAtTimestamp = user['deleatedAt'];
                            DateTime deletedAtDateTime =
                                deletedAtTimestamp.toDate();
                            String finalDateDeleted = formatDate(
                              DateTime(
                                deletedAtDateTime.year,
                                deletedAtDateTime.month,
                                deletedAtDateTime.day,
                                deletedAtDateTime.hour,
                                deletedAtDateTime.minute,
                              ),
                              [
                                yyyy,
                                '-',
                                mm,
                                '-',
                                dd,
                                ' | ',
                                H,
                                ':',
                                nn,
                                ' ',
                                am
                              ],
                            );

                            // Get the document ID from the archiveDep collection
                            String idOfCollection =
                                file.reference.parent.parent?.id ?? '';

                            return InkWell(
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${index + 1}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    isPdfFile || isPdfFileFromDoc
                                        ? Image.asset('images/$getType.png',
                                            width: 50.0,
                                            height: 50.0,
                                            fit: BoxFit.cover)
                                        : Image.network(user['fileUrl'],
                                            width: 50.0,
                                            height: 50.0,
                                            fit: BoxFit.cover),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 2,
                                      child: ListTile(
                                        title: Text(
                                            '${user['title'] ?? 'اسم غير مسجل'}',
                                            overflow: TextOverflow.ellipsis),
                                        subtitle: Text(
                                            user['folderName'] ?? '-',
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                'حذف بواسطة ${user['deletedBy']}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                'بتاريخ $finalDateDeleted',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                          onPressed: () async {
                                            print(idOfCollection);
                                            print(folderNameDeleted);

                                            late bool deletedCollection;

                                            await FirebaseFirestore.instance
                                                .collection('archive')
                                                .doc(myDep)
                                                .collection('archiveDep')
                                                .doc(idOfCollection)
                                                .get()
                                                .then((val) {
                                              deletedCollection =
                                                  val.data()!['deleted'];
                                            });

                                            if (deletedCollection) {
                                              showTopSnackBar(
                                                Overlay.of(context),
                                                const CustomSnackBar.info(
                                                  message:
                                                      'يتوجب عليك الغاء حذف المجلد',
                                                ),
                                              );
                                            } else if (!deletedCollection) {
                                              await FirebaseFirestore.instance
                                                  .collection('archive')
                                                  .doc(myDep)
                                                  .collection('archiveDep')
                                                  .doc(idOfCollection)
                                                  .collection('files')
                                                  .doc(file.id)
                                                  .update({
                                                'deleted': false,
                                              });
                                              showTopSnackBar(
                                                Overlay.of(context),
                                                const CustomSnackBar.success(
                                                  message:
                                                      'اكتملت عملية ارجاع الملف',
                                                ),
                                              );
                                            } else {
                                              showTopSnackBar(
                                                Overlay.of(context),
                                                const CustomSnackBar.error(
                                                  message: 'حدث خطأ',
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.restore_from_trash,
                                            color: Colors.white,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.green.shade800,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(
                                                    16), // Adjust the radius as needed
                                                bottomRight: Radius.circular(
                                                    16), // Adjust the radius as needed
                                              ),
                                            ),
                                          ),
                                          label: const Text(
                                            'اعادة',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                    ),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    'حذف ملف',
                                                    textAlign: TextAlign.right,
                                                  ),
                                                  content: Text(
                                                    'هل تريد حذف ${user['title']}؟',
                                                    textAlign: TextAlign.right,
                                                    style: const TextStyle(
                                                        color: Colors.black87),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text(
                                                        'الغاء',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () async {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'archive')
                                                              .doc(myDep)
                                                              .collection(
                                                                  'archiveDep')
                                                              .doc(
                                                                  idOfCollection)
                                                              .collection(
                                                                  'files')
                                                              .doc(file.id)
                                                              .delete()
                                                              .then((val) {
                                                            FirebaseStorage
                                                                .instance
                                                                .refFromURL(user[
                                                                    'fileUrl'])
                                                                .delete();
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                          showTopSnackBar(
                                                            Overlay.of(context),
                                                            const CustomSnackBar
                                                                .success(
                                                              message:
                                                                  'اكتملت عملية حذف الملف',
                                                            ),
                                                          );
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors
                                                                  .red.shade800,
                                                        ),
                                                        child: const Text(
                                                          'حذف',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ))
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.red.shade800,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(
                                                    16), // Adjust the radius as needed
                                                bottomLeft: Radius.circular(
                                                    16), // Adjust the radius as needed
                                              ),
                                            ),
                                          ),
                                          label: const Text(
                                            'حذف نهائي',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                    ),
                                    const SizedBox(width: 5),
                                  ],
                                ),
                              ),
                            );
                          },
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

  Future<List<List<DocumentSnapshot>>> _fetchFilesForDocs(
      List<String> docIds) async {
    List<List<DocumentSnapshot>> allFiles = [];
    for (var docId in docIds) {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('archive')
          .doc(myDep)
          .collection('archiveDep')
          .doc(docId)
          .collection('files')
          .where('deleted', isEqualTo: true)
          .orderBy('createdAt')
          .orderBy('index')
          .get();
      allFiles.add(querySnapshot.docs);
    }
    return allFiles;
  }
}
