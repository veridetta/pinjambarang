import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../homepage/home_page.dart';
import '../../user/user_page.dart';
import '../login.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Atau widget loading lainnya
          }
          if (snapshot.hasData) {
            final user = snapshot.data!; // Pastikan user tidak null
            print('User ${user.uid} sedang login');
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('user')
                  .where('uid', isEqualTo: user.uid)
                  .get(),
              builder: (context, userDataSnapshot) {
                if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Atau widget loading lainnya
                }
                if (userDataSnapshot.hasData && userDataSnapshot.data!.docs.isNotEmpty) {
                  var documentSnapshot = userDataSnapshot.data!.docs.first;
                  var data = documentSnapshot.data() as Map<String, dynamic>;
                  final userType = data['userType'];
                  if (userType == 'Admin') {
                    return HomeScreen();
                  } else {
                    return UserScreen();
                  }
                }
                print('Data user tidak ditemukan');
                return Text('Data user tidak ditemukan');
              },
            );

          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
