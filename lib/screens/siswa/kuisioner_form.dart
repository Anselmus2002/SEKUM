import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class KuisionerForm extends StatefulWidget {
  @override
  _KuisionerFormState createState() => _KuisionerFormState();
}

class _KuisionerFormState extends State<KuisionerForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kelasController = TextEditingController();
  List<String> _jawaban = List.filled(11, '');
  String _kuisionerId = Uuid().v4();

  final List<String> questions = [
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

  final Map<String, List<String>> options = {
    'Prestasi akademik': ['Meningkat', 'Tidak berubah', 'Menurun'],
    'Prestasi non akademik': ['Meningkat', 'Tidak berubah', 'Menurun'],
    'Jam pembelajaran pada kurikulum merdeka': [
      'Sangat sesuai',
      'Sedikit berlebihan',
      'Kurang'
    ],
    'Pemahaman terhadap pembelajaran proyek pada kurikulum merdeka': [
      'Sangat paham',
      'Cukup paham',
      'Tidak paham'
    ],
    'Pemahaman siswa terhadap internet': [
      'Sangat paham',
      'Cukup paham',
      'Tidak paham'
    ],
    'Kerelevanan pembelajaran dengan kehidupan siswa': [
      'Sangat relevan',
      'Cukup relevan',
      'Tidak relevan'
    ],
    'Efektifvitas siswa terhadap penyelesaian pembelajaran': [
      'Sangat efektif',
      'Cukup efektif',
      'Tidak efektif'
    ],
    'Besarnya dukungan guru terhadap pembelajaran perubahan kurikulum': [
      'Sangat besar',
      'Cukup besar',
      'Kurang'
    ],
    'Keterampilan kritis dan kreatif siswa pada perubahan kurikulum': [
      'Sangat terampil',
      'Cukup terampil',
      'Tidak terampil'
    ],
    'Ekskul pada kurikulum merdeka': [
      'Sangat menarik',
      'Cukup menarik',
      'Kurang menarik'
    ],
    'Respon siswa terhadap perubahan kurikulum merdeka': ['Semangat', 'Biasa'],
  };

  @override
  void initState() {
    super.initState();
    _kuisionerId = _generateId();
  }

  String _generateId() {
    return Uuid().v4().substring(0, 8);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Cek apakah semua jawaban telah diisi
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

      try {
        // Simpan ke Firestore dengan pengecekan duplikasi berdasarkan ID
        final docRef =
            FirebaseFirestore.instance.collection('siswa').doc(_kuisionerId);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          await docRef.set({
            'id': _kuisionerId,
            'nama': _namaController.text,
            'kelas': int.parse(_kelasController.text),
            'jawaban': _jawaban,
          });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Kuisioner berhasil disimpan')));
          _formKey.currentState!.reset();
          setState(() {
            _namaController.clear();
            _kelasController.clear();
            _jawaban = List.filled(11, '');
            _kuisionerId = _generateId(); // Generate new ID for the next form
          });
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
              Text('Kuisioner'),
            ],
          ),
        ),
        backgroundColor: Colors.lightBlue.shade100,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              setState(() {
                _formKey.currentState!.reset();
                _namaController.clear();
                _kelasController.clear();
                _jawaban = List.filled(11, '');
                _kuisionerId = Uuid().v4(); // Generate new ID for reset form
              });
            },
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
                controller: _kelasController,
                decoration: InputDecoration(
                  labelText: 'Kelas',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kelas harus diisi';
                  }
                  final n = int.tryParse(value);
                  if (n == null || n < 1 || n > 12) {
                    return 'Kelas harus antara 1 dan 12';
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
                    backgroundColor: Colors.blueAccent,
                    minimumSize: Size(150, 50), // Shortened button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

class Kuisioner {
  final String id;
  final String nama;
  final int kelas;
  final List<String> jawaban;

  Kuisioner({
    required this.id,
    required this.nama,
    required this.kelas,
    required this.jawaban,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'kelas': kelas,
      'jawaban': jawaban,
    };
  }
}

class DBHelper {
  // Assumed method for SQLite insertion
  Future<void> insertKuisioner(Kuisioner kuisioner) async {
    // Implementation of SQLite insertion here
  }
}
