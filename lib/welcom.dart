import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scan/home.dart';

class WelcomScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHome()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHome()),
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Image GIF centrée
            Center(
              child: Image.asset(
                'assets/images/assistiv.png',
                width: 350,
                height: 250,
              ),
            ),
            // Texte au bas de la page
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome To My EyeMate',
                      style: GoogleFonts.onest(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '⠺⠑⠇⠉⠕⠍⠑ ⠞⠕ ⠍⠽ ⠑⠽⠑⠍⠁⠞⠑',
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
