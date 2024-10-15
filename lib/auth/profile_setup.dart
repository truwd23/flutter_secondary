import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myapp/pages/homepage.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController participantNoController = TextEditingController();
  File? fileImage;
  String? ImageUrl;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    String uid = FirebaseAuth.instance.currentUser!.uid;

    File? pickedFile =
        (await picker.pickImage(source: ImageSource.gallery)) as File?;

    if (pickedFile != null) {
      // Upload gambar profil ke Firebase Storage
      final storageRef =
          FirebaseStorage.instance.ref().child('profileImages/$uid.jpg');

      UploadTask uploadTask = storageRef.putFile(File(fileImage!.path));
      TaskSnapshot snapshot = await uploadTask;
      String ImageUrl = await snapshot.ref.getDownloadURL();
      setsState() {
        ImageUrl = ImageUrl;
        fileImage = pickedFile.path as File?;
      }
    }
  }

  Future<void> uploadProfile() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Update data user di Firestore dengan informasi tambahan
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': nameController.text,
      'phone': phoneController.text,
      'participantNo': participantNoController.text,
      'imageUrl': ImageUrl,
    });

    // Setelah berhasil disimpan, arahkan user ke halaman utama
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            TextField(
              controller: participantNoController,
              decoration:
                  const InputDecoration(labelText: "Participant Number"),
            ),
            if (fileImage != null)
              if (kIsWeb)
                Image.network(fileImage!.path, height: 100, width: 100)
              else
                Image.file(File(fileImage!.path), height: 100, width: 100)
            else
              const Text("No image selected"),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Profile Image"),
            ),
            ElevatedButton(
              onPressed: uploadProfile,
              child: const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }
}