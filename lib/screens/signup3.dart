import 'dart:ui';

import 'package:flutter/material.dart';

class Signup3 extends StatefulWidget{
  const Signup3({super.key});

  @override
  State<StatefulWidget> createState()=> _Signup3();


}
class _Signup3 extends State<Signup3>{
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
         child:Column(
           crossAxisAlignment: CrossAxisAlignment.start,
     
           children: [
     
      const Text("Email",style: TextStyle(fontSize: 15,color:Colors.black,fontWeight:FontWeight.bold), ),const SizedBox(height: 10,),
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.grey,blurRadius: 10,spreadRadius: 0.5,offset: Offset(0, 4))]
        ),
        child: const TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
            hintText: "Enter your email",
            // Placeholder text
     
            // Label text
            border: OutlineInputBorder(),
     
            filled: true,
            fillColor: Colors.white)),
      ),
      const SizedBox(height: 25,),
      const Text("Password",style: TextStyle(fontSize: 15,color:Colors.black,fontWeight:FontWeight.bold), ),const SizedBox(height: 10,),
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
      const Row(
        children: [
          Icon(Icons.square_rounded,color: Colors.white,),
          Text("Show Password",style: TextStyle(fontSize: 16,color:Colors.black), ),
        ],
      )
          ,
      const SizedBox(height: 20,),
      const Text("Confirm Password",style: TextStyle(fontSize: 15,color:Colors.black,fontWeight:FontWeight.bold), ),
      const SizedBox(height: 10,),
      Container(
     
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.grey,blurRadius: 10,spreadRadius: 0.5,offset: Offset(0, 4))]
        ),
        child: const TextField(decoration: InputDecoration(
            hintText: "Enter your Password", // Placeholder text
     
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
              child: const Text(
                "Verify",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
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