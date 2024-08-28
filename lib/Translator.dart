
import 'dart:io';
import 'home.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'ExtractTextPage.dart';
class TranslatorScreen extends StatefulWidget {
  @override
  _TranslatorScreenState createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _textController = TextEditingController();
  TextEditingController fileNameController = TextEditingController();
  TextEditingController textEditingController = TextEditingController();

  void _printText() {
    print(_textController.text);
  }

  Future<void> _saveText() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/translated_text.txt');
    await file.writeAsString(_textController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text saved to ${file.path}')),
    );
  }
  Future<void> saveAsPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(textEditingController.text),
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final fileName = fileNameController.text.isNotEmpty ? fileNameController.text : 'extracted_text_${DateTime.now().millisecondsSinceEpoch}';
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved as PDF: ${file.path}')),
    );
    Navigator.pop(context, file.path); // Navigate back and indicate that a file was saved
  }

  Future<void> _showSaveDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save as PDF'),
          content: TextField(
            controller: fileNameController,
            decoration: InputDecoration(hintText: "Enter file name"),
          ),
          actions: [
            TextButton(
              child: Text('Cancel',
                style: TextStyle(color: Colors.lightGreen[700]),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save',
                style: TextStyle(color: Colors.lightGreen[700]),),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => MyHome()));
                saveAsPDF();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translator'),
      ),
      body: SingleChildScrollView(
    child: Container(
    padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              maxLines: 10,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter text to translate',
              ),
            ),
            SizedBox(height: 16),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    ElevatedButton(
    onPressed: () {
    Navigator.push(context, MaterialPageRoute(builder: (context)=> TranslatorScreen()),
    );

    },
    style: TextButton.styleFrom(
      backgroundColor: Colors.lightGreen[700],
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28),
    ),
    child: Text('Print', style: TextStyle(color: Colors.white)),
    ),
    ElevatedButton(
    onPressed: _showSaveDialog,
    style: TextButton.styleFrom(
      backgroundColor: Colors.lightGreen[700],
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
    ),
    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28),
    ),
    child: Text('Save', style: TextStyle(color: Colors.white)),
    ),]),
          ],
        ),
      ),)

    );
  }
}
