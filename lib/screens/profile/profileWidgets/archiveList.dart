import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:baghdadcompany/screens/profile/profileWidgets/screensSort/sortArchive.dart';
import 'package:date_format/date_format.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:universal_io/io.dart' as uio;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class Archivelist extends StatefulWidget {
  const Archivelist(
      {super.key,
      required this.id,
      required this.depOf,
      required this.date,
      required this.folderName,
      required this.nameOfUser});
  final String id;
  final String folderName;
  final String date;
  final String depOf;
  final String nameOfUser;

  @override
  State<Archivelist> createState() => _ArchivelistState();
}

class _ArchivelistState extends State<Archivelist> {
  final GlobalKey<FormState> _keyOfTitle = GlobalKey<FormState>();
  final GlobalKey<FormState> _keyOfTitleOnline = GlobalKey<FormState>();
  String titleOfLocalPdf = '';
  String titleOfLocalPdfOnline = '';
  String newTitleEdit = '';
  List<ItemOfDATA> selectedFiles = []; // To keep track of selected files

  final GlobalKey<FormState> _keyEdit = GlobalKey<FormState>();
  final GlobalKey<FormState> _keyEditTitle = GlobalKey<FormState>();

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> folderDataList = [];
  Future getFoldersDataList() async {
    try {
      folderDataList.clear();
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('archive')
          .doc(widget.depOf)
          .collection('archiveDep')
          .doc(widget.id)
          .collection('files')
          .where('deleted', isEqualTo: false)
          .orderBy('index')
          .orderBy('createdAt', descending: false)
          .get();

      for (var doc in querySnapshot.docs) {
        var item = doc.data() as Map<String, dynamic>;
        Timestamp createdAtTimestamp = item['createdIndexAt'] as Timestamp;
        DateTime createdAtDateTime = createdAtTimestamp.toDate();
        String finalDate = formatDate(
            DateTime(createdAtDateTime.year, createdAtDateTime.month,
                createdAtDateTime.day),
            [yyyy, '-', mm, '-', dd]);

        folderDataList.add({
          'iditems': widget.id,
          'iditem': doc.id,
          'title': item['title'],
          'folderName': item['folderName'],
          'createdBy': item['createdBy'],
          'type': item['type'],
          'fileUrl': item['fileUrl'],
          'department': widget.depOf,
          'createdIndexAt': item['createdIndexAt'],
          'index': item['index'],
          'finalDate': finalDate,
        });
      }
    } catch (e) {
      print("Error fetching folders: $e");
    }
  }

  var uuid = Uuid();

  //File? _selectedImage;
  final List<XFile> imageFileList = [];
  List<Item> items = [];
  int? _newItemIndex;
  final int splashDuration = 1200; // 400 milliseconds for splash effect
  bool _isUpload = false;

  void _deleteCheckedItems(List items) {
    setState(() {
      items.removeWhere((item) => item.isChecked);
    });
  }

