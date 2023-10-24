import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinjambarang/Screens/user/user_page.dart';

import '../Screens/homepage/home_page.dart';
import '../models/file_model.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();
  FileModel? _imageFile;
  FileModel? get imageFile => _imageFile;
  void setImageFile(FileModel? file) {
    _imageFile = file;
    debugPrint("Updated ImageFile: ${imageFile!.filename}");
    update();
  }

  String? _userType = "Peminjam";
  String? get userType => _userType;
  void setUserType(String? text) {
    _userType = text;
    debugPrint("Updated userType: $userType");
    update();
  }

  String? _name;
  String? get name => _name;
  void setName(String? text) {
    _name = text;
    debugPrint("Updated name: $name");
    update();
  }

  String? _email;
  String? get email => _email;
  void setEmail(String? text) {
    _email = text;
    debugPrint("Updated email: $email");
    update();
  }

  String? _password;
  String? get password => _password;
  void setPassword(String? text) {
    _password = text;
    debugPrint("Updated password: $password");
    update();
  }

  String? _mobileNumber;
  String? get mobileNumber => _mobileNumber;
  void setMobileNumber(String? text) {
    _mobileNumber = text;
    debugPrint("Updated mobileNumber: $mobileNumber");
    update();
  }

  String? _divisiName;
  String? get divisiName => _divisiName;
  void setDivisiName(String? text) {
    _divisiName = text;
    debugPrint("Updated divisiName: $divisiName");
    update();
  }

  Future postSignUpDetails() async {
    try {
      String newDocId = FirebaseAuth.instance.currentUser?.uid ?? '';

      DocumentReference newDocRef =
      FirebaseFirestore.instance.collection('user').doc(newDocId);

      String imageUrl = await uploadImageFile();

      await newDocRef.set({
        'docId': newDocId,
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'userType': userType,
        'name': name,
        'email': email,
        'password': password,
        'mobileNumber': mobileNumber,
        'divisiName': divisiName,
        'imageUrl': imageUrl,
      });

      // Menampilkan snackbar sukses
      Get.showSnackbar(GetBar(
        message: "Data berhasil disimpan",
        duration: const Duration(seconds: 3),
      ));

      // Navigasi ke halaman HomeScreen setelah menutup snackbar
      Future.delayed(const Duration(seconds: 3), () {
        //cekk userType
        if(userType== "Peminjam"){
          Get.offAll(const UserScreen());
        }else{
          Get.offAll(const HomeScreen());
        }
      });
    } catch (error) {
      if (error is FirebaseAuthException) {
        Get.showSnackbar(
          GetBar(
            message: error.toString(),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }


  Future<String> uploadImageFile() async {
    var uploadTask = await FirebaseStorage.instance
        .ref('files/${imageFile!.filename}')
        .putData(imageFile!.fileBytes);

    var downloadURL = await uploadTask.ref.getDownloadURL();
    return downloadURL.toString(); // Return the download URL
  }

  Future<bool> registerUser(String email, String password) async {
    try {
      var response = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // SnackBar dengan pesan sukses
      Get.showSnackbar(
        const GetBar(
          message: "Registration successful",
          duration: Duration(seconds: 3), // SnackBar akan hilang setelah 3 detik
        ),
      );

      return true;
    } catch (error) {
      if (error is FirebaseAuthException) {
        // SnackBar dengan pesan error
        Get.showSnackbar(
          GetBar(
            message: error.toString(),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    return false;
  }

}
