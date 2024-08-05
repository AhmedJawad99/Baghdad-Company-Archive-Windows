// import 'dart:developer';
// import 'dart:html' as html show window;
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:top_snackbar_flutter/custom_snack_bar.dart';
// import 'package:top_snackbar_flutter/top_snack_bar.dart';
// import 'package:uuid/uuid.dart';

// class inboxWidget extends StatefulWidget {
//   const inboxWidget({
//     super.key,
//   });

//   @override
//   State<inboxWidget> createState() => _inboxWidgetState();
// }

// class _inboxWidgetState extends State<inboxWidget> {
//   File? _selectedFile;
//   Uint8List? webFile;
//   String? fileType;
//   final String userId = FirebaseAuth.instance.currentUser!.uid;
//   final String? myEmail = FirebaseAuth.instance.currentUser!.email;
//   String _slectedName = '';
//   String _slectedEmail = '';
//   String _slectedImage = '';
//   String _slectedDep = '';
//   final Uuid uuid = Uuid();
//   _employeesSelected(
//       String nameOf, String emailOf, String imageOf, String depOf) {
//     print(nameOf);
//     print(emailOf);
//     setState(() {
//       _slectedName = nameOf;
//       _slectedEmail = emailOf;
//       _slectedImage = imageOf;
//       _slectedDep = depOf;
//     });
//   }

//   String formatFileSize(int bytes) {
//     if (bytes >= 1073741824) {
//       return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
//     } else if (bytes >= 1048576) {
//       return '${(bytes / 1048576).toStringAsFixed(2)} MB';
//     } else if (bytes >= 1024) {
//       return '${(bytes / 1024).toStringAsFixed(2)} KB';
//     } else {
//       return '$bytes B';
//     }
//   }

//   String formatDate(DateTime date) {
//     int year = date.year;
//     int month = date.month;
//     int day = date.day;
//     int hour = date.hour;
//     int minute = date.minute;

//     String monthStr = month < 10 ? '0$month' : '$month';
//     String dayStr = day < 10 ? '0$day' : '$day';
//     String minuteStr = minute < 10 ? '0$minute' : '$minute';

//     String period = hour >= 12 ? 'PM' : 'AM';
//     if (hour > 12) {
//       hour -= 12;
//     } else if (hour == 0) {
//       hour = 12;
//     }

//     String hourStr = hour < 10 ? '0$hour' : '$hour';

//     return '$year/$monthStr/$dayStr $hourStr:$minuteStr $period';
//   }

//   String removeAfterAt(String input) {
//     int atIndex = input.indexOf('@');
//     if (atIndex != -1) {
//       return input.substring(0, atIndex);
//     }
//     return input; // Return the original string if '@' is not found
//   }

//   void updateReadStatus(String doc) async {
//     try {
//       DocumentSnapshot docSnapshot =
//           await FirebaseFirestore.instance.collection('isRead').doc(doc).get();
//       String? senderEmail = FirebaseAuth.instance.currentUser?.email;
//       if (docSnapshot.exists) {
//         await FirebaseFirestore.instance.collection('isRead').doc(doc).update({
//           'senderEmail': _slectedEmail,
//           'reciverEmail': senderEmail,
//           'read': true
//         });
//       } else {
//         await FirebaseFirestore.instance.collection('isRead').doc(doc).set({
//           'senderEmail': _slectedEmail,
//           'reciverEmail': senderEmail,
//           'read': true
//         });
//       }
//     } catch (e) {
//       print('Error updating read status: $e');
//     }
//   }

//   Future<void> pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();

//     if (result != null) {
//       if (kIsWeb) {
//         webFile = result.files.first.bytes;
//       } else {
//         _selectedFile = File(result.files.first.path!);
//       }
//       fileType = result.files.first.extension;
//       String fileTypeForImage = 'un';
//       switch (fileType) {
//         case 'doc':
//         case 'docx':
//         case 'dot':
//         case 'dotx':
//           fileTypeForImage = 'doc';
//           break;
//         case 'xls':
//         case 'xlsx':
//         case 'xlsm':
//         case 'xltx':
//         case 'csv':
//           fileTypeForImage = 'xlsx';
//           break;
//         case 'pdf':
//           fileTypeForImage = 'pdf';
//           break;
//         case 'jpg':
//         case 'jpeg':
//         case 'jfif':
//           fileTypeForImage = 'jpg';
//           break;
//         case 'png':
//           fileTypeForImage = 'png';
//           break;
//         case 'gif':
//           fileTypeForImage = 'jpg';
//           break;

