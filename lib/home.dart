import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ImportPage.dart'; // Make sure to import necessary files

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedFile;
  List<FileSystemEntity> savedFiles = [];

  @override
  void initState() {
    super.initState();
    fetchSavedFiles();
  }

  Future<void> fetchSavedFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync().where((file) => file.path.endsWith('.pdf'));
    setState(() {
      savedFiles = files.toList();
    });
  }

  Future<void> _refresh() async {
    await fetchSavedFiles();
  }

  Future<void> _openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedFile = File(photo.path);
        _navigateToImportPage();
      });
    }
  }

  Future<void> _openGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
        _navigateToImportPage();
      });
    }
  }

  Future<void> _openFilePicker() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _navigateToPDFViewerPage(_selectedFile!);
      });
    }
  }

  Future<void> _renameFile(File file, String newName) async {
    final directory = await getApplicationDocumentsDirectory();
    final newFilePath = '${directory.path}/$newName.pdf';
    await file.rename(newFilePath);
    fetchSavedFiles();
  }

  Future<void> _deleteFile(File file) async {
    await file.delete();
    fetchSavedFiles();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File deleted')));
  }

  Future<void> _showRenameDialog(File file) async {
    TextEditingController _controller = TextEditingController(text: file.path.split('/').last);

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Rename File'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter new file name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Rename'),
              onPressed: () async {
                String newName = _controller.text;
                if (newName.isNotEmpty) {
                  await _renameFile(file, newName);
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToImportPage() {
    if (_selectedFile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImportPage(file: _selectedFile!),
        ),
      );
    }
  }

  void _navigateToPDFViewerPage(File file) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(file: file),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: Text('Home', style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple.shade100,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/11201139.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildButton(Icons.image, 'Gallery', Colors.pink.shade100, _openGallery),
                  ),
                  SizedBox(width: 10), // Add spacing between the two buttons
                  Expanded(
                    child: _buildButton(Icons.camera_alt, 'Camera', Colors.blue.shade100, _openCamera),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: _buildButton(Icons.folder, 'My PDF', Colors.cyan.shade100, _openFilePicker),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Recent Files', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: savedFiles.length,
                itemBuilder: (context, index) {
                  final file = savedFiles[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                      title: Text(file.path.split('/').last, style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showRenameDialog(File(file.path)),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteFile(File(file.path)),
                          ),
                        ],
                      ),
                      onTap: () {
                        if (file.path.endsWith('.pdf')) {
                          _navigateToPDFViewerPage(File(file.path));
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String title, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class PDFViewerPage extends StatelessWidget {
  final File file;

  PDFViewerPage({required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: Column(
        children: [
          Expanded(
            child: PDFView(
              filePath: file.path,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ImportPage(file: file)),
                  );
                },
                child: Text('Extracted Text'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
