import 'package:scanbarcode/database/db_connect.dart';
import 'package:scanbarcode/models/dataModel.dart';
import 'package:scanbarcode/pages/historyPage.dart';
import 'package:scanbarcode/pages/infoProduct.dart';
import 'package:scanbarcode/pages/multiProduct.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:vibration/vibration.dart';
import '../tohex.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toggle_switch/toggle_switch.dart';
// import 'package:flutter_vibrate/flutter_vibrate.dart';

class mainPageScanBarcode extends StatefulWidget {
  const mainPageScanBarcode({super.key});
  @override
  State<mainPageScanBarcode> createState() => _mainPageScanBarcodeState();
}

class _mainPageScanBarcodeState extends State<mainPageScanBarcode> {
  String _scanBarcodeResult = ''; //เก็บผลการสแกนเป็น String
  final DatabaseService _databaseService =
      DatabaseService.instance; //Database sqlite
  bool isVibart = true;
  int isScan = 0;
  TextEditingController _searchBarcode = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // IconButton(
                //   onPressed: () {
                //     _databaseService.dropDatabase();
                //     setState(() {});
                //   },
                //   icon: Icon(
                //     Icons.delete,
                //     size: 20,
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 80, 8.0, 8.0),
                  child: ToggleSwitch(
                    minWidth: 150.0, // Set the width of each button
                    cornerRadius: 20.0, // Set the corner radius of each button
                    initialLabelIndex: isScan,
                    totalSwitches: 2,
                    labels: ['สแกน', 'ป้อนเลขบาร์โค้ด'],
                    activeBgColors: [
                      [Colors.blue],
                      [Colors.blue]
                    ], // Active background colors for each toggle state
                    customTextStyles: [
                      TextStyle(
                          // fontSize: 18,
                          // fontFamily: 'ThaiSansNeue',
                          // color: Colors.white
                          ),
                      TextStyle(
                          // fontSize: 18,
                          // fontFamily: 'ThaiSansNeue',
                          // color: Colors.white
                          ),
                    ],
                    inactiveBgColor: Colors.grey, // Inactive background color
                    onToggle: (index) {
                      print('switched to: $index');

                      setState(() {
                        isScan = index!;
                      });
                    },
                  ),
                ),
                Container(
                  // color: Colors.blueGrey,
                  // margin: EdgeInsets.only(top: 40),
                  width: 400,
                  height: 300,
                  child: isScan == 0 ? ScanButton() : inputBarcodeNumber(),
                )

                // Text("Barcode result $_scanBarcodeResult"),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              backgroundColor: isVibart ? Colors.black : Colors.grey,
              onPressed: () {
                // Add your desired functionality here

                if (isVibart) {
                  isVibart = false;
                } else { //open vibrate
                  isVibart = true;
                  Vibration.vibrate(
                      duration: 1000); //ให้ทำการสั่นเป็นเวลา 1 วินาที
                }
                setState(() {});
              },
              child: Icon(
                Icons.vibration,
                color: Colors.white,
              ),
              shape: CircleBorder(),
            ),
            FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HistoryPage())); //ไปยังหน้า History
              },
              child: Icon(
                Icons.history,
                color: Colors.white,
              ),
              shape: CircleBorder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget inputBarcodeNumber() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 60, 16.0, 16.0),
      child: Column(
        children: [
          TextFormField(
              cursorColor: const Color.fromARGB(255, 135, 197, 228),
              controller: _searchBarcode,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                filled: true,
              ),
              onSaved: (String? value) {}),
          SizedBox(
            height: 12,
          ),
          Text(
            "ป้อนเลขบาร์โค้ด",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            width: 100,
            height: 70,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor('1746A2')),
                onPressed: () {
                  if (_searchBarcode.text.length == 13) { //เช็คจำนวน input
                    fetchProduct(_searchBarcode.text);
                    print(_searchBarcode.text);
                    _searchBarcode.clear();
                  } else {
                    print("กรุณาป้อนเลขบาร์โค้ด 13 หลัก");
                    _showMyDialog('ใส่ตัวเลขบาร์โค้ด 13 หลัก');
                  }
                },
                child: Text("ค้นหา",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ))),
          )
        ],
      ),
    );
  }

  Widget ScanButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 120, 16.0, 16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              scanBarcodeNormal(); //เรียก method เพื่อที่จะสแกนบาร์โค้ด
              // getProduct();
              // fetchProduct("4987176201980");
              // fetchProduct("8850086130351");
            },
            child: Icon(
              Icons.photo_camera,
              color: Colors.white,
              size: 50,
            ),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(20),
              backgroundColor: HexColor('1746A2'), 
              foregroundColor: Colors.white, 
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "กดเพื่อสแกนสินค้า",
            style: TextStyle(fontSize: 18
                // fontFamily: "FC Defragment",
                //  fontWeight: FontWeight.bold
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMyDialog(String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text, style: TextStyle()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void scanBarcodeNormal() async {
    String barcodeScanRes; //เก็บผลการสแกน
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          //ใช้ฟังก์ชัน เพื่อเปิดหน้าจอสแกนบาร์โค้ด
          "#ff6666", //กำหนดสีชองเส้นขอบในหน้าจอเป็นสีแดง
          "cancel", //ปุ่มยกเลิก
          true, //เปิดใช้งานแฟลช
          ScanMode.BARCODE); //กำหนดโหมดการสแกนเป็นบาร์โค้ด
    } on PlatformException {
      //หากเกิดข้อผิดพลาด
      barcodeScanRes =
          "Failed to get platform version"; //เก็บผลลัพธ์เป็น "Failed to get platform version"
    }
    setState(() {
      _scanBarcodeResult =
          barcodeScanRes; //แทนผลลัพธ์ที่สแกนได้ในตัวแปร _scanBarcodeResult
    });
    print("_scanBarcodeResult====$_scanBarcodeResult");

    if (_scanBarcodeResult != "-1") { //ถ้า user ไม่กด cancel
      print("isVibart $isVibart ");
      if (isVibart) //เช็ค vibrat ว่าได้เปิดสั่นไว้ไหม
        Vibration.vibrate(duration: 1000); //ให้ทำการสั่นเป็นเวลา 1 วินาที
      fetchProduct(_scanBarcodeResult); //เรียกใช้เมธอด fetchProduct()
    }
  }

  Future<DataModel?> fetchProduct(String barcode) async {
    //ประกาศฟังก์ชันคืนค่าเป็น Future<DataModel?> โดยมีพารามีเตอร์ String barcode
    print("======>$barcode");
    DataModel?
        product; //ประกาศตัวแปร product ไว้เก็บผลลัพธ์ที่เรียกจาก api ซึ่งอาจเป็นค่า null
    List<DataModel> products = []; //เก็บรายการสินค้า
    var data = {
      "barcode_id": barcode
    }; //สร้างแมป data ที่มีคีย์เป็น barcode_id และค่าคือบาร์โค้ดที่ได้รับมา
    var jsonData = jsonEncode(data); //แปลงข้อมูล  data เป็น json
    String url =
        "http://csbarcode.thammadalok.com/apibar/selectproductIdjson.php"; //url ของ api ที่จะเรียกใช้

    try {
      var response = await http.post(Uri.parse(url), body: jsonData, headers: {
        //เรียกใช้ HTTP POST request ส่งข้อมูลเป็น json
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        //สถานะจาก server เป็น 200 คือสามารถเรียกใช้ api ได้
        print('res =' + response.body); //นำผลลัพธ์มาแสดงผล
        if (response.body.isEmpty) {
          //ถ้าไม่มีผลลัพธ์กลับมาคือไม่มีข้อมูลของสินค้าอยู่ในฐานข้อมูล
          product = null; //ให้ product เป็นค่า null
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  infoProduct(product: product, barcodeNumber: barcode),
            ),
          );
        } else {
          //response body ไม่ใช่ค่า null
          var parsed = json.decode(response.body.trim()); //แปลงข้อมูล json
          // print('in if two');
          // print(parsed);
          // print("length ${parsed.length}");
          //********วน for loop if parsed > 1 */
          for (var item in parsed) {
            print("thiss in for");
            product = DataModel.fromJson(item);
            print("product = DataModel.fromJson(item);");
            print('Processed item $item: ${product.barcode_id}');

            _databaseService.addProduct1(product);
            if (parsed.length > 1) {
              products.add(product);
            }
          }
          if (parsed.length > 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    multiProduct(products: products, barcodeNumber: barcode),
              ),
            );
            print("go to multi");
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    infoProduct(product: product, barcodeNumber: barcode),
              ),
            );
          }
          setState(() {});
        }
      } else {
        print(response.statusCode);
      }
      print("====>" + response.statusCode.toString());
      return product;
    } catch (e) {
      print('Error ${e.toString()}');
      if (e.toString().contains(
          "type '_Map<String, dynamic>' is not a subtype of type 'Iterable<dynamic>'")) {
        _showMyDialog('สแกนบาร์โค้ด/ใส่เลขบาร์โค้ด');
      } else {
        _showMyDialog(
          'โปรดเชื่อมต่ออินเตอร์เน็ต',
        );
      }
    }
    return null;
  }
}
