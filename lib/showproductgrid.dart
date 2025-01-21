import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class showproductgrid extends StatefulWidget {
  @override
  State<showproductgrid> createState() => _ShowProductGridState();
}

class _ShowProductGridState extends State<showproductgrid> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref('products');
  List<Map<String, dynamic>> products = [];

  // ตัวแปรสำหรับเก็บส่วนลดที่เลือก
  String selectedDiscount = '10%'; // ค่าเริ่มต้น

  // ฟังก์ชันสำหรับดึงข้อมูลจาก Firebase
  Future<void> fetchProducts() async {
    try {
      final query = dbRef.orderByChild('price'); // เรียงสินค้าตามราคา
      final snapshot = await query.get();
      if (snapshot.exists) {
        List<Map<String, dynamic>> loadedProducts = [];
        snapshot.children.forEach((child) {
          Map<String, dynamic> product =
              Map<String, dynamic>.from(child.value as Map);
          product['key'] = child.key;
          loadedProducts.add(product);
        });

        // จัดเรียงสินค้าตามราคาจากน้อยไปมาก
        loadedProducts.sort((a, b) => a['price'].compareTo(b['price']));

        setState(() {
          products = loadedProducts;
        });
      } else {
        print("ไม่พบข้อมูลสินค้าในฐานข้อมูล");
      }
    } catch (e) {
      print("เกิดข้อผิดพลาด: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts(); // ดึงข้อมูลสินค้าเมื่อเริ่มต้น
  }

  // ฟังก์ชันแปลงวันที่ให้อยู่ในรูปแบบที่อ่านง่าย
  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  // ฟังก์ชันที่ใช้ลบ
  void deleteProduct(String key, BuildContext context) {
    dbRef.child(key).remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบสินค้าเรียบร้อย')),
      );
      fetchProducts();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }

  // ฟังก์ชันถามยืนยันก่อนลบ
  void showDeleteConfirmationDialog(String key, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการปิด Dialog โดยการแตะนอกพื้นที่
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('ยืนยันการลบ'),
          content: Text('คุณแน่ใจว่าต้องการลบสินค้านี้ใช่หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ปิด Dialog
              },
              child: Text('ไม่ลบ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ปิด Dialog
                deleteProduct(key, context); // เรียกฟังก์ชันลบข้อมูล
              },
              child: Text('ลบ', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันแสดง Dialog สำหรับแก้ไขข้อมูลสินค้า
  void showEditProductDialog(Map<String, dynamic> product) {
    // ตัวอย่างประกาศตัวแปรเพื่อเก็บค่าข้อมูลเดิมที่เก็บไว้ในฐานข้อมูล ดึงมาเก็บไว้ตัวแปรที่กำหนด
    TextEditingController nameController =
        TextEditingController(text: product['name']);
    TextEditingController descriptionController =
        TextEditingController(text: product['description']);
    TextEditingController categoryController =
        TextEditingController(text: product['category']);
    TextEditingController quantityController =
        TextEditingController(text: product['quantity'].toString());
    TextEditingController priceController =
        TextEditingController(text: product['price'].toString());
    TextEditingController productionDateController =
        TextEditingController(text: product['productionDate']);
    TextEditingController selecteddiscountController =
        TextEditingController(text: product['discount']);

    // ฟังก์ชันสำหรับแสดง DatePicker
    Future<void> _selectDate(BuildContext context) async {
      final DateTime? selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );
      if (selectedDate != null) {
        // แปลงวันที่ที่เลือกเป็นรูปแบบที่ต้องการ
        String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
        productionDateController.text = formattedDate;
      }
    }

    // กำหนดรายการประเภทสินค้าที่สามารถเลือกได้
    List<String> categories = ['Electronics', 'Clothing', 'Food', 'Books'];

    // สร้าง Dialog เพื่อแสดงข้อมูลเก่าและให้กรอกข้อมูลใหม่เพื่อแก้ไข
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('แก้ไขข้อมูลสินค้า'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController, // ดึงข้อมูลชื่อเก่ามาแสดงผล
                  decoration: InputDecoration(labelText: 'ชื่อสินค้า'),
                ),
                TextField(
                  controller:
                      descriptionController, // ดึงข้อมูลรายละเอียดเก่ามาแสดงผล
                  decoration: InputDecoration(labelText: 'รายละเอียด'),
                ),
                // เปลี่ยนจาก TextField เป็น Dropdown สำหรับเลือกประเภทสินค้า
                DropdownButtonFormField<String>(
                  value: product['category'], // ค่าเริ่มต้นจากข้อมูลเดิม
                  onChanged: (value) {
                    setState(() {
                      categoryController.text =
                          value!; // อัปเดตค่าเมื่อเลือกประเภทใหม่
                    });
                  },
                  items:
                      categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'ประเภทสินค้า'),
                ),
                TextField(
                  controller: quantityController, // ดึงข้อมูลจำนวนเก่ามาแสดงผล
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'จำนวน'),
                ),
                TextField(
                  controller:
                      priceController, // ดึงข้อมูลราคาสินค้าเก่ามาแสดงผล
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'ราคา'),
                ),
                GestureDetector(
                  onTap: () {
                    _selectDate(context); // เรียกฟังก์ชันเลือกวันที่
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller:
                          productionDateController, // ดึงข้อมูลวันที่ผลิต
                      decoration: InputDecoration(labelText: 'วันที่ผลิต'),
                    ),
                  ),
                ),
                // ใช้ DropdownButtonFormField สำหรับเลือกส่วนลด
                DropdownButtonFormField<String>(
                  value: selectedDiscount, // ใช้ค่าที่เก็บไว้ในตัวแปร
                  onChanged: (value) {
                    setState(() {
                      selectedDiscount = value!; // อัปเดตค่าหลังเลือก
                    });
                  },
                  items: <String>['10%', 'ไม่มีส่วนลด']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'ส่วนลด'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ปิด Dialog
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                // เตรียมข้อมูลที่แก้ไขแล้ว
                Map<String, dynamic> updatedData = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'category': categoryController.text, // ใช้ค่าจาก Dropdown
                  'quantity': int.parse(quantityController.text),
                  'price': int.parse(priceController.text),
                  'productionDate': productionDateController.text,
                  'discount': selectedDiscount, // ใช้ค่าที่เลือกจาก Dropdown
                };

                // ทำการอัปเดตข้อมูลใน Firebase
                dbRef.child(product['key']).update(updatedData).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('แก้ไขข้อมูลเรียบร้อย')));
                  fetchProducts(); // เรียกใช้ฟังก์ชันเพื่อโหลดข้อมูลใหม่เพื่อแสดงผลหลังการแก้ไข
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
                  );
                });

                Navigator.of(dialogContext).pop(); // ปิด Dialog
              },
              child: Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แสดงข้อมูลสินค้า'),
        backgroundColor: Color.fromARGB(255, 255, 144, 235),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'), // เพิ่มภาพพื้นหลัง
            fit: BoxFit.cover,
          ),
        ),
        child: products.isEmpty
            ? const Center(
                child: CircularProgressIndicator()) // กำลังโหลดข้อมูล
            : GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // จำนวนคอลัมน์ใน GridView
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 3 / 2, // อัตราส่วนของสินค้า
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('รายละเอียด: ${product['description']}'),
                              Text('ประเภทสินค้า: ${product['category']}'),
                              Text('จำนวน: ${product['quantity']}'),
                              Text('ราคา: ${product['price']} บาท'),
                              Text('วันที่ผลิต: ${product['productionDate']}'),
                              Text('ส่วนลด: ${product['discount']}'),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Align(
                              alignment: Alignment
                                  .bottomRight, // จัดตำแหน่งที่มุมขวาล่าง
                              child: SizedBox(
                                width: 50,
                                height: 50, // ให้มีขนาดเป็นวงกลม
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red[50], // พื้นหลังสีแดงอ่อน
                                    shape: BoxShape.circle, // รูปทรงวงกลม
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      showEditProductDialog(
                                          product); // แสดงหน้าจอแก้ไข
                                    },
                                    icon: Icon(Icons.edit),
                                    color: Color.fromARGB(
                                        255, 11, 0, 9), // สีของไอคอน
                                    iconSize: 30, // ขนาดของไอคอน
                                    tooltip: 'แก้ไขสินค้า',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment:
                              Alignment.bottomRight, // จัดตำแหน่งที่มุมขวาล่าง
                          child: SizedBox(
                            width: 50,
                            height: 50, // ให้มีขนาดเป็นวงกลม
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red[50], // พื้นหลังสีแดงอ่อน
                                shape: BoxShape.circle, // รูปทรงวงกลม
                              ),
                              child: IconButton(
                                onPressed: () {
                                  showDeleteConfirmationDialog(
                                      product['key'], context); // ยืนยันการลบ
                                },
                                icon: Icon(Icons.delete),
                                color: const Color.fromARGB(
                                    255, 230, 34, 20), // สีของไอคอน
                                iconSize: 30, // ขนาดของไอคอน
                                tooltip: 'ลบสินค้า',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
