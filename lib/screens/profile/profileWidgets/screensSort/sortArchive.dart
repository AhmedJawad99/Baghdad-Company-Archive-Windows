import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SortArchive extends StatefulWidget {
  const SortArchive(
      {super.key, required this.folderDataList, required this.isFolder});
  final List<Map<String, dynamic>> folderDataList;
  final bool isFolder;

  @override
  State<SortArchive> createState() => _SortArchiveState();
}

class _SortArchiveState extends State<SortArchive> {
  late List<Map<String, dynamic>> _reorderedList;
  late List<Map<String, dynamic>> checkListNoChange;

  bool listsAreEqual = true;

  void compareListsForFolders(
      List<Map<String, dynamic>> list1, List<Map<String, dynamic>> list2) {
    if (list1.length != list2.length) {
      print('Lists have different lengths.');
      listsAreEqual = false;
      return;
    }

    for (int i = 0; i < list1.length; i++) {
      Map<String, dynamic> item1 = list1[i];
      Map<String, dynamic> item2 = list2[i];

      if (item1['folderName'] != item2['folderName'] ||
          item1['index'] != item2['index']) {
        print('Difference found at index $i:');
        print('List1: $item1');
        print('List2: $item2');
        listsAreEqual = false;
        return;
      }
    }
  }

  void compareListsForFiles(
      List<Map<String, dynamic>> list1, List<Map<String, dynamic>> list2) {
    if (list1.length != list2.length) {
      print('Lists have different lengths.');
      listsAreEqual = false;
      return;
    }

    for (int i = 0; i < list1.length; i++) {
      Map<String, dynamic> item1 = list1[i];
      Map<String, dynamic> item2 = list2[i];

      if (item1['title'] != item2['title'] ||
          item1['index'] != item2['index']) {
        print('Difference found at index $i:');
        print('List1: $item1');
        print('List2: $item2');
        listsAreEqual = false;
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _reorderedList = List.from(widget.folderDataList);
    checkListNoChange = List.from(widget.folderDataList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Reorderable List'),
        leading: IconButton(
          onPressed: () async {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                    'حفظ التعديل',
                    textAlign: TextAlign.right,
                  ),
                  content: const Text(
                    'هل تريد حفظ التعديل الذي اجريته؟',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.black87),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'الغاء',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          if (widget.isFolder) {
                            compareListsForFolders(
                                _reorderedList, checkListNoChange);
                            print('--- $listsAreEqual ');
                            if (!listsAreEqual) {
                              print('object');
                              for (var val in _reorderedList) {
                                print('${val['index']} ${val['folderName']}');
                                await FirebaseFirestore.instance
                                    .collection('archive')
                                    .doc(val['department'])
                                    .collection('archiveDep')
                                    .doc(val['id'])
                                    .update({
                                  'index': val['index'],
                                  'createdAtindex': Timestamp.now(),
                                });
                              }
                            }
                          } else {
                            compareListsForFiles(
                                _reorderedList, checkListNoChange);
                            print('--- x $listsAreEqual ');
                            if (!listsAreEqual) {
                              print('object');
                              for (var val in _reorderedList) {
                                print('${val['index']} ${val['folderName']}');
                                await FirebaseFirestore.instance
                                    .collection('archive')
                                    .doc(val['department'])
                                    .collection('archiveDep')
                                    .doc(val['iditems'])
                                    .collection('files')
                                    .doc(val['iditem'])
                                    .update({
                                  'index': val['index'],
                                  'createdAt': Timestamp.now(),
                                });
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('حفظ')),
                  ],
                );
              },
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
              // ElevatedButton(
              //   onPressed: () {
              //     print(_reorderedList);
              //   },
              //   child: Text('Print List'),
              // ),
              const SizedBox(
                  height:
                      16.0), // Add some space between the button and the list
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ReorderableListView(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = _reorderedList.removeAt(oldIndex);
                          _reorderedList.insert(newIndex, item);
                          // Update the index of each item
                          for (int i = 0; i < _reorderedList.length; i++) {
                            _reorderedList[i]['index'] = i;
                          }
                        });
                      },
                      children: List.generate(_reorderedList.length, (index) {
                        final item = _reorderedList[index];
                        return Padding(
                            key: ValueKey(widget.isFolder
                                ? item['id']
                                : item[
                                    'iditem']), // Ensure each item has a unique key
                            padding: const EdgeInsets.only(
                                top: 5, left: 20, right: 20),
                            child: widget.isFolder
                                ? folderList(item)
                                : filesList(item));
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Directionality folderList(Map<String, dynamic> item) {
    return Directionality(
      textDirection: TextDirection.rtl, // RTL direction for ListTile
      child: ListTile(
        leading: const Icon(Icons.folder),
        title: Text(item['folderName']),
        subtitle: Text(item['finalDate'].toString()),
        trailing: Text('بواسطة ${item['createdBy']}'),
      ),
    );
  }

  Directionality filesList(Map<String, dynamic> item) {
    bool isFile = false;
    switch (item['type']) {
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

    String getType = 'un';

    switch (item['type']) {
      case 'doc':
      case 'docx':
      case 'dot':
      case 'dotx':
        getType = 'doc';
        break;
      case 'xls':
      case 'xlsx':
      case 'xlsm':
      case 'xltx':
      case 'csv':
        getType = 'xlsx';
        break;
      case 'pdf':
        getType = 'pdf';
        break;
      case 'jpg':
      case 'jpeg':
        getType = 'jpg';
        break;
      case 'png':
        getType = 'png';
        break;
      default:
        getType = 'un';
    }

    return Directionality(
      textDirection: TextDirection.rtl, // RTL direction for ListTile
      child: ListTile(
        leading: isFile
            ? Image.asset(
                'images/$getType.png',
                width: 50.0,
                height: 50.0,
                fit: BoxFit.cover,
              )
            : Image.network(
                item['fileUrl'],
                width: 50.0,
                height: 50.0,
                fit: BoxFit.cover,
              ),
        title: Text(item['title']),
        subtitle: Text(item['finalDate'].toString()),
        trailing: Text('بواسطة ${item['createdBy']}'),
      ),
    );
  }
}
