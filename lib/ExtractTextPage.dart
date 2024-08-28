import 'dart:io';
import 'dart:convert';  // Ensure this import is included for JSON handling
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'home.dart';
import 'Translator.dart';
import 'package:http/http.dart' as http;

class ExtractTextPage extends StatefulWidget {
  final File file;
  final String extractedText;
  final String languageCode;

  ExtractTextPage({
    required this.file,
    required this.extractedText,
    required this.languageCode,
  });

  @override
  State<ExtractTextPage> createState() => _ExtractTextPageState();
}

class _ExtractTextPageState extends State<ExtractTextPage> {
  TextEditingController textEditingController = TextEditingController();
  TextEditingController fileNameController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = "";
  String _brailleText = "";

  @override
  void initState() {
    super.initState();
    textEditingController.text = widget.extractedText;
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
    final fileName = fileNameController.text.isNotEmpty
        ? fileNameController.text
        : 'extracted_text_${DateTime.now().millisecondsSinceEpoch}';
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved as PDF: ${file.path}')),
    );
    Navigator.pop(context, file.path);
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
              child: Text('Cancel', style: TextStyle(color: Colors.purple.shade100)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save', style: TextStyle(color: Colors.purple.shade100)),
              onPressed: () {
                Navigator.of(context).pop();
                saveAsPDF();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _transcribeToBraille() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.15:5000/transcribe_braille'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded', // Set content type to form-data
        },
        body: {
          'text': textEditingController.text, // Use the text from the TextEditingController
          'language': widget.languageCode, // Use the language code from the widget
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _brailleText = response.body;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to transcribe text to braille');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extracted Text'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                  children: [
                    TextField(
                      controller: textEditingController,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Extracted text will appear here',
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_brailleText.isNotEmpty) ...[
                      Text('Braille Transcription:'),
                      SizedBox(height: 8),
                      Text(_brailleText),
                    ],
                    if (_errorMessage.isNotEmpty) ...[
                      Text('Error: $_errorMessage', style: TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _transcribeToBraille,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.purple.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                    ),
                    child: Text('Transcribe to Braille', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _showSaveDialog,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.purple.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                    ),
                    child: Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
