import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({Key? key}) : super(key: key);

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  List appointments = [];
  bool isLoading = true;
  String errorMessage = '';

  // เปลี่ยน URL นี้เป็น URL จริงของ API คุณ
  final String apiUrl = 'http://localhost/api/get_appointments.php';

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          setState(() {
            appointments = jsonData['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? 'Unknown error';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }

  String formatDateTime(String date, String time) {
    return '$date $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment List'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final item = appointments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      elevation: 3, // เพิ่มเงา
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // มุมโค้งมน
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0), // เพิ่ม padding รอบๆ
                        child: ListTile(
                          title: Text(
                            item['appointment_subject'] ?? '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text('Date & Time: ${formatDateTime(item['appointment_date'], item['appointment_time'])}'),
                              Text('Location: ${item['location_details'] ?? '-'}'),
                              if ((item['notes'] ?? '').isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('Notes: ${item['notes']}'),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
