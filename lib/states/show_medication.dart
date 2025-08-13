import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb; // ตรวจสอบ Web/Mobile
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowMedicationPage extends StatefulWidget {
  const ShowMedicationPage({Key? key}) : super(key: key);

  @override
  State<ShowMedicationPage> createState() => _ShowMedicationPageState();
}

class _ShowMedicationPageState extends State<ShowMedicationPage> {
  late String apiUrl;
  List medications = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    // กำหนด URL ตาม platform
    if (kIsWeb) {
      apiUrl = 'http://localhost/api/get_medications.php';
    } else {
      apiUrl = 'http://172.20.10.2/api/get_medications.php'; // เปลี่ยนเป็น IP server จริง
    }

    fetchMedications();
  }

  Future<void> fetchMedications() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          setState(() {
            medications = jsonData['data'] ?? [];
          });
        } else {
          setState(() {
            medications = [];
            errorMessage = jsonData['message'] ?? 'ไม่พบข้อมูล';
          });
        }
      } else {
        setState(() {
          medications = [];
          errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        medications = [];
        errorMessage = 'เกิดข้อผิดพลาด: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลยา'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchMedications,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: medications.map<Widget>((item) {
                      Color cardColor;

                      // กำหนดสีตามความสำคัญ
                      switch (item['importance']) {
                        case 'สำคัญมาก':
                          cardColor = Colors.red[200]!;
                          break;
                        case 'สำคัญ':
                          cardColor = Colors.orange[200]!;
                          break;
                        default:
                          cardColor = Colors.green[200]!;
                      }

                      return Card(
                        color: cardColor,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['medication_name'] ?? '-',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text('ชนิด: ${item['medication_type'] ?? '-'}'),
                              Text('ขนาดต่อครั้ง: ${item['dosage_per_time'] ?? '-'}'),
                              Text('เวลาที่ต้องทาน: ${item['time_to_take'] ?? '-'}'),
                              Text('ความสำคัญ: ${item['importance'] ?? '-'}'),
                              Text('คำแนะนำพิเศษ: ${item['special_instructions'] ?? '-'}'),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
    );
  }
}
