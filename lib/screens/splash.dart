// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:flutter/material.dart';

import 'login.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<StatefulWidget> createState() => _Splash();
}

class _Splash extends State<Splash> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 4), () {
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg-image.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 125),
            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(35),
            ),
            height: 235,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x99FBBA77),

                borderRadius: BorderRadius.circular(35),
              ),
              height: 235,
              padding: const EdgeInsets.fromLTRB(25, 45, 25, 0),

              child: Column(
                children: [
                  Image.asset("assets/images/purelogo-removebg 1.png"),
                  const Text(
                    "BOOK WORLD",
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Sanchez',
                      color: Color(0xFFE97F11),
                    ),
                  ),
                  const Text(
                    "ONE PLACE FOR ALL TO STUDY",
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'serif',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
