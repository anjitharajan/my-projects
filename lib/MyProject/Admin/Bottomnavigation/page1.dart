import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class page1 extends StatefulWidget {
  page1({super.key});

  @override
  State<page1> createState() => _page1State();
}

class _page1State extends State<page1> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _image = TextEditingController();
  final TextEditingController _about = TextEditingController();

  final dbRef = FirebaseDatabase.instance.ref().child("hospitals");

  Future<void> addHospital() async {
    if (_formKey.currentState!.validate()) {
      final newHospital = dbRef.push();
      await newHospital.set({
        "id": newHospital.key,
        "name": _name.text,
        "image": _image.text,
        "about": _about.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${_name.text} added successfully")),
      );

      _name.clear();
      _image.clear();
      _about.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Hospital",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 4, 46, 81),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: "Hospital Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter hospital name" : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _image,
                decoration: InputDecoration(
                  labelText: "Hospital Image URL",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter image URL" : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _about,
                decoration: InputDecoration(
                  labelText: "About Hospital",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: addHospital,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 4, 46, 81),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  "Add Hospital",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
