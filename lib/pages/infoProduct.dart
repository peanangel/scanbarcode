import 'package:scanbarcode/models/dataModel.dart';
import 'package:scanbarcode/pages/ttsmt.dart';
import 'package:scanbarcode/tohex.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class infoProduct extends StatefulWidget {
  final DataModel? product;
  final String barcodeNumber;
  // const infoProduct(required DataModel product, {Key? key, this.product, required this.barcodeNumber}) : super(key: key);
  const infoProduct({
    Key? key,
    this.product,
    required this.barcodeNumber,
  }) : super(key: key);
  @override
  State<infoProduct> createState() => _InfoProductState(product, barcodeNumber);
}

class _InfoProductState extends State<infoProduct> {
  DataModel? product;
  var productCode = 'None';
  TextToSpeech tts = TextToSpeech();
  //ตัวแปรเช็คว่ากำลังแสดงผลเป็นเสียงอยู่หรือไม่ ให้ค่าเริ่มต้นเป็น false
  bool isSpeaking = false;
  //เก็บประโยคที่แสดงผลล่าสุด
  String? currentlySpeakingText;
  String barcodeNumber;
  _InfoProductState(DataModel? product, this.barcodeNumber) {
    //รับค่า product มาแทนใน this.product
    this.product = product;
    this.barcodeNumber = barcodeNumber;
    print("info page=========>>${product?.barcode_id}");
    print("synonym page=========>>${product?.synonyms}");
    print("this.barcodeNumber=========>>${this.barcodeNumber}");
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: HexColor('1746A2'),
        title: Text("ข้อมูลสินค้า",
            style: TextStyle(
                color: Colors.white,
                // fontFamily: "FC Defragment",
                fontSize: 20)),
        actions: product == null
            ? [
                IconButton(
                  onPressed: () async {
                    await tts.speak("ไม่พบสินค้า");
                  },
                  icon: Icon(Icons.volume_up),
                  color: Colors.white,
                )
              ]
            : null,
      ),
      body: Container(child: (product == null) ? donothaveinfo() : infoall()),
    );
  }

  //widget ที่จะแสดงเมื่อ product ที่สแกนมาได้ไม่มีอยู่ในฐานข้อมูล หรือมีข้อผิดพลาดขณะสแกน คือ product ที่รับมามีค่าเป็น null
  Widget donothaveinfo() {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image(
                  image: AssetImage('assets/no-results.png'),
                  height: 100,
                  width: 100,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("เลขบาร์โค้ด : ${this.barcodeNumber}",style: TextStyle(
                  // fontFamily: "FC Defragment",
                  fontSize:14),),
              ),
              Text(
                'ไม่พบสินค้า',
                style: TextStyle(
                  // fontFamily: "FC Defragment",
                 fontSize: 20),
              )
            ],
          ),
        ),
      ),
    );
  }

