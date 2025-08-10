import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAppointmentPage extends StatefulWidget {
  const AddAppointmentPage({Key? key}) : super(key: key);

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  String appointmentSubject = '';
  DateTime? appointmentDate;
  TimeOfDay? appointmentTime;
  String locationDetails = '';
  String notes = '';

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: appointmentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('th'),
    );
    if (picked != null) {
      setState(() {
        appointmentDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: appointmentTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        appointmentTime = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<bool> insertAppointment() async {
    // TODO: เปลี่ยน IP เป็นของเครื่องคุณเอง ที่รัน PHP API แทน localhost
    final url = Uri.parse('http://172.20.10.2/api/insert_appointment.php');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'appointment_subject': appointmentSubject,
          'appointment_date': _formatDate(appointmentDate),
          'appointment_time': _formatTime(appointmentTime),
          'location_details': locationDetails,
          'notes': notes,
        },
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['status'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มนัดหมาย')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'หัวข้อนัดหมาย'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'กรุณากรอกหัวข้อนัดหมาย' : null,
                onSaved: (value) => appointmentSubject = value ?? '',
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'วันที่นัด',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    appointmentDate != null ? _formatDate(appointmentDate) : 'เลือกวันที่',
                    style: TextStyle(
                      color: appointmentDate != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'เวลานัด',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    appointmentTime != null ? _formatTime(appointmentTime) : 'เลือกเวลา',
                    style: TextStyle(
                      color: appointmentTime != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'รายละเอียดสถานที่และแพทย์'),
                maxLines: 2,
                onSaved: (value) => locationDetails = value ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'หมายเหตุสิ่งที่ต้องเตรียม'),
                maxLines: 2,
                onSaved: (value) => notes = value ?? '',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (appointmentDate == null) {
                      _showMessage('กรุณาเลือกวันที่นัด');
                      return;
                    }
                    if (appointmentTime == null) {
                      _showMessage('กรุณาเลือกเวลานัด');
                      return;
                    }

                    _formKey.currentState!.save();

                    bool success = await insertAppointment();
                    if (success) {
                      _showMessage('บันทึกนัดหมายเรียบร้อย');
                      Navigator.pop(context);
                    } else {
                      _showMessage('เกิดข้อผิดพลาดในการบันทึกนัดหมาย');
                    }
                  }
                },
                child: const Text('บันทึกนัดหมาย'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
