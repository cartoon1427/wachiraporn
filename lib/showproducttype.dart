import 'package:flutter/material.dart';
import 'showfiltertype.dart';
import 'productdetail.dart';

class ShowProductType extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {'name': 'Electronics', 'image': 'assets/electronics.png'},
    {'name': 'Clothing', 'image': 'assets/clothing.png'},
    {'name': 'Food', 'image': 'assets/food.png'},
    {'name': 'Books', 'image': 'assets/book.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ประเภทสินค้า'),
        backgroundColor: Color.fromARGB(255, 255, 144, 235),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'), // ใช้ภาพพื้นหลังเดียวกัน
            fit: BoxFit.cover, // ทำให้ภาพครอบคลุมพื้นที่ทั้งหมด
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 คอลัมน์
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowFilterType(
                        categoryName: categories[index]['name']!,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        categories[index]['image']!,
                        height: 200,
                      ),
                      SizedBox(height: 10),
                      Text(
                        categories[index]['name']!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
