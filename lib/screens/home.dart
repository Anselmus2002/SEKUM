import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sekum/decision_tree/decision_tree_guru.dart';
import 'package:sekum/decision_tree/decisoin_tree_siswa.dart';
import 'package:sekum/screens/admin/diagram_guru.dart';
import 'package:sekum/screens/admin/diagram_siswa.dart';
import 'package:sekum/screens/siswa/kuisioner_form.dart';
import 'package:sekum/screens/guru/kuisioner_guru_form.dart';
import 'package:sekum/screens/admin/kuisioner_guru_results.dart';
import 'package:sekum/screens/admin/kuisioner_siswa_result.dart';
import 'package:sekum/screens/admin/register.dart';
import 'package:sekum/screens/admin/user_management_screen.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  final String role;

  HomeScreen({required this.role});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    Color backgroundColor;
    if (widget.role == 'siswa') {
      backgroundColor = Colors.yellow;
    } else if (widget.role == 'guru') {
      backgroundColor = Colors.green;
    } else {
      backgroundColor = Colors.blue;
    }

    DateTime now = DateTime.now();
    String formattedDate = "${now.day}/${now.month}/${now.year}";
    String formattedTime = "${now.hour}:${now.minute}";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        title: Text(
          'HOME',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Login sebagai ${widget.role.toUpperCase()}'),
              accountEmail:
                  Text('Tanggal: $formattedDate\nWaktu: $formattedTime'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/profile_placeholder.jpg'),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          AnimatedBackground(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  if (widget.role == 'siswa') ...[
                    _buildMenuCard(
                      icon: Icons.school_outlined,
                      iconColor: Colors.blue,
                      text: 'Isi Kuisioner Siswa',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => KuisionerForm()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.help_outline,
                      iconColor: Colors.orange,
                      text: 'Petunjuk Pengisian Kuisioner',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Petunjuk Pengisian Kuisioner'),
                            content: Text(
                                'Berikut adalah petunjuk untuk mengisi kuisioner...\n'
                                '1. Isi form nama dengan nama lengkap responden\n'
                                '2. Isi form kelas sesuai dengan kelas sekarang antara 1 - 12\n'
                                '3. Isi semua jawaban kuisioner dengan cermat\n'
                                '4. Pastikan semua form dan kuisioner sudah di isi\n'
                                '5. Tekan tombol submit untuk mengirim kuisioner'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  if (widget.role == 'guru') ...[
                    _buildMenuCard(
                      icon: Icons.people,
                      iconColor: Colors.black,
                      text: 'Isi Kuisioner Guru',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => KuisionerGuruForm()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.help_outline,
                      iconColor: Colors.orange,
                      text: 'Petunjuk Pengisian Kuisioner',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Petunjuk Pengisian Kuisioner'),
                            content: Text(
                                'Berikut adalah petunjuk untuk mengisi kuisioner...\n'
                                '1. Isi form nama dengan nama lengkap responden\n'
                                '2. Isi form guru mata pelajaran sesuai dengan mata pelajaran yang di ampuh di sekolah dan isikan guru kelas jika anda bukan guru pengampuh mata pelajaran\n'
                                '3. Isi semua jawaban kuisioner dengan cermat\n'
                                '4. Pastikan semua form dan kuisioner sudah di isi\n'
                                '5. Tekan tombol submit untuk mengirim kuisioner'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  if (widget.role == 'admin') ...[
                    _buildMenuCard(
                      icon: Icons.list,
                      iconColor: Colors.blue,
                      text: 'Lihat Hasil Kuisioner Siswa',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => KuisionerSiswaResult()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.list,
                      iconColor: Colors.black,
                      text: 'Lihat Hasil Kuisioner Guru',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => KuisionerGuruResults()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.donut_large,
                      iconColor: Colors.blue,
                      text: 'Diagram Hasil Kuisioner Siswa',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => DiagramKuisionerSiswa()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.donut_large,
                      iconColor: Colors.black,
                      text: 'Diagram Hasil Kuisioner Guru',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => DiagramKuisionerGuru()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.pause_presentation_outlined,
                      iconColor: Colors.blue,
                      text: 'Decision Tree Siswa',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => DecisionTreeSiswa()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.pause_presentation_outlined,
                      iconColor: Colors.black,
                      text: 'Decision Tree Guru',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => DecisionTreeGuru()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.people,
                      iconColor: Colors.black,
                      text: 'Penguna',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => UserManagementScreen()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.app_registration,
                      iconColor: Colors.black,
                      text: 'Registrasi',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => RegisterScreen()),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
      {required IconData icon,
      required Color iconColor,
      required String text,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 191, 137, 137),
                const Color.fromARGB(255, 163, 202, 231)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: iconColor),
              SizedBox(height: 10),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _bubbles = List.generate(50, (index) => Bubble());

    _controller.addListener(() {
      setState(() {
        for (var bubble in _bubbles) {
          bubble.update();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblesPainter(_bubbles),
      child: Container(),
    );
  }
}

class Bubble {
  double x;
  double y;
  double radius;
  double dx;
  double dy;
  Color color;

  Bubble()
      : x = Random().nextDouble() * 400,
        y = Random().nextDouble() * 800,
        radius = Random().nextDouble() * 10 + 5,
        dx = Random().nextDouble() * 2 - 1,
        dy = Random().nextDouble() * 2 - 1,
        color = Color.fromRGBO(
          Random().nextInt(256),
          Random().nextInt(256),
          Random().nextInt(256),
          Random().nextDouble(),
        );

  void update() {
    x += dx;
    y += dy;

    if (x < 0 || x > 400) dx = -dx;
    if (y < 0 || y > 800) dy = -dy;
  }
}

class BubblesPainter extends CustomPainter {
  final List<Bubble> bubbles;

  BubblesPainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var bubble in bubbles) {
      paint.color = bubble.color;
      canvas.drawCircle(Offset(bubble.x, bubble.y), bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
