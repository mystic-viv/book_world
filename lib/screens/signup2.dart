import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:book_world/screens/signup3.dart';

class Signup2
 extends StatefulWidget {
  const Signup2({super.key});

  @override
  State<StatefulWidget> createState() => _Signup2
();
}

class _Signup2
 extends State<Signup2
> {
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
                        padding: const EdgeInsets.fromLTRB(20, 30, 15, 0),
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

                            const Text("Date Of Birth",style: TextStyle(fontSize: 15,color:Colors.black,fontWeight:FontWeight.bold), ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 10, 20),

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Day Input
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [BoxShadow(color: Colors.grey,blurRadius: 10,spreadRadius: 0.5,offset: Offset(0, 4))]
                                    ),
                                    width: 70,
                                    child: const TextField(
                                      keyboardType: TextInputType.number,
                                      maxLength: 2,
                                      decoration: InputDecoration(
                                        counterText: "",
                                        hintText: "DD",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Month Input
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [BoxShadow(color: Colors.grey,blurRadius: 10,spreadRadius: 0.5,offset: Offset(0, 4))]
                                    ),
                                    width: 70,
                                    child: const TextField(
                                      keyboardType: TextInputType.number,
                                      maxLength: 2,
                                      decoration: InputDecoration(
                                        counterText: "",
                                        hintText: "MM",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Year Input
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [BoxShadow(color: Colors.grey,blurRadius: 10,spreadRadius: 0.5,offset: Offset(0, 4))]
                                    ),
                                    width: 80,
                                    child: const TextField(
                                      keyboardType: TextInputType.number,
                                      maxLength: 4,
                                      decoration: InputDecoration(
                                        counterText: "",
                                        hintText: "YYYY",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),

                            const Text("Local Address",style: TextStyle(fontSize: 15,color:Colors.black,fontWeight:FontWeight.bold), ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [BoxShadow(color: Colors.grey,blurRadius: 10,spreadRadius: 0.5,offset: Offset(0, 4))]
                              ),
                              child: const TextField(
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                  decoration: InputDecoration(
                                    border: InputBorder.none
                                  ),
                              ),
                            ),
                            const SizedBox(height: 20,),
                            const Text("Permanent Address",style: TextStyle(fontSize: 15,color:Colors.black,fontWeight:FontWeight.bold), ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [BoxShadow(color: Colors.grey,blurRadius: 10,spreadRadius: 0.5,offset: Offset(0, 4))]
                              ),
                              child: const TextField(
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                decoration: InputDecoration(
                                    border: InputBorder.none
                                ),
                              ),
                            ), const SizedBox(height: 30,),
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
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const Signup3()));
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
                      ), 

                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
