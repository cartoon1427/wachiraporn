import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'addproduct.dart'; // นำเข้าไฟล์ AddProductPage
import 'showproductgrid.dart'; // นำเข้าไฟล์ ProductListPage
import 'showproducttype.dart'; // นำเข้าไฟล์ ShowProductType (ต้องสร้างในภายหลัง)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyB0nxbkVWdG501s7r3gBBUuvgGr_2e2xAM",
            authDomain: "onlinefirebase-c1d35.firebaseapp.com",
            databaseURL:
                "https://onlinefirebase-c1d35-default-rtdb.firebaseio.com",
            projectId: "onlinefirebase-c1d35",
            storageBucket: "onlinefirebase-c1d35.firebasestorage.app",
            messagingSenderId: "1051273705315",
            appId: "1:1051273705315:web:c0e9eddeb5690c67d54556",
            measurementId: "G-D5XC2DBNS3"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  // สร้างปุ่มแบบกำหนดเองเพื่อความสะดวก
  Widget _buildCustomButton(BuildContext context,
      {required String text, required VoidCallback onPressed, Color? color}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: Colors.black), // เปลี่ยนสีข้อความเป็นสีดำ
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        fixedSize: Size(250, 50), // กำหนดขนาดที่แน่นอนให้ปุ่มทุกปุ่ม
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เมนูหลัก'),
        backgroundColor: Color.fromARGB(255, 255, 144, 235),
      ),
      body: Container(
        // เพิ่มรูปพื้นหลังให้เต็มจอ
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'), // เปลี่ยน path ตามที่คุณเก็บรูป
            fit: BoxFit.cover, // ให้รูปขยายเต็มขนาดหน้าจอ
          ),
        ),

        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // แสดงโลโก้
                  Image.asset(
                    'assets/logo.png', // ปรับตาม path ของโลโก้ที่เก็บใน assets
                    width: 350, // ปรับขนาดความกว้างของโลโก้
                    height: 350, // ปรับขนาดความสูงของโลโก้
                  ),
                  SizedBox(height: 30), // ระยะห่างระหว่างโลโก้และปุ่ม

                  _buildCustomButton(
                    context,
                    text: 'บันทึกข้อมูลสินค้า', // ข้อความภาษาไทย
                    color: Color.fromARGB(255, 255, 207, 255),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => addproduct()),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  _buildCustomButton(
                    context,
                    text: 'แสดงข้อมูลสินค้า', // ข้อความภาษาไทย
                    color: Color.fromARGB(255, 255, 207, 255),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => showproductgrid()),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  _buildCustomButton(
                    context,
                    text: 'ประเภทสินค้า', // ข้อความภาษาไทย
                    color: Color.fromARGB(255, 255, 207, 255),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowProductType()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
