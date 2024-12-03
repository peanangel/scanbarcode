import 'package:avatar_glow/avatar_glow.dart';
import 'package:scanbarcode/database/db_connect.dart';
import 'package:scanbarcode/models/dataModel.dart';
import 'package:scanbarcode/pages/infoProduct.dart';
import 'package:scanbarcode/tohex.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TextEditingController _searchController = TextEditingController();
  // stt
  var textSpeech = "CLICK ON MIC TO RECORD";
  SpeechToText speechToText = SpeechToText();
  var isListening = false;

  // Database
  final DatabaseService _databaseService = DatabaseService.instance;
  // Model
  Future<List<DataModel>?>? _searchResults;
  //ทำงานก่อนที่หน้าจอจะแสดง 
  @override
  void initState() {
    super.initState();
    checkMic();
    _searchController.addListener(_onSearchChanged); //ดูการเปลี่ยนแปลงของช่องค้นหา
    _searchResults = _databaseService.getProducts(); //ดึงข้อมูลประวัติสินค้ามาแสดง
  }
  //ตรวจสอบว่าแอปพลิเคชันสามารถเข้าถึงไมโครโฟนได้หรือไม่
  void checkMic() async {
    bool micAvailable = await speechToText.initialize();
    if (micAvailable) {
      print("Microphone Available");
    } else {
      print("User Denied the use of speech microphone");
    }
  }

  void _onSearchChanged() {
    setState(() {
      print('Search query: ${_searchController.text}');
      //เมื่อมีการค้นหา รายการประวัติจะถูกเปลี่ยน
      _searchResults = _databaseService.searchProduct(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged); //ลบ listener ใน initState
    _searchController.dispose(); //ยกเลิก searcontroller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: HexColor('1746A2'),
        title: Text("ประวัติ", style: TextStyle(color: Colors.white,
        fontFamily: "FC Defragment"
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 80,
              child: SearchBar(
                controller: _searchController,
                padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 16.0)),
                leading: const Icon(Icons.search),
                trailing: [
                  Tooltip(
                    message: 'mic',
                    child: AvatarGlow(
                      animate: isListening,
                      duration: const Duration(milliseconds: 2000),
                      glowColor: Colors.blue,
                      repeat: true,
                      child: IconButton(
                        icon: isListening
                            ? Icon(Icons.record_voice_over)
                            : Icon(Icons.mic),
                        onPressed: () async {
                          if (!isListening) {
                            bool micAvailable = await speechToText.initialize();
                            if (micAvailable) {
                              setState(() {
                                isListening = true;
                              });
                              speechToText.listen(
                                listenFor: Duration(seconds: 20),
                                onResult: (result) {
                                  setState(() {
                                    textSpeech = result.recognizedWords;
                                    _searchController.text = textSpeech;
                                    
                                    isListening = false;
                                    print("search ==> ${_searchController.text}");
                                  });
                                },
                              );
                            }
                          } else {
                            setState(() {
                              isListening = false;
                              speechToText.stop();
                              print("search ==> ${_searchController.text}");
                            });
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: productList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget productList() {
    return FutureBuilder<List<DataModel>?>(
      future: _searchResults,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.isEmpty) {
          return Center(child: Text('ไม่พบสินค้า',style: const TextStyle(
            // fontFamily: "ThaiSansNeue",
            fontSize:18,
            // fontWeight: FontWeight.bold,
            ),),);
        }

        return ListView.builder(
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            DataModel product = snapshot.data![index];
            return Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => infoProduct(product: product,barcodeNumber:""),
                    ),
                  );
                },
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    'http://csbarcode.thammadalok.com/AdminBarcode/${product.image}',
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      // Return a placeholder image or an error widget
                      return const Icon(Icons.broken_image);
                    },
                    height: 30,
                    width: 30,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(product.product_name,style: TextStyle(
                  // fontFamily: "FC Defragment",
                  fontSize:18,
                  fontWeight: FontWeight.bold
                  ),),
                
                subtitle: Text('ราคา ${product.price} บาท ${product.quantity}',style: TextStyle(
                  // fontFamily: "ThaiSansNeue",
                  fontSize:16,
                  // fontWeight: FontWeight.w600
                  ),),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    if (await confirm(context,
                    content: Text("ต้องการจะลบสินค้า?",style: TextStyle(
                      // fontFamily: "FC Defragment",
                      fontSize: 16
                      )),textOK: Text("ยืนยัน",style: TextStyle(
                        // fontFamily: "ThaiSansNeue",
                        fontSize:16,
                        // fontWeight: FontWeight.bold,
                        )),textCancel: Text("ยกเลิก",style: TextStyle(
                          // fontFamily: "ThaiSansNeue",
                          fontSize:16,
                          // fontWeight: FontWeight.bold,
                          )))) {
                      _databaseService.deleteProduct(product.product_id);
                      setState(() {
                        _searchResults = _databaseService.getProducts();
                      });
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
