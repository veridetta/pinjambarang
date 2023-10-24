import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

import '../../account/akunPage.dart';
import '../../article/detailArtikelPage.dart';
import '../../barang/addBarangPage.dart';
import '../../barang/editBarangPage.dart';
import '../../login/login.dart';
import 'pinjaman_page_body.dart';

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({Key? key}) : super(key: key);

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
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
          var userType = data['userType'];
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

class _HomeScreenBodyState extends State<HomeScreenBody> {
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
            Text('Data Barang'),
            SizedBox(
              width: 100,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddBarangPage()),
                );
              },
              child: Icon(Icons.post_add_outlined),
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
              'Data Barang',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('barang')
                    .where('nama', isGreaterThanOrEqualTo: _searchKeyword)
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
                      String judul = articles[index]['nama'];
                      String deskripsi = articles[index]['deskripsi'];
                      String stok = articles[index]['stok'].toString();
                      String docId = articles[index].id;
                      return ListTile(
                        title: Text(judul),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text("Deskripsi $deskripsi"),
                            Text("Stok $stok"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditBarangPage( // Ganti EditBarangPage dengan halaman yang sesuai
                                      documentId: articles[index].id,
                                    ),
                                  ),
                                );
                              },
                              child: Icon(Icons.edit), // Tombol Edit
                            ),
                            SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Hapus Barang'),
                                      content: Text('Apakah anda yakin ingin menghapus barang ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('barang')
                                                .doc(docId)
                                                .delete();
                                            Navigator.pop(context);
                                          },
                                          child: Text('Hapus'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Icon(Icons.delete), // Tombol Hapus
                            ),
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
                  MaterialPageRoute(builder: (context) => HomeScreenBody()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_outlined),
              title: Text('Data Pinjaman'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PinjamanScreenBody()),
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
