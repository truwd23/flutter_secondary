import 'package:cloud_firestore/cloud_firestore.dart';
import '/pages/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../onboarding_gate.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // User Loged in
          if (snapshot.hasData) {
            // Mengambil role user dari Firestore
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, snapshot) {
                // Mengecek apakah data role user sudah tersedia atau belum
                if (snapshot.hasData) {
                  // Jika sudah tersedia, maka menampilkan halaman yang sesuai dengan role user
                  String role = snapshot.data!.get('role');
                  if (role == 'Admin') {
                    return const HomePage();
                  } else if (role == 'User') {
                    return const HomePage();
                  } else {
                    return const Text('Role user tidak valid');
                  }
                } else if (snapshot.hasError) {
                  // Jika terjadi error, maka menampilkan pesan error
                  return Text(snapshot.error.toString());
                } else {
                  // Jika data role user belum tersedia, maka menampilkan indikator loading
                  return const CircularProgressIndicator();
                }
              },
            );
          }

          //User Logout
          else {
            return const OnboardingGate();
          }
        },
      ),
    );
  }
}
