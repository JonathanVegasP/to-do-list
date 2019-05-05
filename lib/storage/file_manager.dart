import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileManager {
  String _file;

  FileManager(String file) {
    _file = file;
  }

  Future<File> _getFile() async {
    final path = await getApplicationDocumentsDirectory();
    return File("${path.path}/$_file.json");
  }

  Future<File> saveData(List data) async {
    final file = await _getFile();
    return file.writeAsString(json.encode(data));
  }

  Future<String> readData() async {
    final file = await _getFile();
    if (!await file.exists()) return Future<String>(() => "[]");
    return file.readAsString();
  }

  Future<FileSystemEntity> deleteFile() async {
    final file = await _getFile();
    return file.delete();
  }

  Future<FileSystemEntity> deleteAllFiles() async {
    final path = await getApplicationDocumentsDirectory();
    return path.delete(recursive: true);
  }
}
