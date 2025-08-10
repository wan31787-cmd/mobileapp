import 'package:flutter/material.dart'; 
import 'package:mobile/states/authen.dart'; 
import '../body/main_menu.dart';
import 'package:mobile/states/add_medication.dart';  // หน้าเพิ่มข้อมูลยา
import 'package:mobile/states/add_appointment.dart'; // หน้าเพิ่มนัดหมาย
import 'package:mobile/states/appointmentlistpage.dart'; // เพิ่ม import หน้านัดหมาย

class MainMobilePage extends StatefulWidget {
  const MainMobilePage({Key? key}) : super(key: key);

  @override
  State<MainMobilePage> createState() => _MainMobilePageState();
}

class _MainMobilePageState extends State<MainMobilePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Center(child: Text('ยินดีต้อนรับเข้าสู่แอป', style: TextStyle(fontSize: 24))),
      const Center(child: Text('ข้อมูลยา', style: TextStyle(fontSize: 24))),
      const AppointmentListPage(), // แก้ตรงนี้ให้เป็นหน้าแสดงนัดหมายดึงข้อมูลจริง
      const Center(child: Text('รายงาน', style: TextStyle(fontSize: 24))),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? fab; // ตัวแปรเก็บ FloatingActionButton

    if (_selectedIndex == 1) {
      // หน้า "ยา"
      fab = FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicationPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'เพิ่มข้อมูลยา',
      );
    } else if (_selectedIndex == 2) {
      // หน้า "นัดหมาย"
      fab = FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAppointmentPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'เพิ่มนัดหมาย',
      );
    } else {
      fab = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'หน้าหลัก'
              : _selectedIndex == 1
                  ? 'ยา'
                  : _selectedIndex == 2
                      ? 'นัดหมาย'
                      : 'รายงาน',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ออกจากระบบ',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthenPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: MainMenu(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: fab,
    );
  }
}
