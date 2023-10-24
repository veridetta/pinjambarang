import 'dart:io';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../homepage/components/home_page_body.dart';
import 'components/user_page_body.dart';

class AddPinjamPage extends StatefulWidget {
  const AddPinjamPage({Key? key}) : super(key: key);
  @override
  State<AddPinjamPage> createState() => _AddPinjamPageState();
}

class _AddPinjamPageState extends State<AddPinjamPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  List<String> barangList = [];
  List<String> idBarangList = [];
  List<String> stokBarangList = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController _namaBarang = TextEditingController();
  final TextEditingController _idBarang = TextEditingController();
  final TextEditingController _keterangan = TextEditingController();
  final TextEditingController _qty = TextEditingController();
  final TextEditingController _namaPeminjam = TextEditingController();
  final TextEditingController _divisi = TextEditingController();
  final TextEditingController _tglPinjam = TextEditingController();
  final TextEditingController _tglKembali = TextEditingController();

  final _articleCollection = FirebaseFirestore.instance.collection('pinjam');
  void fetchDataFromFirestore() {
    FirebaseFirestore.instance.collection('barang').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
        // Ambil nama barang dan tambahkan ke daftar barang
        barangList.add(documentSnapshot['nama']);
        idBarangList.add(documentSnapshot.id);
        stokBarangList.add(documentSnapshot['stok']);
      });
    });
  }
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime pickedDate = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      controller.text = formattedDate;
    }
  }
  Future<void> fetchData() async {
    try {
      // Ambil data dari Firestore berdasarkan uid
      QuerySnapshot querySnapshot = await firestore
          .collection('user')
          .where('uid', isEqualTo: auth.currentUser!.uid)
          .get();

      // Periksa apakah ada dokumen yang cocok
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;

        // Dapatkan data yang diperlukan
        String namaPeminjam = userDoc['name'];
        String divisi = userDoc['divisiName'];

        // Setel data yang diambil ke dalam controller untuk TextFormField
        setState(() {
          _namaPeminjam.text = namaPeminjam;
          _divisi.text = divisi;
        });
      } else {
        // Handle jika dokumen tidak ditemukan
        Get.snackbar('Error', 'Data pengguna tidak ditemukan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat mengambil data dari Firestore');
      print('Terjadi kesalahan: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
    fetchData(); // Panggil metode fetchData untuk mengisi TextFormField
  }
  Future<void> _saveData() async {
    try {
      if (_formKey.currentState!.validate()) {
        String namaBarang = _namaBarang.text;
        String idBarang = _idBarang.text;
        String keterangan = _keterangan.text;
        String tglPinjam = _tglPinjam.text;
        String tglKembali = _tglKembali.text;
        String namaPeminjam = _namaPeminjam.text;
        String divisi = _divisi.text;
        String qty = _qty.text;

        // Ambil stok barang dari Firestore
        DocumentSnapshot barangDoc = await firestore
            .collection('barang')
            .doc(idBarang)
            .get();
        int stok = int.parse(barangDoc['stok'].toString());

        // Validasi stok cukup untuk dipinjam
        int qtyInt = int.parse(qty);
        if (qtyInt > stok) {
          Get.snackbar('Error', 'Stok barang tidak mencukupi');
          return;
        }

        // Kurangi stok barang dengan qty yang dipinjam
        int sisaStok = stok - qtyInt;

        // Update stok barang di Firestore
        await firestore.collection('barang').doc(idBarang)
            .update({'stok': sisaStok});

        // Tambahkan data peminjaman
        await _articleCollection.add({
          'uid': FirebaseAuth.instance.currentUser!.uid,
          'idBarang': idBarang,
          'namaBarang': namaBarang,
          'keterangan': keterangan,
          'qty': qty,
          'namaPeminjam': namaPeminjam,
          'divisi': divisi,
          'tglPinjam': tglPinjam,
          'tglKembali': tglKembali,
          'date': Timestamp.now(),
        });

        Get.snackbar('Sukses', 'Data berhasil ditambahkan');
        Get.off(UserScreenBody());
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat menambahkan data');
      print('Terjadi kesalahan: $e');
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
            Icon(Icons.shopping_bag_rounded, size: 25),
            Text('Buat Pinjaman'),
            SizedBox(width: 167),
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
                    AutoCompleteTextField<String>(
                      key: key,
                      controller: _namaBarang,
                      clearOnSubmit: false,
                      suggestions: barangList,
                      itemFilter: (item, query) {
                        return item.toLowerCase().contains(query.toLowerCase());
                      },
                      itemSorter: (a, b) {
                        return a.compareTo(b);
                      },
                      itemSubmitted: (item) {
                        setState(() {
                          _namaBarang.text = item;
                          _idBarang.text = idBarangList[barangList.indexOf(item)];
                        });
                      },
                      itemBuilder: (context, item) {
                        return ListTile(
                          title: Text(item),
                        );
                      },
                      decoration: InputDecoration(
                        icon: Icon(Icons.shopping_bag, color: Colors.brown),
                        labelText: 'Cari Barang',
                        errorStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Visibility(
                      visible: false,
                        child:
                        TextFormField(
                          controller: _idBarang,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.shopping_bag, color: Colors.brown),
                            labelText: 'Pilih Barang',
                            errorStyle: TextStyle(color: Colors.grey),
                          ),
                          maxLength: 50,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'mohon pilih barang';
                            }
                            return null;
                          },
                          onSaved: (value) {},
                        )
                    ),
                    TextFormField(
                      controller: _qty,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.production_quantity_limits, color: Colors.brown),
                        labelText: 'Masukkan Kuantitas Pinjaman',
                        errorStyle: TextStyle(color: Colors.grey),
                      ),
                      maxLength: 5,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'mohon masukkan kuantitas';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                    ),
                    TextFormField(
                      controller: _namaPeminjam,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.perm_identity, color: Colors.brown),
                        labelText: 'Nama Peminjam',
                        errorStyle: TextStyle(color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'mohon isi nama';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                    ),
                    TextFormField(
                      controller: _divisi,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.work, color: Colors.brown),
                        labelText: 'Divisi',
                        errorStyle: TextStyle(color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'mohon isi divisi';
                        }
                        return null;
                      },
                      onSaved: (value) {},
                    ),
                    InkWell(
                      onTap: () {
                        _selectDate(context, _tglPinjam);
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _tglPinjam,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.calendar_today, color: Colors.blue),
                            labelText: 'Tanggal Pinjam',
                            errorStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        _selectDate(context, _tglKembali);
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _tglKembali,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.calendar_today, color: Colors.blue),
                            labelText: 'Tanggal Kembali',
                            errorStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      maxLength: 1000,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      controller: _keterangan,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.description_outlined,
                            color: Colors.green),
                        labelText: 'Masukkan keterangan',
                        errorStyle: TextStyle(color: Colors.grey),
                      ),
                      autofocus: false,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'mohon masukkan keterangan';
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