//         case 'heif':
//         case 'heic':
//           fileTypeForImage = 'jpg';
//           break;
//         default:
//           fileTypeForImage = 'un';
//       }
//       int fileSizeBytes = result.files.first.size; // Get the file size in bytes
//       String fileSizeString =
//           formatFileSize(fileSizeBytes); // Format the file size

//       // Extract the original file name without the extension
//       String originalFileName = result.files.first.name;
//       originalFileName =
//           originalFileName.substring(0, originalFileName.lastIndexOf('.'));

//       // Generate a unique identifier using UUID
//       String uniqueId = uuid.v4();

//       // Combine the original file name with the unique identifier
//       String uniqueFileName = '$originalFileName-$uniqueId.${fileType!}';

//       // Upload file to Firebase Storage
//       final Reference storageRef = FirebaseStorage.instance
//           .ref()
//           .child('inboxFiles')
//           .child(_slectedDep)
//           .child(uniqueFileName);

//       String fileUrl;
//       if (kIsWeb) {
//         await storageRef.putData(webFile!);
//       } else {
//         await storageRef.putFile(_selectedFile!);
//       }
//       fileUrl = await storageRef.getDownloadURL();
//       log(fileUrl);
//       String? senderEmail = FirebaseAuth.instance.currentUser?.email;

//       // Format the current date and time
//       String formattedDate = formatDate(DateTime.now());

//       // Store file data in Firestore
//       await FirebaseFirestore.instance.collection('inbox').add({
//         'file_url': fileUrl,
//         'file_type': fileType,
//         'senderEmail': senderEmail,
//         'reciverEmail': _slectedEmail,
//         'fileName': originalFileName,
//         'date': formattedDate, // Store the formatted date
//         'sizeOfFile': fileSizeString, // Store the formatted file size
//         'fileTypeForImage': fileTypeForImage,
//         'createdAt': Timestamp.now(),
//         'department': _slectedDep,
//       });

//       String doc1 = removeAfterAt(senderEmail!);
//       String doc2 = removeAfterAt(_slectedEmail);
//       String doc = '$doc1-$doc2';

//       await FirebaseFirestore.instance.collection('isRead').doc(doc).set({
//         'senderEmail': senderEmail,
//         'reciverEmail': _slectedEmail,
//         'read': false,
//       });

//       print('File uploaded successfully');
//     } else {
//       print('No file has been picked!');
//     }
//   }

//   bool _isLoading = false;

//   Future<void> _convertImageUrlToPdf(String imageUrl) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Download image from URL
//       http.Response response = await http.get(Uri.parse(imageUrl));
//       Uint8List imageData = response.bodyBytes;

//       // Convert image data to PDF
//       final pdf = pw.Document();
//       final image = pw.MemoryImage(imageData);

//       pdf.addPage(
//         pw.Page(
//           build: (pw.Context context) {
//             return pw.Center(
//               child: pw.Image(image),
//             );
//           },
//         ),
//       );

//       // Save or print the PDF document
//       final pdfData = await pdf.save();

