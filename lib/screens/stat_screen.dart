// lib/screens/stats_screen.dart
import 'package:flutter/material.dart';

// StatsScreen เป็น StatelessWidget เพราะมันจะแสดงผลข้อมูลสถิตินิ่งๆ
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Learning Stats'),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.analytics,
                size: 80,
                color: Colors.blueGrey,
              ),
              const SizedBox(height: 20),
              const Text(
                'Progress Overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              // Card แสดงผลสถิติจำลอง
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: const ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Lessons Completed'),
                  trailing: Text('12', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: const ListTile(
                  leading: Icon(Icons.star, color: Colors.amber),
                  title: Text('Current Streak'),
                  trailing: Text('12 Days', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
              // ปุ่มย้อนกลับ
              ElevatedButton(
                onPressed: () {
                  // ใช้ Navigator.pop เพื่อย้อนกลับไปยังหน้าจอก่อนหน้า
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Go Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}