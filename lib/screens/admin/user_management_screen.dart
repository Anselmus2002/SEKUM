import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _updateUser(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'username': _nameController.text,
      'role': _roleController.text,
      'password': _passwordController.text,
      'email': _emailController.text,
    });
    Navigator.of(context).pop();
  }

  Future<void> _deleteUser(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }

  Future<void> _showEditDialog(DocumentSnapshot userDoc) async {
    _nameController.text = userDoc['username'];
    _roleController.text = userDoc['role'];
    _passwordController.text = userDoc['password'];
    _emailController.text = userDoc['email'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _roleController,
              decoration: InputDecoration(labelText: 'Role'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () => _updateUser(userDoc.id),
            child: Text('Update', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(String userId) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus User'),
        content: Text('Apakah anda yakin ingin menghapus user ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Tidak', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              _deleteUser(userId);
              Navigator.of(ctx).pop();
            },
            child: Text('Ya', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          'Kelola Pengguna',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Nama')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Password')),
                DataColumn(label: Text('Aksi')),
              ],
              rows: snapshot.data!.docs.map((doc) {
                return DataRow(cells: [
                  DataCell(Text(doc['username'])),
                  DataCell(Text(doc['role'])),
                  DataCell(Text(doc['email'])),
                  DataCell(Text(doc['password'])),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        onPressed: () => _showEditDialog(doc),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () => _showDeleteDialog(doc.id),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