  Future<void> _createAndAddPdf(String titleOfLocalPdf) async {
    final checkedItems = items.where((item) => item.isChecked).toList();
    bool isFile = checkedItems.any((val) => val.file == true);
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
    if (isFile) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'هذا الامر خاص بالصور فقط! لايمكنك دمج الملفات',
        ),
      );
    } else {
      final pdf = pw.Document();
      final pdfImageList = <pw.ImageProvider>[];

      final checkedItems = items.where((item) => item.isChecked).toList();

      if (checkedItems.isEmpty) {
        print('No items selected for PDF creation.');
        return;
      }

      for (final item in checkedItems) {
        pdfImageList.add(pw.MemoryImage(item.imageData));
      }

      for (final imageProvider in pdfImageList) {
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(imageProvider),
              );
            },
          ),
        );
      }

      final pdfBytes = await pdf.save();

      if (kIsWeb) {
        // Web-specific code (if needed)
      } else {
        final outputFile = File(
            '${(await getTemporaryDirectory()).path}/$titleOfLocalPdf.pdf');
        await outputFile.writeAsBytes(pdfBytes);
      }

      setState(() {
        items.add(Item('$titleOfLocalPdf.pdf', pdfBytes, false, true, 'pdf'));

        // Reset all checkboxes
        for (final item in items) {
          item.isChecked = false;
        }

        // Set the index of the new item
        _newItemIndex = items.length - 1;

        // Start the splash effect timer
        Future.delayed(Duration(milliseconds: splashDuration), () {
          setState(() {
            _newItemIndex = null; // Remove the splash effect
          });
        });
      });
    }
    Navigator.of(context).pop();
  }

  Future<void> _uploadFiles() async {
    bool allDatesSet = items.every((item) => item.date != null);

    if (allDatesSet) {
      final storageRef = FirebaseStorage.instance.ref();
      final firestoreRef = FirebaseFirestore.instance
          .collection('archive')
          .doc(widget.depOf)
          .collection('archiveDep')
          .doc(widget.id)
          .collection('files');
      setState(() {
        _isUpload = true;
      });
      // get last index
      int getLastIndex = 0;
      await FirebaseFirestore.instance
          .collection('archive')
          .doc(widget.depOf)
          .collection('archiveDep')
          .doc(widget.id)
          .collection('files')
          .where('deleted', isEqualTo: false)
          .orderBy('index', descending: true)
          .orderBy('createdAt', descending: false)
          .limit(1)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var lastDocument = querySnapshot.docs.first;
          print(lastDocument['index']);
          getLastIndex = lastDocument['index'] + 1;
          // Process the document as needed
        } else {
          // Handle the case when no documents are found
        }
      }).catchError((error) {
        // Handle errors here
        print("Error getting documents: $error");
      });

      for (int index = 0; index < items.length; index++) {
        final item = items[index];
        if (item.imageData.isNotEmpty) {
          try {
            // Create a unique file name
            String fullName = item.title;
            String nameBeforeDot = fullName.split('.').first;
            String nameAfterDot = fullName.split('.').last;

            String fileName = "${uuid.v4()}-${item.title}";
            String fileNameBeforeDot = fileName.split('.').first;

            //String fileNameFiltered = replaceArabicWithEnglish();

            // Upload the file to Firebase Storage
            final uploadRef = storageRef
                .child('الارشيف/${widget.depOf}/${Uri.file(fileName)}');
            final uploadTask = uploadRef.putData(item.imageData);

            // Wait for the upload to complete
            await uploadTask.whenComplete(() => null);

            // Get the file URL
            final fileUrl = await uploadRef.getDownloadURL();

            // Update Firestore with the file URL, title, date, and index
            await firestoreRef.add({
              // جاي نعتمد على الكرييتد ابو الاندكس بالتاريخ الحقيقي مال الانشاء بسسبب الخطا الي صار
              'title': nameBeforeDot,
              'type': nameAfterDot,
              'date': item.date,
              'createdAt': Timestamp.now(),
              'createdIndexAt': Timestamp.now(),
              'fileUrl': fileUrl,
              'index': getLastIndex, // Add index here
              'fileName': fileNameBeforeDot,
              'createdBy': widget.nameOfUser,
              'deleted': false,
              'folderName': widget.folderName
            });

            print('File uploaded and Firestore updated for ${item.title}');
          } catch (e) {
            print('Failed to upload file for ${item.title}: $e');
          }
        }
      }

      // Optionally, you can clear the list after uploading
      setState(() {
        items.clear();
        _isUpload = false;
      });
    } else {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'يتوجب عليك وضع تواريخ جميع الملفات',
        ),
      );
    }
  }

  openFileFromPath(String filePath) async {
    final Uri fileUri = Uri.file(filePath);

    try {
      if (await canLaunchUrl(fileUri)) {
        await launchUrl(fileUri);
      } else {
        print('----- of a');
        deleteEntryByFilePath(filePath);
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: 'حدث خطا,  اعد المحاولة',
          ),
        );
        throw 'Could not open file: $filePath';
      }
    } catch (e) {
      print(e);
      // print(filePath);
      print('----- of e');
      deleteEntryByFilePath(filePath);
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'حدث خطا, اعد المحاولة',
        ),
      );
    }
  }

  void deleteEntryByFilePath(String filePath) async {
    log('-------');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? downloadedData = prefs.getString('downloaded');

    if (downloadedData != null) {
      List<dynamic> downloadedList = json.decode(downloadedData);

      downloadedList.removeWhere((item) => item['filePath'] == filePath);

      // Save the updated list back to SharedPreferences
      String updatedData = json.encode(downloadedList);
      await prefs.setString('downloaded', updatedData);

      print('Entry with filePath $filePath deleted.');
    } else {
      print('No data found under the key "downloaded".');
    }
  }

  Future<Map<String, String>?> downloadFileFromUrl(
      String url, String customFilename) async {
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
      // Fetch the file data from the URL
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final filename = customFilename;

        final projectDir = Directory.current.path;
        final fileDir = path.join(projectDir, 'assets/filesDownloaded');
        final filePath = path.join(fileDir, filename);

        print('Directory path: $fileDir');
        print('File path: $filePath');

        final directory = Directory(fileDir);
        if (!directory.existsSync()) {
          print('Creating directory: $fileDir');
          directory.createSync(recursive: true);
        }

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print('File downloaded to $filePath');

        final prefs = await SharedPreferences.getInstance();

        // Retrieve and decode the existing list of downloaded files
        List downloadedFiles = [];
        final jsonString = prefs.getString('downloaded') ?? '[]';
        downloadedFiles = List.from(jsonDecode(jsonString));

        // Add the new file details including filePath
        downloadedFiles.add({
          'fileName': filename,
          'url': url,
          'filePath': filePath,
        });

        // Encode and store the updated list
        final updatedJsonString = jsonEncode(downloadedFiles);
        await prefs.setString('downloaded', updatedJsonString);

        print('URL, filename, and filePath saved to shared preferences');

        //Navigator.of(context).pop();

        // Return the map with the details
        return {
          'fileName': filename,
          'url': url,
          'filePath': filePath,
        };
      } else {
        print('Failed to download file. Status code: ${response.statusCode}');
        //Navigator.of(context).pop();
        return null;
      }
    } catch (e) {
      print('Error downloading file: $e');
      //Navigator.of(context).pop();
      return null;
    } finally {
      Navigator.of(context).pop();
    }
  }

  void searchForUrlAndDownloadOpen(
      String searchUrl, String fileNameFrom) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? downloadedData = prefs.getString('downloaded');

    if (downloadedData != null) {
      List<dynamic> downloadedList = json.decode(downloadedData);

      for (var item in downloadedList) {
        if (item['url'] == searchUrl) {
          // founed the file
          print('File found:');
          print('fileName: ${item['fileName']}');
          print('url: ${item['url']}');
          print('filePath: ${item['filePath']}');
          await openFileFromPath(item['filePath']);
          return;
        }
      }
      print('URL not found in stored data.');

      await downloadFileFromUrl(searchUrl, fileNameFrom);
      Map<String, String>? getPath =
          await downloadFileFromUrl(searchUrl, fileNameFrom);
      log(getPath!['filePath']!);
      await openFileFromPath(getPath['filePath']!);
    } else {
      print('No data found under the key "downloaded".');

      await downloadFileFromUrl(searchUrl, fileNameFrom);
      Map<String, String>? getPath =
          await downloadFileFromUrl(searchUrl, fileNameFrom);
      log(getPath!['filePath']!);
      await openFileFromPath(getPath['filePath']!);
    }
  }

  // ---

  Future<void> printFile(String url, String fileType) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        if (fileType == 'jpg' || fileType == 'jpeg' || fileType == 'png') {
          await printImage(bytes);
        } else if (fileType == 'pdf') {
          await printPdf(bytes);
        } else if (fileType == 'word' || fileType == 'excel') {
          // Convert Word/Excel to PDF and then print
          await printConvertedToPdf(bytes, fileType);
        }
      } else {
        throw Exception('Failed to load file');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> printImage(Uint8List bytes) async {
    final doc = pw.Document();
    final image = pw.MemoryImage(bytes);

    doc.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(child: pw.Image(image));
    }));

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  Future<void> printPdf(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  Future<void> printConvertedToPdf(Uint8List bytes, String fileType) async {
    // For demonstration, assuming you have a function to convert Word/Excel to PDF
    final pdfBytes = await convertToPdf(bytes, fileType);

    if (pdfBytes != null) {
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes);
    }
  }

  Future<Uint8List?> convertToPdf(Uint8List bytes, String fileType) async {
    // Implement the conversion logic or use an API service to convert files to PDF
    // For example, you can use a cloud service or a local library
    // This is a placeholder function and should be replaced with actual implementation
    return null;
  }

  // --

  // ---

  Future<void> generateUploadPdfAndUpdateFirestore(
      String fileName,
      String depOf,
      String nameBeforeDot,
      String nameAfterDot,
      int index) async {
    // Function to generate PDF from URLs
    //print(selectedFiles);
    List filterFiles = [];
    for (var val in selectedFiles) {
      filterFiles.add(val.file);
    }
    //List checkedItems = [];

    bool isFile = filterFiles.any((val) => val == true);

    if (isFile) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'هذا الامر خاص بالصور فقط! لايمكنك دمج الملفات',
        ),
      );
    } else {
      Future<Uint8List> generatePdfFromUrls(List<String> urls) async {
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
          final pdf = pw.Document();

          for (String url in urls) {
            if (url.contains('pdf')) {
              // If the URL points to a PDF, embed it as a text placeholder or handle appropriately
              final response = await http.get(Uri.parse(url));
              if (response.statusCode == 200) {
                final pdfData = response.bodyBytes;
                // Creating a placeholder page for the PDF
                pdf.addPage(
                  pw.Page(
                    build: (pw.Context context) {
                      return pw.Center(
                        child: pw.Text(
                          'Embedded PDF (cannot display inline)',
                          style: pw.TextStyle(fontSize: 20),
                        ),
                      );
                    },
                  ),
                );
              }
            } else {
              // If the URL points to an image, add it to the document
              final response = await http.get(Uri.parse(url));
              if (response.statusCode == 200) {
                final image = pw.MemoryImage(response.bodyBytes);
                pdf.addPage(
                  pw.Page(
                    build: (pw.Context context) {
                      return pw.Center(
                        child: pw.Image(image),
                      );
                    },
                  ),
                );
              }
            }
          }

          // Save the PDF document and return the bytes
          return await pdf.save();
        } finally {
          Navigator.of(context).pop();
        }
      }

      // Generate PDF from selected files
      List<String> urls = selectedFiles.map((file) => file.url).toList();
      Uint8List pdfData = await generatePdfFromUrls(urls);

      // Firebase Storage reference
      final storageRef = FirebaseStorage.instance.ref();
      final uploadRef = storageRef.child('الارشيف/$depOf/$nameBeforeDot');

      // Upload the PDF
      final uploadTask = uploadRef.putData(pdfData);
      await uploadTask.whenComplete(() => null);

      // Get the file URL
      final fileUrl = await uploadRef.getDownloadURL();

      // get last index number

      int getLastIndex = 0;
      await FirebaseFirestore.instance
          .collection('archive')
          .doc(widget.depOf)
          .collection('archiveDep')
          .doc(widget.id)
          .collection('files')
          .where('deleted', isEqualTo: false)
          .orderBy('index', descending: true)
          .orderBy('createdAt', descending: false)
          .limit(1)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var lastDocument = querySnapshot.docs.first;
          print(lastDocument['index']);
          getLastIndex = lastDocument['index'] + 1;
          // Process the document as needed
        } else {
          // Handle the case when no documents are found
        }
      }).catchError((error) {
        // Handle errors here
        print("Error getting documents: $error");
      });

      // Firestore reference
      final firestoreRef = FirebaseFirestore.instance
          .collection('archive')
          .doc(depOf)
          .collection('archiveDep')
          .doc(widget.id)
          .collection('files'); // Replace with your collection name

      // Update Firestore with the file URL, title, date, and index
      await firestoreRef.add({
        // جاي نعتمد على الكرييتد ابو الاندكس بالتاريخ الحقيقي مال الانشاء بسسبب الخطا الي صار

        'title': fileName,
        'type': nameAfterDot,
        'date': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'createdIndexAt': Timestamp.now(),
        'fileUrl': fileUrl,
        'index': getLastIndex,
        'fileName': nameBeforeDot,
        'createdBy': widget.nameOfUser,
        'deleted': false,
        'folderName': widget.folderName
      });
      _deleteCheckedItems(selectedFiles);
      selectedFiles.clear();
    }
  }

  // ---

  List<QueryDocumentSnapshot> filteredDocuments = [];
  List<QueryDocumentSnapshot> documents = [];

  void _filterDocuments() {
    setState(() {
      filteredDocuments = documents.where((doc) {
        String title = doc['title'] ?? 'اسم غير مسجل';
        return title.contains(_searchController.text);
      }).toList();
    });
  }

  late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    print(widget.depOf);

    _stream = FirebaseFirestore.instance
        .collection('archive')
        .doc(widget.depOf)
        .collection('archiveDep')
        .doc(widget.id)
        .collection('files')
        .where('deleted', isEqualTo: false)
        .orderBy('index')
        .orderBy('createdAt', descending: false)
        .snapshots();
    // جاي نعتمد على الكرييتد ابو الاندكس بالتاريخ الحقيقي مال الانشاء بسسبب الخطا الي صار
    _searchController.addListener(_filterDocuments);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _keyEdit;
    _keyOfTitle;
    _keyOfTitleOnline;
    _searchController;
  }

  @override
  Widget build(BuildContext context) {
    bool anyChecked = items.any((item) => item.isChecked);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          '${widget.folderName} ${widget.date}',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            Center(
              child: SizedBox(
                width: 700,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      items.isEmpty
                          ? InkWell(
                              onTap: () async {
                                final ImagePicker _picker = ImagePicker();

                                if (kIsWeb) {
                                  // Web platform
                                  final List<XFile>? selectedFiles = await _picker
                                      .pickMultiImage(); // Adjust this if you have a different file picker for web

                                  if (selectedFiles != null) {
                                    setState(() {
                                      imageFileList.clear();
                                      items.clear();
                                    });

                                    for (XFile file in selectedFiles) {
                                      final Uint8List bytes = await file
                                          .readAsBytes(); // Directly read bytes
                                      String type = file.name.split('.').last;
                                      bool isFile = false;
                                      switch (type) {
                                        case 'jpeg':
                                          isFile = false;
                                          break;
                                        case 'jpg':
                                          isFile = false;
                                          break;
                                        case 'png':
                                          isFile = false;
                                          break;
                                        default:
                                          isFile = true;
                                      }
                                      String typeAfterFilter = 'un';

                                      switch (type) {
                                        case 'doc':
                                        case 'docx':
                                        case 'dot':
                                        case 'dotx':
                                          typeAfterFilter = 'doc';
                                          break;
                                        case 'xls':
                                        case 'xlsx':
                                        case 'xlsm':
                                        case 'xltx':
                                        case 'csv':
                                          typeAfterFilter = 'xlsx';
                                          break;
                                        case 'pdf':
                                          typeAfterFilter = 'pdf';
                                          break;
                                        case 'jpg':
                                        case 'jpeg':
                                        case 'jfif':
                                          typeAfterFilter = 'jpg';
                                          break;
                                        case 'png':
                                          typeAfterFilter = 'png';
                                          break;
                                        case 'gif':
                                          typeAfterFilter = 'jpg';
                                          break;

                                        case 'heif':
                                        case 'heic':
                                          typeAfterFilter = 'jpg';
                                          break;
                                        default:
                                          typeAfterFilter = 'un';
                                      }
                                      setState(() {
                                        imageFileList.add(file);
                                        items.add(Item(file.name, bytes, false,
                                            isFile, typeAfterFilter));
                                      });
                                    }
                                    print(
                                        "File List Length: ${imageFileList.length}");
                                    print('web');
                                  } else {
                                    print('No files have been picked!');
                                  }
                                } else if (uio.Platform.isWindows) {
                                  // Windows platform
                                  final result =
                                      await FilePicker.platform.pickFiles(
                                    allowMultiple: true,
                                    type: FileType.any, // Allow any file type
                                  );

                                  if (result != null &&
                                      result.files.isNotEmpty) {
                                    setState(() {
                                      imageFileList.clear();
                                      items.clear();
                                    });

                                    for (var pickedFile in result.files) {
                                      if (pickedFile.path != null) {
                                        final file = File(pickedFile.path!);
                                        final bytes = await file.readAsBytes();

                                        String type =
                                            pickedFile.name.split('.').last;
                                        bool isFile = false;
                                        switch (type) {
                                          case 'jpeg':
                                            isFile = false;
                                            break;
                                          case 'jpg':
                                            isFile = false;
                                            break;
                                          case 'png':
                                            isFile = false;
                                            break;
                                          default:
                                            isFile = true;
                                        }
                                        String typeAfterFilter = 'un';

                                        switch (type) {
                                          case 'doc':
                                          case 'docx':
                                          case 'dot':
                                          case 'dotx':
                                            typeAfterFilter = 'doc';
                                            break;
                                          case 'xls':
                                          case 'xlsx':
                                          case 'xlsm':
                                          case 'xltx':
                                          case 'csv':
                                            typeAfterFilter = 'xlsx';
                                            break;
                                          case 'pdf':
                                            typeAfterFilter = 'pdf';
                                            break;
                                          case 'jpg':
                                          case 'jpeg':
                                          case 'jfif':
                                            typeAfterFilter = 'jpg';
                                            break;
                                          case 'png':
                                            typeAfterFilter = 'png';
                                            break;
                                          case 'gif':
                                            typeAfterFilter = 'jpg';
                                            break;

                                          case 'heif':
                                          case 'heic':
                                            typeAfterFilter = 'jpg';
                                            break;
                                          default:
                                            typeAfterFilter = 'un';
                                        }

                                        setState(() {
                                          imageFileList.add(XFile(pickedFile
                                              .path!)); // Wrap the file path in XFile for consistency
                                          items.add(Item(pickedFile.name, bytes,
                                              false, isFile, typeAfterFilter));
                                        });
                                      }
                                    }
                                    print(
                                        "File List Length: ${imageFileList.length}");
                                    print('windows');
                                  } else {
                                    print('No files have been picked!');
                                  }
                                } else {
                                  // Mobile platforms
                                  final XFile? file = await _picker.pickImage(
                                      source: ImageSource
                                          .gallery); // You may need to use a different file picker for non-image files on mobile

                                  if (file != null) {
                                    var selected = File(file.path);
                                    final bytes = await selected.readAsBytes();
                                    String type = file.name.split('.').last;
                                    bool isFile = false;
                                    switch (type) {
                                      case 'jpeg':
                                        isFile = false;
                                        break;
                                      case 'jpg':
                                        isFile = false;
                                        break;
                                      case 'png':
                                        isFile = false;
                                        break;
                                      default:
                                        isFile = true;
                                    }

                                    String typeAfterFilter = 'un';

                                    switch (type) {
                                      case 'doc':
                                      case 'docx':
                                      case 'dot':
                                      case 'dotx':
                                        typeAfterFilter = 'doc';
                                        break;
                                      case 'xls':
                                      case 'xlsx':
                                      case 'xlsm':
                                      case 'xltx':
                                      case 'csv':
                                        typeAfterFilter = 'xlsx';
                                        break;
                                      case 'pdf':
                                        typeAfterFilter = 'pdf';
                                        break;
                                      case 'jpg':
                                      case 'jpeg':
                                      case 'jfif':
                                        typeAfterFilter = 'jpg';
                                        break;
                                      case 'png':
                                        typeAfterFilter = 'png';
                                        break;
                                      case 'gif':
                                        typeAfterFilter = 'jpg';
                                        break;

                                      case 'heif':
                                      case 'heic':
                                        typeAfterFilter = 'jpg';
                                        break;
                                      default:
                                        typeAfterFilter = 'un';
                                    }

                                    setState(() {
                                      imageFileList.add(file);
                                      items.add(Item(file.name, bytes, false,
                                          isFile, typeAfterFilter));
                                    });
                                    print('mobile');
                                  } else {
                                    print('No files have been picked!');
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DottedBorder(
                                  borderType: BorderType.Rect,
                                  dashPattern: [8, 4],
                                  child: Container(
                                    height: 50,
                                    child: Center(
                                      child: Text('رفع الملفات'),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 600,
                              child: ReorderableListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                onReorder: (oldIndex, newIndex) {
                                  setState(() {
                                    if (newIndex > oldIndex) {
                                      newIndex -= 1;
                                    }
                                    final Item item = items.removeAt(oldIndex);
                                    items.insert(newIndex, item);
                                  });
                                },
                                children: List.generate(items.length, (index) {
                                  final item = items[index];
                                  return Padding(
                                    key: ValueKey(item),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Container(
                                      color: _newItemIndex == index
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                          : Colors.transparent, // Splash effect
                                      child: ListTile(
                                        onTap: () {
                                          DateTime? selectedDate = item.date;
                                          String titleTextFiled = item.title;
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              final TextEditingController
                                                  _dateController =
                                                  TextEditingController(
                                                text: selectedDate != null
                                                    ? "${selectedDate?.toLocal().toIso8601String().split('T')[0]}"
                                                    : '',
                                              );

                                              return SingleChildScrollView(
                                                child: Directionality(
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  child: AlertDialog(
                                                    title: const Text('تعديل'),
                                                    content: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: Form(
                                                        key: _keyEdit,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            item.file
                                                                ? Image.asset(
                                                                    'images/${item.type}.png')
                                                                : Image.memory(item
                                                                    .imageData),
                                                            const SizedBox(
                                                                height: 10),
                                                            TextFormField(
                                                              // controller:
                                                              //     _dateController,
                                                              initialValue: item
                                                                  .title
                                                                  .split('.')
                                                                  .first,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                              decoration:
                                                                  const InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                labelText:
                                                                    'اسم الملف',
                                                                suffixIcon:
                                                                    Icon(Icons
                                                                        .description),
                                                              ),
                                                              validator: (val) {
                                                                if (val ==
                                                                        null ||
                                                                    val.isEmpty) {
                                                                  return '';
                                                                }
                                                                return null;
                                                              },

                                                              onChanged: (val) {
                                                                titleTextFiled =
                                                                    '$val.${item.title.split('.').last}';
                                                              },
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            TextFormField(
                                                              controller:
                                                                  _dateController,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                              decoration:
                                                                  const InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                labelText:
                                                                    'التاريخ',
                                                                suffixIcon:
                                                                    Icon(Icons
                                                                        .calendar_today),
                                                              ),
                                                              readOnly: true,
                                                              onTap: () async {
                                                                final DateTime?
                                                                    pickedDate =
                                                                    await showDatePicker(
                                                                  context:
                                                                      context,
                                                                  initialDate:
                                                                      selectedDate ??
                                                                          DateTime
                                                                              .now(),
                                                                  firstDate:
                                                                      DateTime(
                                                                          2000),
                                                                  lastDate:
                                                                      DateTime(
                                                                          2101),
                                                                );
                                                                if (pickedDate !=
                                                                    null) {
                                                                  setState(() {
                                                                    selectedDate =
                                                                        pickedDate;
                                                                    _dateController
                                                                            .text =
                                                                        "${pickedDate.toLocal().toIso8601String().split('T')[0]}";
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    actions: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  if (selectedDate !=
                                                                      null) {
                                                                    items.forEach(
                                                                        (item) {
                                                                      setState(
                                                                          () {
                                                                        item.date =
                                                                            selectedDate!;
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                                child: Text(
                                                                  'تعيين هذا التاريخ للجميع',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .inverseSurface,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  print(
                                                                      titleTextFiled);
                                                                  var vaild = _keyEdit
                                                                      .currentState!
                                                                      .validate();
                                                                  if (!vaild) {
                                                                    return;
                                                                  }
                                                                  print(
                                                                      titleTextFiled);
                                                                  setState(() {
                                                                    item.title =
                                                                        titleTextFiled;
                                                                  });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();

                                                                  if (selectedDate !=
                                                                      null) {
                                                                    setState(
                                                                        () {
                                                                      item.date =
                                                                          selectedDate!;
                                                                    });
                                                                  }
                                                                },
                                                                child: Text(
                                                                  'اضافة',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .inverseSurface,
                                                                  ),
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  'الغاء',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .secondaryContainer,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        leading: item.file
                                            ? Image.asset(
                                                'images/${item.type}.png')
                                            : Image.memory(item.imageData),
                                        title: Text(item.title),
                                        subtitle: item.date != null
                                            ? Text(
                                                "${item.date?.toLocal().toIso8601String().split('T')[0]}")
                                            : const Text(
                                                'لم يتم تحديد التاريخ',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                        trailing: Checkbox(
                                          value: item.isChecked,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              item.isChecked = value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                      items.isEmpty
                          ? const Text('')
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: anyChecked
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.spaceBetween,
                                children: [
                                  if (anyChecked) ...[
                                    ElevatedButton(
                                      onPressed: () {
                                        for (final item in items) {
                                          setState(() {
                                            item.isChecked = false;
                                          });
                                        }
                                      },
                                      child: const Text('الغاء التحديد'),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        int n = 0;
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'من اي رقم يبدا التسلسل؟'),
                                              content: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SpinBox(
                                                    min: 1,
                                                    max: 100,
                                                    value: 1,
                                                    textStyle: const TextStyle(
                                                      color: Colors
                                                          .blue, // Change the text color here
                                                      fontSize: 24,
                                                    ),
                                                    step: 1,
                                                    incrementIcon: const Icon(
                                                      Icons.arrow_upward,
                                                      color: Colors
                                                          .green, // Change the increment button color here
                                                    ),
                                                    decrementIcon: const Icon(
                                                      Icons.arrow_downward,
                                                      color: Colors
                                                          .red, // Change the decrement button color here
                                                    ),
                                                    decoration: InputDecoration(
                                                      fillColor: Colors.grey[
                                                          200], // Change the background color here
                                                      filled: true,
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .black), // Change the border color here
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      print(value);
                                                      setState(() {
                                                        n = value.toInt();
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    'الغاء',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    // Handle the input values here
                                                    List<Map> filter = [];
                                                    for (var i = 0;
                                                        i < items.length;
                                                        i++) {
                                                      var item = items[i];
                                                      if (!item.isChecked) {
                                                        continue;
                                                      }
                                                      filter.add({
                                                        'title': item.title,
                                                        'id': i
                                                      });
                                                    }
                                                    // loop filter
                                                    if (n == 0) {
                                                      n = 0;
                                                    } else if (n == 1) {
                                                      n = 1;
                                                    } else {
                                                      n = n - 1;
                                                    }
                                                    for (var i = 0;
                                                        i < filter.length;
                                                        i++) {
                                                      n++;
                                                      var f = filter[i];
                                                      print(
                                                          '${f['title']} ===');
                                                      String nameBeforeDot =
                                                          f['title']
                                                              .split('.')
                                                              .first;
                                                      String nameAfterDot =
                                                          f['title']
                                                              .split('.')
                                                              .last;
                                                      print(nameAfterDot);

                                                      String fileOrImage =
                                                          nameAfterDot;
                                                      switch (fileOrImage) {
                                                        case 'jpg':
                                                        case 'jpeg':
                                                        case 'png':
                                                          fileOrImage = 'صورة';
                                                          break;
                                                        default:
                                                          fileOrImage = 'ملف';
                                                      }

                                                      nameBeforeDot =
                                                          '$fileOrImage رقم ${i + 1}';
                                                      print('$nameBeforeDot');
                                                      print(nameAfterDot);
                                                      setState(() {
                                                        items[f['id']].title =
                                                            '$fileOrImage رقم ${n}.$nameAfterDot';
                                                      });
                                                    }
                                                    for (final item in items) {
                                                      setState(() {
                                                        item.isChecked = false;
                                                      });
                                                    }
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('تطبيق'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Text(
                                          'ترقيم اسماء الملفات بالتسلسل'),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        _deleteCheckedItems(items);
                                      },
                                      child: Text('حذف'),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: AlertDialog(
                                                title:
                                                    const Text('ضع اسما للملف'),
                                                content: SizedBox(
                                                  width: 600,
                                                  child: Form(
                                                    key: _keyOfTitle,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        TextFormField(
                                                          onChanged: (val) {
                                                            titleOfLocalPdf =
                                                                val;
                                                          },
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty ||
                                                                value
                                                                        .trim()
                                                                        .length <
                                                                    2) {
                                                              return '';
                                                            }
                                                            return null;
                                                          },
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                          decoration:
                                                              const InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            labelText:
                                                                'اسم الملف',
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      final valid = _keyOfTitle
                                                          .currentState!
                                                          .validate();
                                                      if (!valid) {
                                                      } else {
                                                        _createAndAddPdf(
                                                            titleOfLocalPdf);
                                                      }
                                                    },
                                                    child: Text(
                                                      'اضافة',
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .inverseSurface),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text(
                                                      'الغاء',
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .secondaryContainer),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Text('pdf انشاء'),
                                    ),
                                  ] else ...[
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          _isUpload
                                              ? const SizedBox()
                                              : ElevatedButton(
                                                  onPressed: () {
                                                    for (var i = 0;
                                                        i < items.length;
                                                        i++) {
                                                      setState(() {
                                                        items[i].isChecked =
                                                            true;
                                                      });
                                                    }
                                                  },
                                                  child:
                                                      const Text('تحديد الكل'),
                                                )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          !_isUpload
                                              ? TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      items.clear();
                                                    });
                                                  },
                                                  child: Text('الغاء'),
                                                )
                                              : const Text(''),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          !_isUpload
                                              ? ElevatedButton(
                                                  onPressed: () {
                                                    _uploadFiles(); // Call the method to upload files and update Firestore
                                                  },
                                                  child: const Text('رفع'),
                                                )
                                              : const CircularProgressIndicator(),
                                        ],
                                      ),
                                    )
                                  ],
                                ],
                              ),
                            )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),

            selectedFiles.isEmpty
                ? const SizedBox()
                : SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    selectedFiles.clear();
                                  });
                                },
                                label: const Text('الغاء التحديد'),
                                icon: const Icon(Icons.close),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  int n = 1;
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                            'من اي رقم يبدا التسلسل؟'),
                                        content: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SpinBox(
                                              min: 1,
                                              max: 100,
                                              value: 1,
                                              textStyle: const TextStyle(
                                                color: Colors
                                                    .blue, // Change the text color here
                                                fontSize: 24,
                                              ),
                                              step: 1,
                                              incrementIcon: const Icon(
                                                Icons.arrow_upward,
                                                color: Colors
                                                    .green, // Change the increment button color here
                                              ),
                                              decrementIcon: const Icon(
                                                Icons.arrow_downward,
                                                color: Colors
                                                    .red, // Change the decrement button color here
                                              ),
                                              decoration: InputDecoration(
                                                fillColor: Colors.grey[
                                                    200], // Change the background color here
                                                filled: true,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                      color: Colors
                                                          .black), // Change the border color here
                                                ),
                                              ),
                                              onChanged: (value) {
                                                print(' xx xx $value');
                                                setState(() {
                                                  n = value.toInt();
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              'الغاء',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Handle the input values here
                                              Navigator.of(context).pop();
                                              List<Map> filter = [];
                                              for (var i = 0;
                                                  i < selectedFiles.length;
                                                  i++) {
                                                var item = selectedFiles[i];
                                                if (!item.isChecked) {
                                                  continue;
                                                }
                                                filter.add({
                                                  'title': item.title,
                                                  'id': i,
                                                  'type': item.file,
                                                  'iditem': item.idOfItem
                                                });
                                              }
                                              // loop filter
                                              // if (n == 0) {
                                              //   n = 0;
                                              // } else if (n == 1) {
                                              //   n = 1 - 1;
                                              // } else {
                                              //   n = n - 1;
                                              // }
                                              //print(filter);

                                              for (var i = 0;
                                                  i < filter.length;
                                                  i++) {
                                                var f = filter[i];

                                                String nameBeforeDot =
                                                    f['title'];

                                                String fileOrImage =
                                                    f['type'] ? 'ملف' : 'صورة';

                                                nameBeforeDot =
                                                    '$fileOrImage رقم $n';
                                                print(
                                                    '-- $nameBeforeDot --${f['iditem']}');

                                                // setState(() {
                                                //   selectedFiles[f['id']].title =
                                                //       '$fileOrImage رقم $n';
                                                // });

                                                await FirebaseFirestore.instance
                                                    .collection('archive')
                                                    .doc(widget.depOf)
                                                    .collection('archiveDep')
                                                    .doc(widget.id)
                                                    .collection('files')
                                                    .doc(f['iditem'])
                                                    .update({
                                                  'title': nameBeforeDot,
                                                });
                                                n++;
                                              }

                                              setState(() {
                                                selectedFiles.clear();
                                                n = 1;
                                              });
                                            },
                                            child: const Text('تطبيق'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                label: const Text('ترقيم'),
                                icon:
                                    const Icon(Icons.format_list_numbered_rtl),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: AlertDialog(
                                          title: const Text('تعديل'),
                                          content: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                            height: 130,
                                            child: Form(
                                              key: _keyEditTitle,
                                              child: Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                      'سيتم تغيير جميع اسماء الملفات المحددة للاسم الذي ستضعه',
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    TextFormField(
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        labelText:
                                                            'اسم الملف الجديد',
                                                        suffixIcon: Icon(
                                                            Icons.description),
                                                      ),
                                                      validator: (val) {
                                                        if (val == null ||
                                                            val.isEmpty ||
                                                            val
                                                                .trim()
                                                                .isEmpty) {
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
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        var vaild =
                                                            _keyEditTitle
                                                                .currentState!
                                                                .validate();
                                                        if (vaild) {
                                                          selectedFiles.forEach(
                                                              (val) async {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'archive')
                                                                .doc(widget
                                                                    .depOf)
                                                                .collection(
                                                                    'archiveDep')
                                                                .doc(widget.id)
                                                                .collection(
                                                                    'files')
                                                                .doc(val
                                                                    .idOfItem)
                                                                .update({
                                                              'title':
                                                                  newTitleEdit,
                                                            });
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      },
                                                      child: Text(
                                                        'تعديل',
                                                        style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .inverseSurface,
                                                        ),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text(
                                                        'الغاء',
                                                        style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .secondaryContainer,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                label: const Text('تعديل'),
                                icon: const Icon(Icons.edit),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'حذف',
                                          textAlign: TextAlign.right,
                                        ),
                                        content: const Text(
                                            'هل تريد حذف هذه الملفات؟',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: Colors.black87)),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text(
                                              'الغاء',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          ElevatedButton(
                                            child: const Text(
                                              'حذف',
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              selectedFiles
                                                  .forEach((valx) async {
                                                print(valx.isChecked);
                                                print(valx.idOfItem);
                                                if (valx.isChecked) {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('archive')
                                                      .doc(widget.depOf)
                                                      .collection('archiveDep')
                                                      .doc(widget.id)
                                                      .collection('files')
                                                      .doc(valx.idOfItem)
                                                      .update({
                                                    'deleted': true,
                                                    'deletedBy':
                                                        widget.nameOfUser,
                                                    'deleatedAt':
                                                        Timestamp.now()
                                                  }).then((_) {
                                                    setState(() {
                                                      selectedFiles.clear();
                                                    });
                                                  });
                                                  print('ok');
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                label: const Text('حذف'),
                                icon: const Icon(Icons.delete),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: AlertDialog(
                                          title: const Text('ضع اسما للملف'),
                                          content: SizedBox(
                                            width: 600,
                                            child: Form(
                                              key: _keyOfTitleOnline,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextFormField(
                                                    onChanged: (val) {
                                                      titleOfLocalPdfOnline =
                                                          val;
                                                    },
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty ||
                                                          value.trim().length <
                                                              2) {
                                                        return '';
                                                      }
                                                      return null;
                                                    },
                                                    style: const TextStyle(
                                                        color: Colors.black),
                                                    decoration:
                                                        const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                      labelText: 'اسم الملف',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                ],
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                final valid = _keyOfTitleOnline
                                                    .currentState!
                                                    .validate();
                                                if (!valid) {
                                                } else {
                                                  await generateUploadPdfAndUpdateFirestore(
                                                      titleOfLocalPdfOnline,
                                                      widget.depOf,
                                                      '${uuid.v4()}-$titleOfLocalPdfOnline',
                                                      'pdf',
                                                      0);
                                                }
                                              },
                                              child: Text(
                                                'اضافة',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .inverseSurface),
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
                                                        .secondaryContainer),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                label: const Text('انشاء pdf'),
                                icon: const Icon(Icons.picture_as_pdf_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(
              height: 1,
            ),

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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.88,
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                await getFoldersDataList();
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (ctx) {
                                  return SortArchive(
                                    folderDataList: folderDataList,
                                    isFolder: false,
                                  );
                                }));
                              },
                              label: const Text('تعديل الترتيب'),
                              icon: Icon(Icons.format_list_numbered_rtl),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            selectedFiles.isNotEmpty
                                ? const SizedBox()
                                : ElevatedButton.icon(
                                    onPressed: () async {
                                      await getFoldersDataList();
                                      print(folderDataList);
                                      for (var i = 0;
                                          i < folderDataList.length;
                                          i++) {
                                        bool isFile = false;
                                        switch (folderDataList[i]['type']) {
                                          case 'jpeg':
                                            isFile = false;
                                            break;
                                          case 'jpg':
                                            isFile = false;
                                            break;
                                          case 'png':
                                            isFile = false;
                                            break;
                                          default:
                                            isFile = true;
                                        }

                                        setState(() {
                                          selectedFiles.add(ItemOfDATA(
                                            folderDataList[i]['title'],
                                            folderDataList[i]['fileUrl'],
                                            true,
                                            isFile,
                                            folderDataList[i]['iditem'],
                                          ));
                                        });
                                        print(selectedFiles[i].isChecked);
                                      }
                                    },
                                    label: const Text('تحديد الكل'),
                                    icon: const Icon(Icons.checklist),
                                  ),
                          ],
                        ),
                      ),
                      const Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [],
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ), // Padding between the cards
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Center(
                  child: Card(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _stream,
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

                    documents = snapshot.data!.docs;
                    filteredDocuments = documents.where((doc) {
                      String title = doc['title'] ?? 'اسم غير مسجل';
                      return title.contains(_searchController.text);
                    }).toList();

                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10.0),
                        itemCount: filteredDocuments.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          var doc = filteredDocuments[index];
                          bool isPdfFile =
                              doc['fileUrl'].toString().contains('pdf');
                          bool isPdfFileFromDoc = false;
                          String getType = 'un';

                          switch (doc['type']) {
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

                          bool isFile = false;
                          switch (doc['type']) {
                            case 'jpeg':
                              isFile = false;
                              break;
                            case 'jpg':
                              isFile = false;
                              break;
                            case 'png':
                              isFile = false;
                              break;
                            default:
                              isFile = true;
                          }

                          ItemOfDATA item = ItemOfDATA(
                            doc['title'] ?? 'اسم غير مسجل',
                            doc['fileUrl'],
                            false, // Initially not selected
                            isFile,
                            doc.id,
                          );

                          bool isSelected = selectedFiles.any(
                            (selectedItem) => selectedItem.url == item.url,
                          );

                          Timestamp createdAtTimestamp = doc['date'];
                          DateTime createdAtDateTime =
                              createdAtTimestamp.toDate();
                          String finalDate = formatDate(
                              DateTime(
                                  createdAtDateTime.year,
                                  createdAtDateTime.month,
                                  createdAtDateTime.day),
                              [yyyy, '-', mm, '-', dd]);

                          return InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: Row(
                                children: [
                                  Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedFiles.add(ItemOfDATA(
                                            item.title,
                                            item.url,
                                            true,
                                            item.file,
                                            item.idOfItem,
                                          ));
                                        } else {
                                          selectedFiles.removeWhere(
                                            (selectedItem) =>
                                                selectedItem.url == item.url,
                                          );
                                        }
                                      });
                                    },
                                  ),
                                  isPdfFile || isPdfFileFromDoc
                                      ? Image.asset(
                                          'images/$getType.png',
                                          width: 50.0,
                                          height: 50.0,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          doc['fileUrl'],
                                          width: 50.0,
                                          height: 50.0,
                                          fit: BoxFit.cover,
                                        ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 4,
                                    child: ListTile(
                                      title: Text(
                                        '${doc['title'] ?? 'اسم غير مسجل'}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        finalDate,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        searchForUrlAndDownloadOpen(
                                          doc['fileUrl'],
                                          '${Uri.file(doc['fileName'])}.${doc['type']}',
                                        );
                                      },
                                      label: const Text('فتح'),
                                      icon: const Icon(Icons.open_in_new),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        if (doc['type'] == 'jpg' ||
                                            doc['type'] == 'jpeg' ||
                                            doc['type'] == 'png' ||
                                            doc['type'] == 'pdf') {
                                          await printFile(
                                              doc['fileUrl'], doc['type']);
                                        } else {
                                          searchForUrlAndDownloadOpen(
                                            doc['fileUrl'],
                                            '${Uri.file(doc['fileName'])}.${doc['type']}',
                                          );
                                        }
                                      },
                                      label: const Text('طباعة'),
                                      icon: const Icon(Icons.print_rounded),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              )),
            )
          ],
        ),
      ),
    );
  }
}

class Item {
  Item(this.title, this.imageData, this.isChecked, this.file, this.type,
      [this.date]);

  String title;
  Uint8List imageData;
  bool isChecked;
  bool file;
  DateTime? date;
  String type;
}

class ItemOfDATA {
  ItemOfDATA(this.title, this.url, this.isChecked, this.file, this.idOfItem);

  String title;
  String url;
  bool isChecked;
  bool file;
  String idOfItem;
}
