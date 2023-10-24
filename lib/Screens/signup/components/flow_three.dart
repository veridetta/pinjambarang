import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../../components/my_button.dart';
import '../../../controller/flow_controller.dart';
import '../../../controller/sign_up_controller.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/file_model.dart';

import '../../homepage/home_page.dart';

class SignUpThree extends StatefulWidget {
  const SignUpThree({super.key});

  @override
  State<SignUpThree> createState() => _SignUpThreeState();
}

class _SignUpThreeState extends State<SignUpThree> {
  var user = FirebaseAuth.instance.currentUser!.uid;
  SignUpController signUpController =
      Get.put(SignUpController(), permanent: false);
  Future signUserUp() async {
    // create user

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: signUpController.email.toString(),
        password: signUpController.password.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    print(FirebaseAuth.instance.currentUser!.uid);
  }

  String basename(String path) => basename(path);

  Future uploadImageFile() async {
    FilePickerResult? image = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (image != null) {
      Uint8List? fileBytes = image.files.first.bytes;
      String fileName = image.files.first.name;
      signUpController
          .setImageFile(FileModel(filename: fileName, fileBytes: fileBytes!));
    }
  }

  FlowController flowController = Get.put(FlowController());

  @override
  Widget build(BuildContext context) {
    SignUpController signUpController =
        Get.put(SignUpController(), permanent: false);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    flowController.setFlow(2);
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 67,
                ),
                Text(
                  "Sign Up",
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: HexColor("#4f4f4f"),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Profile Picture",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: HexColor("#8d8d8d"),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      textStyle: MaterialStateProperty.all<TextStyle?>(
                        GoogleFonts.poppins(
                          fontSize: 15,
                          color: HexColor("#4f4f4f"),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.fromLTRB(90, 15, 90, 15)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(HexColor("#fed8c3")),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      )),
                    ),
                    onPressed: () async {
                      uploadImageFile();
                      setState(() {
                        int i = 1 + 1;
                      });
                    },
                    child: const Text("Upload an image"),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  GetBuilder<SignUpController>(builder: (context) {
                    if (signUpController.imageFile != null) {
                      // Tampilkan gambar yang sudah dipilih
                      return Column(
                        children: [
                          const SizedBox(height: 5),
                          Center(
                            child: Image.memory(
                              signUpController.imageFile!.fileBytes,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Center(
                            child: Text(
                              signUpController.imageFile!.filename,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: HexColor("#8d8d8d"),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Tampilkan pesan jika tidak ada gambar yang dipilih
                      return Text(
                        "No file selected",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: HexColor("#8d8d8d"),
                        ),
                      );
                    }
                  }),
                  const SizedBox(
                    height: 5,
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyButton(
                    onPressed: () {
                      signUpController.postSignUpDetails();
                    },
                    buttonText: 'Submit',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
