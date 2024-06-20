import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class KuisionerSiswaResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          'Hasil Kuisioner Siswa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('siswa').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final siswaDocs = snapshot.data?.docs ?? [];

                if (siswaDocs.isEmpty) {
                  return Center(child: Text('Tidak ada data kuisioner siswa!'));
                }

                // Menambahkan kolom untuk setiap pertanyaan
                final columns = [
                  DataColumn(label: Text('Id')),
                  DataColumn(label: Text('Nama')),
                  DataColumn(label: Text('Kelas')),
                ];

                final questions = [
                  'Prestasi akademik',
                  'Prestasi non akademik',
                  'Jam pembelajaran pada kurikulum merdeka',
                  'Pemahaman terhadap pembelajaran proyek pada kurikulum merdeka',
                  'Pemahaman siswa terhadap internet',
                  'Kerelevanan pembelajaran dengan kehidupan siswa',
                  'Efektifvitas siswa terhadap penyelesaian pembelajaran',
                  'Besarnya dukungan guru terhadap pembelajaran perubahan kurikulum',
                  'Keterampilan kritis dan kreatif siswa pada perubahan kurikulum',
                  'Ekskul pada kurikulum merdeka',
                  'Respon siswa terhadap perubahan kurikulum merdeka',
                ];

                for (var question in questions) {
                  columns.add(DataColumn(label: Text(question)));
                }

                columns.add(DataColumn(label: Text('AKSI')));

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Untuk scroll horizontal
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical, // Untuk scroll vertical
                    child: DataTable(
                      columns: columns,
                      rows: siswaDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final id = doc.id;
                        final jawaban = data['jawaban'] as List<dynamic>? ?? [];

                        // Membuat sel untuk setiap pertanyaan
                        final cells = [
                          DataCell(Text(data['id'] ?? '')),
                          DataCell(Text(data['nama'] ?? '')),
                          DataCell(Text(data['kelas']?.toString() ?? '')),
                        ];

                        for (var answer in jawaban) {
                          cells.add(DataCell(Text(answer.toString())));
                        }

                        cells.add(
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, id),
                            ),
                          ),
                        );

                        return DataRow(cells: cells);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => _downloadData(context),
              icon: Icon(Icons.download, color: Colors.white),
              label: Text(
                'Download Data Excel',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: EdgeInsets.all(10.0),
                textStyle: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konfirmasi penghapusan'),
          content: Text('Apakah yakin anda ingin menghapus data ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue),
              child: Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('siswa')
                    .doc(id)
                    .delete();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red),
              child: Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadData(BuildContext context) async {
    // Check for storage permission
    if (await Permission.storage.request().isGranted) {
      try {
        // Get data from Firestore
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('siswa').get();
        List<QueryDocumentSnapshot> docs = querySnapshot.docs;

        // Create an Excel document
        var excel = Excel.createExcel();
        Sheet sheetObject = excel['Sheet1'];

        // Assuming all documents have the same fields
        if (docs.isNotEmpty) {
          // Get headers from the first document
          var headers = [
            'Id',
            'Nama',
            'Kelas',
            'Prestasi akademik',
            'Prestasi non akademik',
            'Jam pembelajaran pada kurikulum merdeka',
            'Pemahaman terhadap pembelajaran proyek pada kurikulum merdeka',
            'Pemahaman siswa terhadap internet',
            'Kerelevanan pembelajaran dengan kehidupan siswa',
            'Efektifvitas siswa terhadap penyelesaian pembelajaran',
            'Besarnya dukungan guru terhadap pembelajaran perubahan kurikulum',
            'Keterampilan kritis dan kreatif siswa pada perubahan kurikulum',
            'Ekskul pada kurikulum merdeka',
            'Respon siswa terhadap perubahan kurikulum merdeka'
          ];
          sheetObject.appendRow(headers);

          // Add rows for each document
          for (var doc in docs) {
            var data = doc.data() as Map<String, dynamic>;
            var jawaban = data['jawaban'] as List<dynamic>? ?? [];
            List<dynamic> row = [
              data['id'],
              data['nama'],
              data['kelas'],
              ...jawaban
            ];
            sheetObject.appendRow(row);
          }

          // Get the directory to save the file
          Directory? directory = await getExternalStorageDirectory();
          String filePath = "${directory!.path}/kuisioner_siswa.xlsx";

          // Save the file
          File(filePath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(excel.encode()!);

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("File saved at $filePath")));
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to download data: $e")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Storage permission is required to save the file.")));
    }
  }
}
