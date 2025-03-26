import 'dart:ui';

import 'package:book_world/screens/signup2.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<StatefulWidget> createState() => _Signup();
}

class _Signup extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            SizedBox.expand(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Image.asset('assets/images/bg-image.png'),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height*20/100,
              width: MediaQuery.of(context).size.width,
              child: Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [

                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 50, 15, 0),
                        margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),

                        height: 450,
                        width: 300,

                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: const Color(0xFFFDDCBB),
                            border: Border.all(color: Colors.orange, width: 3)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            const Text("Full Name",style: TextStyle(fontSize: 15,color:Colors.black,fontWeight:FontWeight.bold), ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [BoxShadow(color: Colors.grey,blurRadius: 10,spreadRadius: 0.5,offset: Offset(0, 4))]
                              ),
                              child: const TextField(decoration: InputDecoration(
                                  hintText: "Enter your name", // Placeholder text

                                  // Label text
                                  border: OutlineInputBorder(),

                                  filled: true,
                                  fillColor: Colors.white)),
                            ),
                            const SizedBox(height: 25,),
                            const Text("User Name",style: TextStyle(fontSize: 15,color:Colors.black,fontWeight:FontWeight.bold), ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [BoxShadow(color: Colors.grey,blurRadius: 5,spreadRadius: 0.5,offset: Offset(0, 4))]
                              ),
                              child: const TextField(decoration: InputDecoration(
                                  hintText: "Enter your Password", // Placeholder text

                                  // Label text
                                  border: OutlineInputBorder(),

                                  filled: true,
                                  fillColor: Colors.white)),
                            ),
                            const SizedBox(height: 5,),
                            const Text("Contains alphabets, numbers, hyphen and underscore",style: TextStyle(fontSize: 16,color:Colors.black), ),
                            const SizedBox(height: 15,),
                            const Text("Mobile Number",style: TextStyle(fontSize: 15,color:Colors.black,fontWeight:FontWeight.bold), ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [BoxShadow(color: Colors.grey,blurRadius: 10,spreadRadius: 0.5,offset: Offset(0, 4))]
                              ),
                              child: const TextField(decoration: InputDecoration(
                                  hintText: "Enter your mobile number", // Placeholder text

                                  // Label text
                                  border: OutlineInputBorder(),

                                  filled: true,
                                  fillColor: Colors.white)),
                            ),
                            const SizedBox(height: 25,),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  width: 110,
                                  child: const Text("Login",style: TextStyle(fontSize: 19,color: Colors.orange),),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                                height: 30,
                                width: 110,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.orange),
                                child: InkWell(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const Signup2()));
                                  },
                                  child: const Text(
                                    "Next",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
]
                            )

                          ],
                        ),
                      ), Positioned(
                        left: 45,
                        child:

                        Container(
                          height: 50,
                          width: 210,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.orange),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