//       await Printing.layoutPdf(
//         onLayout: (PdfPageFormat format) async => pdfData,
//       );
//     } catch (e) {
//       print("Error converting image URL to PDF: $e");
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future<void> _printPdfFromUrl(String url) async {
//     try {
//       // Fetch the PDF data from the URL
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         // Print the PDF document
//         await Printing.layoutPdf(
//           onLayout: (PdfPageFormat format) async => response.bodyBytes,
//         );
//       } else {
//         print('Failed to load PDF');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//         flex: 3,
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Column(
//                 children: [
//                   SizedBox(
//                     width: double.infinity,
//                     child: Card(
//                       child: Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: Column(
//                           children: [
//                             const Text(
//                               'الموظفين',
//                               textAlign: TextAlign.start,
//                             ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             StreamBuilder<QuerySnapshot>(
//                               stream: FirebaseFirestore.instance
//                                   .collection('isRead')
//                                   .where('reciverEmail', isEqualTo: myEmail)
//                                   .where('read', isEqualTo: false)
//                                   .snapshots(),
//                               builder: (context, snapshot) {
//                                 if (snapshot.connectionState ==
//                                     ConnectionState.waiting) {
//                                   return const Center(
//                                       child: CircularProgressIndicator());
//                                 }
//                                 if (snapshot.hasError) {
//                                   print('Error: ${snapshot.error}');
//                                   return Center(
//                                       child: Text('Error: ${snapshot.error}'));
//                                 }
//                                 if (!snapshot.hasData ||
//                                     snapshot.data!.docs.isEmpty) {
//                                   return const Center(child: Text('لا يوجد'));
//                                 }

//                                 var users = snapshot.data!.docs;
//                                 var count = users.length; // Count the documents

//                                 return Text(
//                                   'عدد الرسائل غير المقروءة: $count',
//                                   style: TextStyle(color: Colors.red),
//                                 );
//                               },
//                             ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             StreamBuilder<QuerySnapshot>(
//                               stream: FirebaseFirestore.instance
//                                   .collection('users')
//                                   .orderBy('department')
//                                   .snapshots(),
//                               builder: (context, snapshot) {
//                                 if (snapshot.connectionState ==
//                                     ConnectionState.waiting) {
//                                   return const Center(
//                                       child: CircularProgressIndicator());
//                                 }
//                                 if (snapshot.hasError) {
//                                   return Center(
//                                       child: Text('Error: ${snapshot.error}'));
//                                 }
//                                 if (!snapshot.hasData ||
//                                     snapshot.data!.docs.isEmpty) {
//                                   return Center(child: Text('لا يوجد'));
//                                 }

//                                 var users = snapshot.data!.docs;

//                                 return ListView.builder(
//                                   shrinkWrap: true,
//                                   padding: const EdgeInsets.all(8.0),
//                                   itemCount: users.length,
//                                   itemBuilder: (context, index) {
//                                     var user = users[index].data()
//                                         as Map<String, dynamic>;

//                                     return InkWell(
//                                       onTap: () => _employeesSelected(
//                                           user['name'],
//                                           user['email'],
//                                           user['image_url'],
//                                           user['department']),
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: ListTile(
//                                           leading: Stack(
//                                             children: [
//                                               ClipOval(
//                                                 child:
//                                                     user['image_url'] != null &&
//                                                             user['image_url']
//                                                                 .isNotEmpty
//                                                         ? Image.network(
//                                                             user['image_url'],
//                                                             fit: BoxFit.cover,
//                                                           )
//                                                         : Image.asset(
//                                                             'images/user.jpg',
//                                                             fit: BoxFit.cover,
//                                                           ),
//                                               ),
//                                               Positioned(
//                                                 right: 0,
//                                                 top: 0,
//                                                 child: StreamBuilder<
//                                                     QuerySnapshot>(
//                                                   stream: FirebaseFirestore
//                                                       .instance
//                                                       .collection('isRead')
//                                                       .where('reciverEmail',
//                                                           isEqualTo: myEmail)
//                                                       .where('senderEmail',
//                                                           isEqualTo:
//                                                               user['email'])
//                                                       .snapshots(),
//                                                   builder:
//                                                       (context2, snapshot2) {
//                                                     if (snapshot2
//                                                             .connectionState ==
//                                                         ConnectionState
//                                                             .waiting) {
//                                                       return const Center(
//                                                           child:
//                                                               CircularProgressIndicator());
//                                                     }
//                                                     if (snapshot2.hasError) {
//                                                       return Center(
//                                                           child: Text(
//                                                               'Error: ${snapshot2.error}'));
//                                                     }
//                                                     if (!snapshot2.hasData ||
//                                                         snapshot2.data!.docs
//                                                             .isEmpty) {
//                                                       return const Center(
//                                                           child: Text(''));
//                                                     }
//                                                     var readMessages = snapshot2
//                                                         .data!.docs
//                                                         .map((doc) => doc.data()
//                                                             as Map<String,
//                                                                 dynamic>)
//                                                         .toList();
//                                                     bool messageData =
//                                                         readMessages.isNotEmpty
//                                                             ? readMessages[0]
//                                                                 ['read']
//                                                             : false;

//                                                     return messageData == false
//                                                         ? const CircleAvatar(
//                                                             radius: 5,
//                                                             backgroundColor:
//                                                                 Colors.red,
//                                                           )
//                                                         : const Text('');
//                                                   },
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           title: Text(user['name']),
//                                           subtitle: Text(user['department']),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 );
//                               },
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               flex: 2,
//               child: SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.96,
//                 child: Card(
//                   child: _slectedEmail == ''
//                       ? const Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Center(
//                               child: Text('اختر محادثة'),
//                             )
//                           ],
//                         )
//                       : SingleChildScrollView(
//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(15.0),
//                                 child: Text('الصندوق الوارد مع $_slectedName'),
//                               ),
//                               ElevatedButton.icon(
//                                   onPressed: pickFile,
//                                   icon: const Icon(Icons.upload_file),
//                                   label: const Text('ارسال ملف')),
//                               const SizedBox(
//                                 height: 15,
//                               ),
//                               StreamBuilder<QuerySnapshot>(
//                                 stream: FirebaseFirestore.instance
//                                     .collection('inbox')
//                                     .where(Filter.or(
//                                       Filter.and(
//                                         Filter('reciverEmail',
//                                             isEqualTo: _slectedEmail),
//                                         Filter('senderEmail',
//                                             isEqualTo: myEmail),
//                                       ),
//                                       Filter.and(
//                                         Filter('senderEmail',
//                                             isEqualTo: _slectedEmail),
//                                         Filter('reciverEmail',
//                                             isEqualTo: myEmail),
//                                       ),
//                                     ))
//                                     .orderBy('createdAt', descending: true)
//                                     .snapshots(),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return const Center(
//                                         child: CircularProgressIndicator());
//                                   }
//                                   if (snapshot.hasError) {
//                                     print('Error: ${snapshot.error}');
//                                     return Center(
//                                         child:
//                                             Text('Error: ${snapshot.error}'));
//                                   }
//                                   if (!snapshot.hasData ||
//                                       snapshot.data!.docs.isEmpty) {
//                                     return const Center(child: Text('لا يوجد'));
//                                   }

//                                   var users = snapshot.data!.docs;

//                                   return ListView.builder(
//                                     shrinkWrap: true,
//                                     padding: const EdgeInsets.all(8.0),
//                                     itemCount: users.length,
//                                     itemBuilder: (context, index) {
//                                       var idDoc = users[index].id;
//                                       var user = users[index].data()
//                                           as Map<String, dynamic>;
//                                       String doc1 =
//                                           removeAfterAt(user['reciverEmail']);
//                                       String doc2 =
//                                           removeAfterAt(_slectedEmail);
//                                       String doc = '$doc2-$doc1';
//                                       updateReadStatus(doc);

//                                       return fileMessage(
//                                           context,
//                                           user['fileName'],
//                                           user['date'],
//                                           user['file_url'] ?? 'null',
//                                           user['file_type'],
//                                           user['sizeOfFile'],
//                                           myEmail == user['senderEmail']
//                                               ? true
//                                               : false,
//                                           user['file_type'] == 'jpg' ||
//                                                   user['file_type'] == 'png' ||
//                                                   user['file_type'] == 'pdf'
//                                               ? true
//                                               : false,
//                                           user['fileTypeForImage'],
//                                           idDoc,
//                                           user['department'],
//                                           _slectedDep);
//                                     },
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                 ),
//               ),
//             ),
//           ],
//         ));
//   }

//   Row fileMessage(
//       BuildContext context,
//       String title,
//       String date,
//       String url,
//       String typeFile,
//       String sizeOf,
//       bool isMe,
//       bool isPrintable,
//       String fileTypeForImage,
//       var idDoc,
//       String departmentOfTheReciver,
//       String localDep) {
//     return Row(
//       children: [
//         const SizedBox(
//           width: 10,
//         ),
//         Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.blueAccent, width: 2),
//           ),
//           child: ClipOval(
//             child: _slectedImage != ''
//                 ? isMe
//                     ? CircleAvatar(
//                         radius: 60,
//                         child: const Text('انا'),
//                         backgroundColor:
//                             Theme.of(context).colorScheme.onPrimary,
//                       )
//                     : Image.network(
//                         _slectedImage,
//                         fit: BoxFit.cover,
//                       )
//                 : Image.asset(
//                     'images/user.jpg',
//                     fit: BoxFit.cover,
//                   ),
//           ),
//         ),
//         const SizedBox(
//           width: 10,
//         ),
//         Expanded(
//           child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(6.0),
//               ),
//               color: isMe
//                   ? Theme.of(context).colorScheme.primaryContainer
//                   : Theme.of(context).colorScheme.secondaryContainer,
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       height: 40,
//                       child: Image.asset(
//                         'images/$fileTypeForImage.png',
//                       ),
//                     ),
//                     Expanded(
//                         child: Column(
//                       children: [
//                         Text(title),
//                         Directionality(
//                           textDirection: TextDirection.ltr,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(date),
//                               SizedBox(
//                                   width: 2), // Adjust the width to create space

//                               const SizedBox(
//                                   width:
//                                       10), // Adjust the width to create space
//                               Text(sizeOf),
//                             ],
//                           ),
//                         ),
//                       ],
//                     )),
//                     Row(
//                       children: [
//                         ElevatedButton.icon(
//                             style: ElevatedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(
//                                     10), // Adjust the value as needed
//                               ),
//                             ),
//                             onPressed: () async {
//                               // html.AnchorElement anchorElement =
//                               //     new html.AnchorElement(href: url);
//                               // anchorElement.download = url;
//                               // anchorElement.click();
//                               html.window.open(url, title);
//                             },
//                             icon: const Icon(Icons.download),
//                             label: const Text('تنزيل')),
//                         const SizedBox(
//                           width: 6,
//                         ),
//                         !isPrintable
//                             ? const Text('')
//                             : ElevatedButton.icon(
//                                 style: ElevatedButton.styleFrom(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(
//                                         10), // Adjust the value as needed
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   typeFile == 'pdf'
//                                       ? _printPdfFromUrl(url)
//                                       : _convertImageUrlToPdf(url);
//                                 },
//                                 icon: const Icon(Icons.print_rounded),
//                                 label: const Text('طباعة')),
//                         PopupMenuButton<String>(
//                           icon: const Icon(
//                             Icons.more_vert,
//                             color: Colors.white,
//                           ),
//                           onSelected: (String value) async {
//                             switch (value) {
//                               case 'Delete':
//                                 // Handle delete action
//                                 if (departmentOfTheReciver == localDep) {
//                                   FirebaseFirestore.instance
//                                       .collection('inbox')
//                                       .doc(idDoc)
//                                       .delete()
//                                       .then((_) async {
//                                     print("Document successfully deleted!");
//                                     await FirebaseStorage.instance
//                                         .refFromURL(url)
//                                         .delete()
//                                         .then((value) => print("deleted "));
//                                   }).catchError((error) {
//                                     print("Error removing document: $error");
//                                   });
//                                   break;
//                                 } else {
//                                   showTopSnackBar(
//                                     Overlay.of(context),
//                                     const CustomSnackBar.info(
//                                       message: 'لا يمكنك حذف رسائل الطرف الاخر',
//                                     ),
//                                   );
//                                 }
//                             }
//                           },
//                           itemBuilder: (BuildContext context) {
//                             return {'Delete'}.map((String choice) {
//                               return PopupMenuItem<String>(
//                                 value: choice,
//                                 child: Text(choice),
//                               );
//                             }).toList();
//                           },
//                         )
//                       ],
//                     )
//                   ],
//                 ),
//               )),
//         ),
//       ],
//     );
//   }
// }