//เปลี่ยน format ของวันที่ที่จะนำไปแสดง
  String formatDate(String dateStr) {
    try {
      print("date==>$dateStr");
      //แปลง String ให้เป็น DateTime
      DateTime date = DateTime.parse(dateStr);
      //เปลี่ยน format ของ DateTime ให้เป็น 'dd-MM-yyyy'
      String formattedDate = DateFormat('dd-MM-yyyy').format(date);
      return formattedDate;
    } catch (e) {
      print("Error parsing date");
      return dateStr; // If parsing fails, return the original string
    }
  }

  //widget แสดงรายละเอียดสินค้า
  Widget infoall() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: 50,
              alignment: Alignment.bottomRight,
              child: IconButton(
                onPressed: () async {
                  if (isSpeaking) {
                    await tts.stop();
                    setState(() {
                      isSpeaking = false;
                    });
                  } else {
                    String text = _generateProductText(product);
                    await tts.speak(text);
                    setState(() {
                      isSpeaking = true;
                      currentlySpeakingText = text;
                    });
                  }
                },
                icon: Icon(isSpeaking ? Icons.volume_up : Icons.volume_off),
              ),
            ),
            Center(
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    'http://csbarcode.thammadalok.com/AdminBarcode/${product?.image}',
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      // Return a placeholder image or an error widget
                      return const Icon(Icons.broken_image);
                    },
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: barcodeNumber != "" ? Text("เลขบาร์โค้ด : $barcodeNumber"): null,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product!.product_name.isNotEmpty)
                    info("ชื่อ", product!.product_name),
                  info("ราคา", "${product!.price.toString()} บาท"),
                  if (product!.quantity.isNotEmpty)
                    info("ปริมาณ", product!.quantity),
                  if (product!.expirationDate != "0000-00-00")
                    info("วันหมดอายุ", formatDate(product!.expirationDate)),
                  if (product!.productionDate != "0000-00-00")
                    info("วันที่ผลิต", formatDate(product!.productionDate)),
                  if (product!.type.isNotEmpty) info("ประเภท", product!.type),
                  if (product!.ingredient.isNotEmpty)
                    info("ส่วนประกอบ", product!.ingredient),
                  if (product!.preserve.isNotEmpty)
                    info("วิธีเก็บรักษา", product!.preserve),
                  if (product!.precautions.isNotEmpty)
                    info("ข้อควรระวัง", product!.precautions),
                  if (product!.direction.isNotEmpty)
                    info("วิธีใช้", product!.direction),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget info(String title, String info) {
    bool showSuffixIcon = false;
    print("before try");
    if (title == "วันหมดอายุ") {
      print("วันหมดอายุ");
      try {
        // DateTime infoDate = DateTime.parse(info);
        DateTime infoDate = DateFormat('dd-MM-yyyy').parseStrict(info);
        print("---${DateTime.now()}");
        if (infoDate.isBefore(DateTime.now())) {
          print("in if");
          showSuffixIcon = true;
        }
        print("showSuffixIcon$showSuffixIcon");
      } catch (e) {
        print(e);
      }
    }
    return GestureDetector(
      onTap: () {
        if (isSpeaking && currentlySpeakingText == info) {
          tts.stop();
          setState(() {
            isSpeaking = false;
            currentlySpeakingText = null;
          });
        } else {
          tts.stop();
          tts.speak(info);
          setState(() {
            isSpeaking = true;
            currentlySpeakingText = info;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          enabled: false,
          initialValue: info,
          style: TextStyle(
              color: Colors.black,
              // fontFamily: "ThaiSansNeue",
              fontSize: 16,
              // fontWeight: FontWeight.w600
              ),

          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            labelText: title,
            labelStyle: TextStyle(
              color: Colors.black,
              fontSize: 22, // Set the desired font size for the label
              fontWeight: FontWeight.bold,
              // fontFamily: "FC Defragment",
            ),
            suffixIcon: showSuffixIcon
                ? IconButton(
                    icon: Icon(Icons.warning_amber_rounded, color: Colors.red),
                    onPressed: () {},
                  )
                : null,
          ),
        ),
      ),
    );
  }

  String _generateProductText(DataModel? product) {
    if (product == null) return '';
    return [
      product.product_name,
      "ราคา ${product.price} บาท",
      if (product.quantity.isNotEmpty) "ปริมาณ ${product.quantity}",
      if (product.expirationDate != "0000-00-00")
        "วันหมดอายุ ${formatDate(product.expirationDate)}",
      // if (product.productionDate != "0000-00-00")
      //   "วันที่ผลิต ${formatDate(product.productionDate)}",
      // if (product.type.isNotEmpty) "ประเภท ${product.type}",
      // if (product.ingredient.isNotEmpty) "ส่วนประกอบ ${product.ingredient}",
      // if (product.preserve.isNotEmpty) "วิธีเก็บรักษา ${product.preserve}",
      // if (product.precautions.isNotEmpty) "ข้อควรระวัง ${product.precautions}",
      // if (product.direction.isNotEmpty) "วิธีใช้ ${product.direction}",
    ].join(', ');
  }
}
