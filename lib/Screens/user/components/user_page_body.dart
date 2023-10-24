import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:pinjambarang/Screens/barang/editBarangPage.dart';
import 'package:pinjambarang/Screens/homepage/home_page.dart';
import 'package:pinjambarang/Screens/user/addPinjamPage.dart';

import '../../account/akunPage.dart';
import '../../article/detailArtikelPage.dart';
import '../../barang/addBarangPage.dart';
import '../../login/login.dart';

class UserScreenBody extends StatefulWidget {
  const UserScreenBody({Key? key}) : super(key: key);

  @override
  State<UserScreenBody> createState() => _UserScreenBodyState();
}

class UserProfileDrawerHeader extends StatefulWidget {
  @override
  _UserProfileDrawerHeaderState createState() =>
      _UserProfileDrawerHeaderState();
}

class _UserProfileDrawerHeaderState extends State<UserProfileDrawerHeader> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('uid', isEqualTo: auth.currentUser!.uid)
          .snapshots()
          .map((querySnapshot) => querySnapshot.docs.first),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return UserAccountsDrawerHeader(
            accountName: Text('Loading...'),
            accountEmail: Text('Loading...'),
            currentAccountPicture: CircleAvatar(backgroundColor: Colors.orange),
          );
        }

        if (snapshot.hasError) {
          return UserAccountsDrawerHeader(
            accountName: Text('Error'),
            accountEmail: Text('Error'),
            currentAccountPicture: CircleAvatar(backgroundColor: Colors.red),
          );
        }

        if (snapshot.hasData) {
          var documentSnapshot = snapshot.data as DocumentSnapshot;
          var data = documentSnapshot.data() as Map<String, dynamic>;

          var username = data['name'];
          var email = data['email'];
          var divisi = data['divisi'];
          var userType = data['userType'];
          //jika userType admin dialihkan ke homeScreen
          var imageUrl = data['imageUrl'];

          return UserAccountsDrawerHeader(
            accountName: Text(username),
            accountEmail: Text(userType),
            currentAccountPicture: imageUrl != null
                ? CircleAvatar(backgroundImage: NetworkImage(imageUrl))
                : CircleAvatar(backgroundColor: Colors.orange),
          );
        }

        return UserAccountsDrawerHeader(
          accountName: Text('No data'),
          accountEmail: Text('No data'),
          currentAccountPicture: CircleAvatar(backgroundColor: Colors.orange),
        );
      },
    );
  }
}

class _UserScreenBodyState extends State<UserScreenBody> {
  String _searchKeyword = '';

  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // memberi spasi antar widget
          children: [
            Text('Data Peminjaman'),
            SizedBox(
              width: 100,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPinjamPage()),
                );
              },
              child: Icon(Icons.add_circle_outlined),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchKeyword = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Riwayat Peminjaman',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pinjam')
                    .where('namaBarang', isGreaterThanOrEqualTo: _searchKeyword)
                    .where('uid', isEqualTo: auth.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Terjadi kesalahan');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  // Mengambil data artikel dari snapshot
                  List<DocumentSnapshot> articles = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      // Mengambil data judul dan imageUrl dari artikel
                      String namaBarang = articles[index]['namaBarang'];
                      String namaPeminjam = articles[index]['namaPeminjam'];
                      String divisi = articles[index]['divisi'];
                      String keterangan = articles[index]['keterangan'];
                      String qty = articles[index]['qty'];
                      String docId = articles[index].id;
                      //tanggal
                      String tglPinjamString = articles[index]['tglPinjam'];
                      String tglKembaliString = articles[index]['tglKembali'];

                      var inputFormat = DateFormat('dd-MM-yyyy');
                      var outputFormat = DateFormat('dd MMMM yyyy');

                      var tglPinjam = inputFormat.parse(tglPinjamString);
                      var tglKembali = inputFormat.parse(tglKembaliString);

                      var pinjam = outputFormat.format(tglPinjam);
                      var kembali = outputFormat.format(tglKembali);


                      return ListTile(
                        title: Text(namaBarang),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text("Keterangan : $keterangan"),
                            Text("Qty : $qty"),
                            Text("Tanggal Pinjam : $pinjam"),
                            Text("Tanggal Kembali : $kembali"),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Menampilkan header drawer yang berisi informasi profil pengguna
            UserProfileDrawerHeader(),

            // Menu Home
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserScreenBody()),
                );
              },
            ),

            // Menu Profile
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AkunPage()),
                );
              },
            ),

            // Menu Logout
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                // Setelah berhasil sign out, arahkan pengguna ke halaman login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
