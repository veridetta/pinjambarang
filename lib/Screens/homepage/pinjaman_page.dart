import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'components/pinjaman_page_body.dart';

class PinjamanScreen extends StatefulWidget {
  const PinjamanScreen({super.key});

  @override
  State<PinjamanScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<PinjamanScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: Center(child: PinjamanScreenBody()),
      ),
    );
  }
}
