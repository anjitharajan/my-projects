// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';

// class page1 extends StatefulWidget {
//   page1({super.key});

//   @override
//   State<page1> createState() => _page1State();
// }

// class _page1State extends State<page1> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _name = TextEditingController();
//   final TextEditingController _image = TextEditingController();
//   final TextEditingController _about = TextEditingController();

//   final dbRef = FirebaseDatabase.instance.ref().child("hospitals");

//   Future<void> addHospital() async {
//     if (_formKey.currentState!.validate()) {
//       final newHospital = dbRef.push();
//       await newHospital.set({
//         "id": newHospital.key,
//         "name": _name.text,
//         "image": _image.text,
//         "about": _about.text,
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("${_name.text} added successfully")),
//       );

//       _name.clear();
//       _image.clear();
//       _about.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Add Hospital",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Color.fromARGB(255, 4, 46, 81),
//                 ),
//               ),
//               SizedBox(height: 20),
//               TextFormField(
//                 controller: _name,
//                 decoration: InputDecoration(
//                   labelText: "Hospital Name",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? "Enter hospital name" : null,
//               ),
//               SizedBox(height: 10),
//               TextFormField(
//                 controller: _image,
//                 decoration: InputDecoration(
//                   labelText: "Hospital Image URL",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) => value!.isEmpty ? "Enter image URL" : null,
//               ),
//               SizedBox(height: 10),
//               TextFormField(
//                 controller: _about,
//                 decoration: InputDecoration(
//                   labelText: "About Hospital",
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: addHospital,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color.fromARGB(255, 4, 46, 81),
//                   padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 ),
//                 child: Text(
//                   "Add Hospital",
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
    















    import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class page1 extends StatefulWidget {
  page1({super.key});

  @override
  State<page1> createState() => _Page1State();
}

class _Page1State extends State<page1> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController hospitalName = TextEditingController();
  final TextEditingController hospitalAddress = TextEditingController();
  final TextEditingController hospitalCode = TextEditingController();
  final TextEditingController hospitalContact = TextEditingController();

  final dbRef = FirebaseDatabase.instance.ref().child("hospitals");

 Future<void> addHospital() async {
  if (_formKey.currentState!.validate()) {
   final newHospital = dbRef.push();


    // 🔹 Auto-generated hospital code
    final autoCode = "HOSP${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";

    await newHospital.set({
      "id": newHospital.key,
      "name": hospitalName.text.trim(),
      "address": hospitalAddress.text.trim(),
      "contact": hospitalContact.text.trim(),
      "code": autoCode, // auto-generated code
      "email": "", // will be filled during hospital signup
      "password": "",
      "linked": false, // will be true when hospital signs up
      "createdAt": DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Hospital added successfully!\nCode: $autoCode")),
    );

    // Clear form fields
    hospitalName.clear();
    hospitalAddress.clear();
    hospitalContact.clear();
  }
}

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding:  EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                "Add New Hospital",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 5, 101, 180),
                ),
              ),
               SizedBox(height: 24),

            
              Container(
                padding:  EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient:  LinearGradient(
                    colors: [Colors.blue, Color.fromARGB(255, 4, 46, 81)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow:  [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                 
                    Row(
                      children: [
                        Expanded(
                          child: buildTextFormField(
                            "Hospital Name",
                            hospitalName,
                            "Enter hospital name",
                          ),
                        ),
                         SizedBox(width: 20),
                        Expanded(
                          child: buildTextFormField(
                            "Hospital Address",
                            hospitalAddress,
                            "Enter hospital address",
                          ),
                        ),
                      ],
                    ),
                     SizedBox(height: 16),

                    // Row 2
                    Row(
                      children: [
                     
                        Expanded(
                          child: buildTextFormField(
                            "Hospital Contact",
                            hospitalContact,
                            "Enter hospital contact",
                          ),
                        ),
                      ],
                    ),

                     SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: addHospital,
                        icon:  Icon(Icons.save,size: 24,),
                        label:  Text(
                          "Save",
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor:
                               Color.fromARGB(255, 4, 46, 81),
                          padding:  EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildTextFormField(
      String label, TextEditingController controller, String? validationText) {
    return Padding(
      padding:  EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        validator: (val) =>
            val == null || val.isEmpty ? validationText : null,
        style:  TextStyle(color: Colors.white, fontSize: 24),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
               TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:  BorderSide(color: Colors.white38),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:  BorderSide(color: Colors.white, width: 2),
          ),
          contentPadding:
               EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
