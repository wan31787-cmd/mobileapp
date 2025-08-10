import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainMenu({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'หน้าหลัก',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services),
          label: 'ยาของฉัน',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'นัดหมาย',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.document_scanner),
          label: 'รายงาน',
        ),
      ],
    );
  }
}
