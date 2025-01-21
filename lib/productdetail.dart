import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ProductDetail extends StatefulWidget {
  final String productId;

  ProductDetail({required this.productId});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final databaseRef = FirebaseDatabase.instance.ref("products");
  Map<String, dynamic>? product;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  void fetchProductDetails() async {
    try {
      final snapshot = await databaseRef.child(widget.productId).get();
      if (snapshot.exists) {
        setState(() {
          product = Map<String, dynamic>.from(snapshot.value as Map);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching product details: $e");
    }
  }

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return "Invalid Date"; // เพิ่มการจัดการวันที่ผิดพลาด
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product?["name"] ?? "รายละเอียดสินค้า"),
        backgroundColor: Color.fromARGB(
            255, 255, 144, 235), // ใช้สีเดียวกับ AppBar หน้าอื่น ๆ
      ),
      body: Stack(
        children: [
          // เพิ่ม Stack เพื่อให้ภาพพื้นหลังครอบคลุมทั้งหน้าจอ
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpg'),
                fit: BoxFit.cover, // ทำให้ภาพครอบคลุมพื้นที่ทั้งหมด
              ),
            ),
          ),
          // เนื้อหาของหน้า
          isLoading
              ? Center(child: CircularProgressIndicator())
              : product == null
                  ? Center(child: Text("ไม่พบข้อมูลสินค้า"))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ชื่อสินค้า: ${product!["name"]}',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'ราคา: ${product!["price"]} บาท',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'หมวดหมู่: ${product!["category"]}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'วันที่ผลิต: ${product!["productionDate"] != null ? formatDate(product!["productionDate"]) : "ไม่มีข้อมูล"}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'รายละเอียด: ${product!["description"] ?? "ไม่มีรายละเอียด"}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }
}
