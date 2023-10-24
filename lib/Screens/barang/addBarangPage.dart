import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../homepage/components/home_page_body.dart';

class AddBarangPage extends StatefulWidget {
  const AddBarangPage({Key? key}) : super(key: key);

  @override
  State<AddBarangPage> createState() => _AddBarangPageState();
}

class _AddBarangPageState extends State<AddBarangPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nama = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _stok = TextEditingController();

  final _articleCollection = FirebaseFirestore.instance.collection('barang');

  Future<void> _saveData() async {
    try {
      if (_formKey.currentState!.validate()) {
        String nama = _nama.text;
        String deskripsi = _description.text;
        String stok = _stok.text;

        await _articleCollection.add({
          'uid': FirebaseAuth.instance.currentUser!.uid,
          'nama': nama,
          'deskripsi': deskripsi,
          'stok': stok,
          'date': Timestamp.now(),
        });

        Get.snackbar('Sukses', 'Data berhasil ditambahkan');
        Get.off(HomeScreenBody());
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat menambahkan data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        flexibleSpace: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            gradient: LinearGradient(
              colors: [Colors.green, Colors.greenAccent],
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.shopping_bag_rounded, size: 30),
            Text('Add Barang'),
            SizedBox(width: 180),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nama,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.shopping_bag, color: Colors.brown),
                        labelText: 'Masukkan Nama Barang',
                        errorStyle: TextStyle(color: Colors.grey),
                      ),
                      maxLength: 25,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'mohon masukkan nama';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                    ),
                    TextFormField(
                      controller: _stok,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.production_quantity_limits, color: Colors.brown),
                        labelText: 'Masukkan Stok Barang',
                        errorStyle: TextStyle(color: Colors.grey),
                      ),
                      maxLength: 5,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'mohon masukkan stok';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                    ),
                    TextFormField(
                      maxLength: 1000,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      controller: _description,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.description_outlined,
                            color: Colors.green),
                        labelText: 'Masukkan deskripsi barang tersebut',
                        errorStyle: TextStyle(color: Colors.grey),
                      ),
                      autofocus: false,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'mohon masukkan deskripsi';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                    ),
                    SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(45, 8, 15, 8),
                      child: ElevatedButton(
                        autofocus: true,
                        onPressed: () {
                          _saveData();
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        child: const Text('Save',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
