// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class KuisionerGuruForm extends StatefulWidget {
  @override
  _KuisionerGuruFormState createState() => _KuisionerGuruFormState();
}

class _KuisionerGuruFormState extends State<KuisionerGuruForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _guruMataPelajaranController = TextEditingController();
  List<String> _jawaban = List.filled(6, '');
  String _kuisionerId = _generateRandomId();

  static String _generateRandomId() {
    const length = 8;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  final List<String> questions = [
    'Adaptasi terhadap metode pembelajaran baru',
    'Digitalisasi metode pendidikan',
    'Perubahan biaya pendidikan terhadap jumlah pendaftaran siswa baru',
    'Perubahan kurikulum meningkatkan kolaborasi dan kreativitas siswa dalam kelas',
    'Efektivitas pelatihan guru terkait kurikulum baru',
    'Dampak implementasi kurikulum merdeka terhadap perkembangan sekolah',
  ];

  final Map<String, List<String>> options = {
    'Adaptasi terhadap metode pembelajaran baru': [
      'Sangat baik',
      'Baik',
      'Tidak baik'
    ],
    'Digitalisasi metode pendidikan': ['Sangat Paham', 'Paham', 'Tidak paham'],
    'Perubahan biaya pendidikan terhadap jumlah pendaftaran siswa baru': [
      'Meningkat',
      'Tidak meningkat'
    ],
    'Perubahan kurikulum meningkatkan kolaborasi dan kreativitas siswa dalam kelas':
        ['Sangat kreatif', 'Biasa', 'Tidak kreatif'],
    'Efektivitas pelatihan guru terkait kurikulum baru': [
      'Sangat efektif',
      'Efektif',
      'Tidak efektif'
    ],
    'Dampak implementasi kurikulum merdeka terhadap perkembangan sekolah': [
      'Sangat berdampak',
      'Biasa'
    ],
  };

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      bool allAnswered = true;
      for (var answer in _jawaban) {
        if (answer.isEmpty) {
          allAnswered = false;
          break;
        }
      }

      if (!allAnswered) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Semua pertanyaan harus dijawab')),
        );
        return;
      }

      if (_namaController.text.isEmpty ||
          _guruMataPelajaranController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nama dan Guru Mata Pelajaran harus diisi')),
        );
        return;
      }

      try {
        final kuisioner = KuisionerGuru(
          id: _kuisionerId,
          nama: _namaController.text,
          guruMataPelajaran: _guruMataPelajaranController.text,
          jawaban: _jawaban,
        );

        // Simpan ke SQLite
        await DBHelperGuru().insertKuisioner(kuisioner);

        // Simpan ke Firestore dengan pengecekan duplikasi berdasarkan ID
        final docRef =
            FirebaseFirestore.instance.collection('guru').doc(_kuisionerId);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          await docRef.set({
            'id': _kuisionerId,
            'nama': _namaController.text,
            'guruMataPelajaran': _guruMataPelajaranController.text,
            'jawaban': _jawaban,
          });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Kuisioner berhasil disimpan')));
          _resetForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data dengan ID ini sudah ada')),
          );
        }
      } catch (e) {
        print('Error: $e'); // Logging error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Terjadi kesalahan. Cek kembali form pengisian')),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _namaController.clear();
      _guruMataPelajaranController.clear();
      _jawaban = List.filled(6, '');
      _kuisionerId = _generateRandomId(); // Generate new ID for reset form
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedDefaultTextStyle(
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          duration: const Duration(milliseconds: 300),
          child: Row(
            children: [
              Icon(Icons.question_answer, color: Colors.black),
              SizedBox(width: 8),
              Text('Kuisioner Guru'),
            ],
          ),
        ),
        backgroundColor: Colors.lightGreen.shade100,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _resetForm,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 7),
              Text(
                'ID Kuisioner: $_kuisionerId',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama harus diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _guruMataPelajaranController,
                decoration: InputDecoration(
                  labelText: 'Guru Mata Pelajaran',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Guru Mata Pelajaran harus diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ...questions.asMap().entries.map((entry) {
                int index = entry.key;
                String question = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...options[question]!.map((option) {
                      return RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: _jawaban[index],
                        onChanged: (value) {
                          setState(() {
                            _jawaban[index] = value!;
                          });
                        },
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    minimumSize: Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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

class KuisionerGuru {
  final String id;
  final String nama;
  final String guruMataPelajaran;
  final List<String> jawaban;

  KuisionerGuru({
    required this.id,
    required this.nama,
    required this.guruMataPelajaran,
    required this.jawaban,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'guruMataPelajaran': guruMataPelajaran,
      'jawaban': jawaban,
    };
  }
}

class DBHelperGuru {
  // Assumed method for SQLite insertion
  Future<void> insertKuisioner(KuisionerGuru kuisioner) async {
    // Implementation of SQLite insertion here
  }
}
