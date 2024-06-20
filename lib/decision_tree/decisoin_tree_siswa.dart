import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sekum/models/decision_tree.dart';

import 'package:sekum/widgets/decision_tree_painter_siswa.dart';

class DecisionTreeSiswa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('C4.5 Decision Tree')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('siswa').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available'));
          }

          List<Map<String, String>> data = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            List<dynamic> jawaban = data['jawaban'] ?? [];
            return {
              'Prestasi akademik':
                  jawaban.length > 0 ? jawaban[0].toString() : 'null',
              'Prestasi non akademik':
                  jawaban.length > 1 ? jawaban[1].toString() : 'null',
              'Jam pembelajaran pada kurikulum merdeka':
                  jawaban.length > 2 ? jawaban[2].toString() : 'null',
              'Pemahaman terhadap pembelajaran proyek pada kurikulum merdeka':
                  jawaban.length > 3 ? jawaban[3].toString() : 'null',
              'Pemahaman siswa terhadap internet':
                  jawaban.length > 4 ? jawaban[4].toString() : 'null',
              'Kerelevanan pembelajaran dengan kehidupan siswa':
                  jawaban.length > 5 ? jawaban[5].toString() : 'null',
              'Efektifvitas siswa terhadap penyelesaian pembelajaran':
                  jawaban.length > 6 ? jawaban[6].toString() : 'null',
              'Besarnya dukungan guru terhadap pembelajaran perubahan kurikulum':
                  jawaban.length > 7 ? jawaban[7].toString() : 'null',
              'Keterampilan kritis dan kreatif siswa pada perubahan kurikulum':
                  jawaban.length > 8 ? jawaban[8].toString() : 'null',
              'Ekskul pada kurikulum merdeka':
                  jawaban.length > 9 ? jawaban[9].toString() : 'null',
              'Respon siswa terhadap perubahan kurikulum merdeka':
                  jawaban.length > 10 ? jawaban[10].toString() : 'null',
            };
          }).toList();

          List<String> attributes = [
            'Prestasi akademik',
            'Prestasi non akademik',
            'Jam pembelajaran pada kurikulum merdeka',
            'Pemahaman terhadap pembelajaran proyek pada kurikulum merdeka',
            'Pemahaman siswa terhadap internet',
            'Kerelevanan pembelajaran dengan kehidupan siswa',
            'Efektifvitas siswa terhadap penyelesaian pembelajaran',
            'Besarnya dukungan guru terhadap pembelajaran perubahan kurikulum',
            'Keterampilan kritis dan kreatif siswa pada perubahan kurikulum',
            'Ekskul pada kurikulum merdeka'
          ];

          String targetAttribute =
              'Respon siswa terhadap perubahan kurikulum merdeka';

          C45DecisionTree tree =
              C45DecisionTree(data, attributes, targetAttribute);
          DecisionTreeNode root = tree.build();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: MediaQuery.of(context).size.width * 2,
                height: MediaQuery.of(context).size.height * 2,
                child: DecisionTreeDiagram(root: root),
              ),
            ),
          );
        },
      ),
    );
  }
}
