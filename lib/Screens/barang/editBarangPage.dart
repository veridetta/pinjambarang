import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../homepage/components/home_page_body.dart';
import '../homepage/home_page.dart';

class EditBarangPage extends StatefulWidget {
  final String documentId;

  EditBarangPage({required this.documentId});

  @override
  _EditBarangPageState createState() => _EditBarangPageState();
}

class _EditBarangPageState extends State<EditBarangPage> {
  late TextEditingController _namaController;
  late TextEditingController _descriptionController;
  late TextEditingController _stokController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _descriptionController = TextEditingController();
    _stokController = TextEditingController();
    _fetchData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _descriptionController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  void _fetchData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('barang')
        .doc(widget.documentId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _namaController.text = data['nama'];
        _descriptionController.text = data['deskripsi'];
        _stokController.text = data['stok'];
      });
    }
  }

  void _uploadData() async {
    String nama = _namaController.text;
    String description = _descriptionController.text;
    String stok = _stokController.text;

    if (nama.isNotEmpty && description.isNotEmpty && stok.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('barang')
          .doc(widget.documentId)
          .update({
        'nama': nama,
        'deskripsi': description,
        'stok': stok,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreenBody()),
      );
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
                bottomRight: Radius.circular(12)),
            gradient:
                LinearGradient(colors: [Colors.green, Colors.greenAccent]),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.edit_outlined, size: 20),
            Text('Edit Barang'),
            SizedBox(
              width: 180,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.shopping_bag,
                    color: Colors.brown,
                  ),
                  labelText: 'Masukkan Nama Barang',
                  errorStyle: TextStyle(color: Colors.grey),
                ),
                maxLength: 25,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),
              TextFormField(
                controller: _stokController,
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.production_quantity_limits,
                    color: Colors.brown,
                  ),
                  labelText: 'Masukkan Stok',
                  errorStyle: TextStyle(color: Colors.grey),
                ),
                maxLength: 5,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  icon: Icon(
                    Icons.description_outlined,
                    color: Colors.green,
                  ),
                  labelText: 'Masukkan deskripsi barang',
                  errorStyle: TextStyle(color: Colors.grey),
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                maxLength: 1000,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _uploadData,
                child: Text('Simpan'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
