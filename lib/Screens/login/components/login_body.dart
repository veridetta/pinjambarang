import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../components/my_button.dart';
import '../../../components/my_textfield.dart';
import '../../homepage/home_page.dart';
import '../../signup/sign_up.dart';
import '../../user/user_page.dart';

class LoginBodyScreen extends StatefulWidget {
  const LoginBodyScreen({super.key});

  @override
  State<LoginBodyScreen> createState() => _LoginBodyScreenState();
}

class _LoginBodyScreenState extends State<LoginBodyScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false; // Menambahkan indikator loading

  void signUserIn() async {
    try {
      setState(() {
        isLoading = true; // Menampilkan indikator loading saat proses login
      });

      // Masuk menggunakan email dan password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      setState(() {
        isLoading = false; // Menghilangkan indikator loading setelah berhasil login
      });
      //ambil data dari user
      final user = FirebaseAuth.instance.currentUser!;
      // Ambil data dari Firestore
      final userData = await FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: user.uid)
          .get();
      if (userData.docs.isNotEmpty) {
        var documentSnapshot = userData.docs.first;
        var data = documentSnapshot.data() as Map<String, dynamic>;
        var userType = data['userType'];

        if (userType == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false; // Menghilangkan indikator loading saat terjadi kesalahan
      });
      showErrorMessage(e.code);
    }
  }

  void showErrorMessage(String message) {
    // Tampilkan dialog dengan pesan error
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
        );
      },
    );
  }

  String _errorMessage = "";

  void validateEmail(String val) {
    if (val.isEmpty) {
      // Validasi jika email kosong
      setState(() {
        _errorMessage = "Email tidak boleh kosong";
      });
    } else if (!EmailValidator.validate(val, true)) {
      // Validasi jika email tidak valid
      setState(() {
        _errorMessage = "Alamat Email tidak valid";
      });
    } else {
      setState(() {
        _errorMessage = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.green,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(0, 200, 0, 0),
          shrinkWrap: true,
          reverse: true,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 650,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: HexColor("#ffffff"),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/images/logo.png',
                                scale: 1.5,
                              ),
                            ),
                            Center(
                              child: Text(
                                "Log In",
                                style: GoogleFonts.poppins(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: HexColor("#4f4f4f"),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 0, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Email",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: HexColor("#8d8d8d"),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  MyTextField(
                                    onChanged: (() {
                                      validateEmail(emailController.text);
                                    }),
                                    controller: emailController,
                                    hintText: "masukkan email anda",
                                    obscureText: false,
                                    prefixIcon: const Icon(Icons.mail_outline),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                    child: Text(
                                      _errorMessage,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Password",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: HexColor("#8d8d8d"),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  MyTextField(
                                    controller: passwordController,
                                    hintText: "**************",
                                    obscureText: true,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  isLoading
                                      ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                      : MyButton(
                                    onPressed: signUserIn,
                                    buttonText: 'Submit',
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.fromLTRB(35, 0, 0, 0),
                                    child: Row(
                                      children: [
                                        Text("Belum punya akun?",
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: HexColor("#8d8d8d"),
                                            )),
                                        TextButton(
                                          child: Text(
                                            "Daftar",
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: HexColor("#44564a"),
                                            ),
                                          ),
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                              const SignUpScreen(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
