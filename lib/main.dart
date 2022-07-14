import 'package:appwrite/appwrite.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appwrite_simple_app/data.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appwrite Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final Client _client;
  late final Account _account;
  late final Databases _database;
  late final Storage _storage;

  late final Future<void> _future;

  @override
  void initState() {
    super.initState();

    _client = Client()
      ..setEndpoint(appWriteUrl)
      ..setProject(projectId);
    _account = Account(_client);
    _database = Databases(_client, databaseId: 'main');
    _storage = Storage(_client);

    _future = _initSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appwrite Demo'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) => ListView(
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 30.0,
                right: 16.0,
              ),
              child: Center(
                child: ElevatedButton(
                  onPressed: _createDatabaseRecord,
                  child: const Text('Create database record'),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 30.0,
                right: 16.0,
              ),
              child: Center(
                child: ElevatedButton(
                  onPressed: _uploadFile,
                  child: const Text('Upload file'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initSession() async {
    try {
      await _account.get();
    } catch (_) {
      await _account.createAnonymousSession();
    }
  }

  Future<void> _createDatabaseRecord() async {
    final messenger = ScaffoldMessenger.of(context);

    late final String message;
    try {
      await _database.createDocument(
        collectionId: 'test',
        documentId: 'unique()',
        data: {'message': 'A message generated from the App'},
      );
      message = 'Record created';
    } catch (e) {
      debugPrint('Error while creating a record: $e');
      message = 'Could not create record';
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _uploadFile() async {
    final messenger = ScaffoldMessenger.of(context);

    late final String message;
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null) {
        await _storage.createFile(
          bucketId: 'main',
          fileId: 'unique()',
          file: InputFile(
            path: result.files.single.path!,
            filename: result.files.single.name,
          ),
        );
      }
      message = 'File uploaded';
    } catch (e) {
      debugPrint('Error while uploading a file: $e');
      message = 'Could not upload file';
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
