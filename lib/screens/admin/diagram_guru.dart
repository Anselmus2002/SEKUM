// ignore_for_file: equal_keys_in_map

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DiagramKuisionerGuru extends StatefulWidget {
  @override
  _DiagramKuisionerGuruState createState() => _DiagramKuisionerGuruState();
}

class _DiagramKuisionerGuruState extends State<DiagramKuisionerGuru> {
  // Mapping warna untuk setiap opsi jawaban
  final Map<String, Color> optionColors = {
    'Sangat baik': Colors.green,
    'Baik': Colors.blue,
    'Tidak baik': Colors.orange,
    'Sangat Paham': Colors.green,
    'Paham': Colors.blue,
    'Tidak paham': Colors.orange,
    'Meningkat': Colors.green,
    'Tidak meningkat': Colors.blue,
    'Sangat kreatif': Colors.green,
    'Biasa': Colors.blue,
    'Tidak kreatif': Colors.orange,
    'Sangat efektif': Colors.green,
    'Efektif': Colors.blue,
    'Tidak efektif': Colors.orange,
    'Sangat berdampak': Colors.green,
    'Biasa': Colors.blue
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          'Hasil Kuisioner Guru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('guru').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final guruDocs = snapshot.data?.docs ?? [];

          if (guruDocs.isEmpty) {
            return Center(child: Text('Tidak ada data kuisioner guru!'));
          }

          // Menghitung jawaban untuk setiap pertanyaan
          final jawabanCounts = List<Map<String, int>>.generate(6, (_) => {});

          for (var doc in guruDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final jawaban = data['jawaban'] as List<dynamic>? ?? [];
            for (var i = 0; i < jawaban.length; i++) {
              final answer = jawaban[i].toString();
              if (!jawabanCounts[i].containsKey(answer)) {
                jawabanCounts[i][answer] = 0;
              }
              jawabanCounts[i][answer] = jawabanCounts[i][answer]! + 1;
            }
          }

          final questionTitles = [
            'Adaptasi terhadap metode pembelajaran baru',
            'Digitalisasi metode pendidikan',
            'Perubahan biaya pendidikan terhadap jumlah pendaftaran siswa baru',
            'Perubahan kurikulum meningkatkan kolaborasi dan kreativitas siswa dalam kelas',
            'Efektivitas pelatihan guru terkait kurikulum baru',
            'Dampak implementasi kurikulum merdeka terhadap perkembangan sekolah'
          ];

          final questionOptions = {
            'Adaptasi terhadap metode pembelajaran baru': [
              'Sangat baik',
              'Baik',
              'Tidak baik'
            ],
            'Digitalisasi metode pendidikan': [
              'Sangat Paham',
              'Paham',
              'Tidak paham'
            ],
            'Perubahan biaya pendidikan terhadap jumlah pendaftaran siswa baru':
                ['Meningkat', 'Tidak meningkat'],
            'Perubahan kurikulum meningkatkan kolaborasi dan kreativitas siswa dalam kelas':
                ['Sangat kreatif', 'Biasa', 'Tidak kreatif'],
            'Efektivitas pelatihan guru terkait kurikulum baru': [
              'Sangat efektif',
              'Efektif',
              'Tidak efektif'
            ],
            'Dampak implementasi kurikulum merdeka terhadap perkembangan sekolah':
                ['Sangat berdampak', 'Biasa']
          };

          return ListView.builder(
            itemCount: jawabanCounts.length,
            itemBuilder: (context, index) {
              final questionTitle = questionTitles[index];
              final options = questionOptions[questionTitle]!;
              final data = jawabanCounts[index];
              final totalResponses = data.values.fold(0, (a, b) => a + b);
              final pieSections = data.entries.map((entry) {
                final value = (entry.value / totalResponses) * 100;
                final fontSize = 12.0;
                final radius = 50.0;
                final color = optionColors[entry.key]!;
                return PieChartSectionData(
                  color: color,
                  value: value,
                  title: '${value.toStringAsFixed(1)}%',
                  radius: radius,
                  titleStyle: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                );
              }).toList();

              return Card(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(questionTitle,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: pieSections,
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ...options.asMap().entries.map((entry) {
                      // ignore: unused_local_variable
                      final idx = entry.key;
                      final option = entry.value;
                      final color = optionColors[option]!;
                      final count = data[option] ?? 0;
                      final percentage = totalResponses > 0
                          ? (count / totalResponses) * 100
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: color,
                            ),
                            SizedBox(width: 8),
                            Text(
                                '$option: ${percentage.toStringAsFixed(1)}% ($count)'),
                          ],
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
