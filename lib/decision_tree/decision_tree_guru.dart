import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sekum/models/decision_tree.dart';

import 'package:sekum/widgets/decision_tree_painter_guru.dart';

class DecisionTreeGuru extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('C4.5 Decision Tree')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('guru').snapshots(),
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
              'Adaptasi terhadap metode pembelajaran baru':
                  jawaban.length > 0 ? jawaban[0].toString() : 'null',
              'Digitalisasi metode pendidikan':
                  jawaban.length > 1 ? jawaban[1].toString() : 'null',
              'Perubahan biaya pendidikan terhadap jumlah pendaftaran siswa baru':
                  jawaban.length > 2 ? jawaban[2].toString() : 'null',
              'Perubahan kurikulum meningkatkan kolaborasi dan kreativitas siswa dalam kelas':
                  jawaban.length > 3 ? jawaban[3].toString() : 'null',
              'Efektivitas pelatihan guru terkait kurikulum baru':
                  jawaban.length > 4 ? jawaban[4].toString() : 'null',
              'Dampak implementasi kurikulum merdeka terhadap perkembangan sekolah':
                  jawaban.length > 5 ? jawaban[5].toString() : 'null',
            };
          }).toList();

          List<String> attributes = [
            'Adaptasi terhadap metode pembelajaran baru',
            'Digitalisasi metode pendidikan',
            'Perubahan biaya pendidikan terhadap jumlah pendaftaran siswa baru',
            'Perubahan kurikulum meningkatkan kolaborasi dan kreativitas siswa dalam kelas',
            'Efektivitas pelatihan guru terkait kurikulum baru',
          ];

          String targetAttribute =
              'Dampak implementasi kurikulum merdeka terhadap perkembangan sekolah';

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
                child: DecisionTreeDiagramGuru(root: root),
              ),
            ),
          );
        },
      ),
    );
  }
}
