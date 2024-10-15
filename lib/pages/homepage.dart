import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/onboarding_gate.dart';
import 'package:myapp/pages/tambahdata.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<Map<String, dynamic>> getUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddItem(),
                  ),
                );
              },
              icon: const Icon(Icons.menu))
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: const CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading profile"));
          }

          final userData = snapshot.data!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              userData['imageUrl'] != null
                  ? Image.network(userData['imageUrl'], height: 100, width: 100)
                  : const Icon(Icons.account_circle, size: 100),
              Text("Name: ${userData['name']}"),
              Text("Phone: ${userData['phone']}"),
              Text("Participant No: ${userData['participantNo']}"),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await _logout();
                  // Navigasi ke halaman login setelah logout
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const OnboardingGate(),
                    ),
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }
}
