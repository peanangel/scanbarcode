import 'package:scanbarcode/models/dataModel.dart';
import 'package:scanbarcode/pages/infoProduct.dart';
import 'package:scanbarcode/pages/ttsmt.dart';
import 'package:scanbarcode/tohex.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class multiProduct extends StatefulWidget {
  final List<DataModel> products;
  final String barcodeNumber;
  const multiProduct(
      {Key? key, required this.products, required this.barcodeNumber})
      : super(key: key);

  State<multiProduct> createState() =>
      _multiProductState(products, barcodeNumber);
}

class _multiProductState extends State<multiProduct> {
  //เก็บ product list ที่รับมาจากหน้า main
  List<DataModel>? products;
  TextToSpeech tts = TextToSpeech();
  //เก็บข้อความที่จะนำไปแปลงเป็นเสียง
  String text = '';
  String barcodeNumber;
  //constructure รับ List<DataModel>
  _multiProductState(List<DataModel> products, this.barcodeNumber) {
    this.products = products;
    this.barcodeNumber = barcodeNumber;
    print('products multi page length ${products.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: HexColor('1746A2'),
        title: Text("ผลลัพธ์",
            style: TextStyle(color: Colors.white, 
            // fontFamily: "FC Defragment"
            )),
        //ปุ่มเปิดเสียง
        actions: [
          IconButton(
            onPressed: () {
              //แทนค่าจำนวนสินค้า
              int num = products?.length ?? 0;
              //ข้อความที่จะนำไปแปลงเป็นเสียง
              text =
                  'มีผลลัพธ์ทั้งหมด $num รายการ กดรายการสินค้าเพื่อดูรายละเอียด';
              //เรียกเพื่อแปลงข้อความเป็นเสียง
              tts.speak(text);
            },
            icon: Icon(Icons.volume_up),
            color: Colors.white,
          )
        ],
      ),
      body: productList(),
    );
  }

  Widget productList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        shrinkWrap: true, //ปรับขนาดความสูงของตัวเองตามจำนวนรายการที่มี
        itemCount: widget.products.length, //กำหนดจำนวนรายการ
        itemBuilder: (context, index) {
          DataModel product = widget.products[index]; //ดึงข้อมูลผลิตภัณฑ์ในแต่ละลำดับจาก widget.products มาเก็บไว้ในตัวแปร product
          String formattedDate = ""; //เก็บวันที่หมดอายุที่ถูกฟอร์แมตแล้ว
          //หาก expirationDate == "0000-00-00" แปลว่าไม่มีวันหมดอายุ จึงให้เป็นค่า ""
          if (product.expirationDate == "0000-00-00") {
            formattedDate = "";
          } else {
            //แปลง expirationDate จาก String เป็น DateTime
            DateTime expirationDate = DateTime.parse(product.expirationDate);
            //ถ้ามีวันหมดอายุให้เปลี่ยน format วันหมดอายุเป็น 'dd-MM-yyyy'
            formattedDate = DateFormat('dd-MM-yyyy').format(expirationDate);
          }
          return Card(
            shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(15.0)),
            child: ListTile(
              //หากกดที่แท็บสินค้าให้ไปที่หน้าข้อมูลสินค้า infoProduct เพื่อแสดงรายละเอียด
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => infoProduct(
                        product: product, barcodeNumber: barcodeNumber),
                  ),
                );
              },
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'http://csbarcode.thammadalok.com/AdminBarcode/${product.image}',
                  height: 30,
                  width: 30,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(product.product_name,style: TextStyle(
                // fontFamily: "FC Defragment",
                  fontSize:18,
                  fontWeight: FontWeight.bold),),
              subtitle: Text(
                  'ราคา ${product.price} บาท ${product.quantity}\n ${formattedDate}',style: TextStyle(
                    // fontFamily: "ThaiSansNeue",
                  fontSize:16,
                  // fontWeight: FontWeight.w600
                  ),),
              trailing: IconButton(
                icon: Icon(Icons.navigate_next),
                onPressed: () async {},
              ),
            ),
          );
        },
      ),
    );
  }
}
