import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';

class DiagramKuisionerSiswa extends StatefulWidget {
  @override
  _DiagramKuisionerSiswaState createState() => _DiagramKuisionerSiswaState();
}

class _DiagramKuisionerSiswaState extends State<DiagramKuisionerSiswa> {
  int touchedIndex = -1;

  // Mapping warna untuk setiap opsi jawaban
  final Map<String, Color> optionColors = {
    'Meningkat': Colors.blue,
    'Tidak berubah': Colors.purple,
    'Menurun': Colors.orange,
    'Sangat sesuai': Colors.blue,
    'Sedikit berlebihan': Colors.purple,
    'Kurang': Colors.orange,
    'Sangat paham': Colors.blue,
    'Cukup paham': Colors.purple,
    'Tidak paham': Colors.orange,
    'Sangat relevan': Colors.blue,
    'Cukup relevan': Colors.purple,
    'Tidak relevan': Colors.orange,
    'Sangat efektif': Colors.blue,
    'Cukup efektif': Colors.purple,
    'Tidak efektif': Colors.orange,
    'Sangat besar': Colors.blue,
    'Cukup besar': Colors.purple,
    // ignore: equal_keys_in_map
    'Kurang': Colors.orange,
    'Sangat terampil': Colors.blue,
    'Cukup terampil': Colors.purple,
    'Tidak terampil': Colors.orange,
    'Sangat menarik': Colors.blue,
    'Cukup menarik': Colors.purple,
    'Kurang menarik': Colors.orange,
    'Semangat': Colors.blue,
    'Biasa': Colors.orange
  };

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('siswa').snapshots(),
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

          // Menghitung jawaban untuk setiap pertanyaan
          final jawabanCounts = List<Map<String, int>>.generate(11, (_) => {});

          for (var doc in siswaDocs) {
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

          final questionOptions = {
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
            'Besarnya dukungan guru terhadap pembelajaran perubahan kurikulum':
                ['Sangat besar', 'Cukup besar', 'Kurang'],
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
            'Respon siswa terhadap perubahan kurikulum merdeka': [
              'Semangat',
              'Biasa'
            ]
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
                final isTouched =
                    data.keys.toList().indexOf(entry.key) == touchedIndex;
                final fontSize = isTouched ? 25.0 : 12.0;
                final radius = isTouched ? 60.0 : 50.0;
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
