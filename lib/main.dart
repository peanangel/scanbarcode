// import 'package:barcodeprojectapp/pages/historyPage.dart';
// import 'package:barcodeprojectapp/pages/infoProduct.dart';
// import 'package:barcodeprojectapp/pages/loginPage.dart';
// import 'package:barcodeprojectapp/pages/profilePage.dart';
// import 'package:barcodeprojectapp/pages/settingPage.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'tohex.dart';
import 'package:scanbarcode/pages/mainPageScanBarcode.dart';
// import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iScanGo',
      // theme: ThemeData(
      // colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      // useMaterial3: true,
      // ),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 35, 72, 103)),
            textStyle: MaterialStateProperty.all<TextStyle>(
              TextStyle(
                  // fontFamily: "ThaiSansNeue",
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
      ),
      home: const MyHomePage(title: 'iScanGo',),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          backgroundColor: HexColor('1746A2'),
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/Barcode.png',
                  fit: BoxFit.contain,
                  height: 32,
                ),
              ),
              Text(widget.title, style: TextStyle(color: Colors.white,
              // fontFamily: 'FC Defragment'
              )),
            ],
          ),
          // actions: [
          //   IconButton(onPressed: (){}, icon: Icon(Icons.settings),color: Colors.white,)
          // ],
        ),
        body:
            // infoProduct()
            mainPageScanBarcode()
        //historyPage()
        // settingPage()
        // profile_page()
        // login_page()
        );
  }
}
