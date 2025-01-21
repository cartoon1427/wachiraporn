import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'productdetail.dart';

class ShowFilterType extends StatefulWidget {
  final String categoryName;

  ShowFilterType({required this.categoryName});

  @override
  _ShowFilterTypeState createState() => _ShowFilterTypeState();
}

class _ShowFilterTypeState extends State<ShowFilterType> {
  final databaseRef = FirebaseDatabase.instance.ref("products");
  List<Map<String, dynamic>> filteredProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFilteredProducts();
  }

  void fetchFilteredProducts() async {
    databaseRef.once().then((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final List<Map<String, dynamic>> products = [];
        data.forEach((key, value) {
          if (value["category"] == widget.categoryName) {
            products.add({
              "id": key, // เพิ่ม id ของสินค้า
              "name": value["name"],
              "price": value["price"],
              "category": value["category"],
              "description": value["description"],
              "productionDate": value["productionDate"], // วันที่ผลิต
              "quantity": value["quantity"], // จำนวนสินค้า
            });
          }
        });

        setState(() {
          filteredProducts = products;
          isLoading = false;
        });
      } else {
        setState(() {
          filteredProducts = [];
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แสดงข้อมูลสินค้า: ${widget.categoryName}'),
        backgroundColor: Color.fromARGB(255, 255, 144, 235),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'), // ใช้ภาพพื้นหลังเดียวกัน
            fit: BoxFit.cover, // ทำให้ภาพครอบคลุมพื้นที่ทั้งหมด
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : filteredProducts.isEmpty
                ? Center(
                    child: Text(
                      'ไม่มีสินค้าประเภท ${widget.categoryName}',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            product["name"],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('รายละเอียด: ${product["description"]}'),
                                  Text(
                                      'วันที่ผลิต: ${product["productionDate"]}'),
                                  Text('ประเภท: ${product["category"]}'),
                                  Text('จำนวน: ${product["quantity"]}'),
                                ],
                              ),
                              SizedBox(width: 10),
                              Text(
                                'ราคา: ${product["price"]} บาท',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(
                                      255, 212, 27, 30), // เน้นราคาให้เด่น
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // เมื่อคลิกที่รายการสินค้าให้ไปหน้า ProductDetail
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetail(
                                  productId: product["id"], // ส่ง productId
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
