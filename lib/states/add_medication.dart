import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({Key? key}) : super(key: key);

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();

  // ตัวแปรเก็บข้อมูลฟอร์ม
  String medicationName = '';
  String dosagePerTime = '';
  String medicationType = '';
  String timeToTake = '';
  String importance = 'ธรรมดา';
  String specialInstructions = '';

  final List<String> importanceOptions = ['ธรรมดา', 'สำคัญ', 'สำคัญมาก'];

  Future<bool> insertMedication() async {
    final url = Uri.parse('http://localhost/api/insert_medication.php');  // แก้ URL ที่นี่
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'medication_name': medicationName,
          'dosage_per_time': dosagePerTime,
          'medication_type': medicationType,
          'time_to_take': timeToTake,
          'importance': importance,
          'special_instructions': specialInstructions,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['status'] == true;
      } else {
        return false;
      }
    } catch (e) {
      // กรณีเกิดข้อผิดพลาด เช่น network
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มข้อมูลยา')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'ชื่อยา'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'กรุณากรอกชื่อยา' : null,
                onSaved: (value) => medicationName = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'จำนวนเม็ด/ครั้ง'),
                onSaved: (value) => dosagePerTime = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ประเภท'),
                onSaved: (value) => medicationType = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'เวลารับประทาน'),
                onSaved: (value) => timeToTake = value ?? '',
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'ความสำคัญ'),
                value: importance,
                items: importanceOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    importance = value ?? 'ธรรมดา';
                  });
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'คำแนะนำพิเศษ / ข้อควรระวัง'),
                maxLines: 2,
                onSaved: (value) => specialInstructions = value ?? '',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    bool success = await insertMedication();

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('บันทึกข้อมูลยาเรียบร้อย')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูลยา')),
                      );
                    }
                  }
                },
                child: const Text('บันทึกข้อมูลยา'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
