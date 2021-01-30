import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:qrscan/qrscan.dart' as scanner;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My scanner',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scanner(),
    );
  }
}

class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  String barcode = '';

  Uint8List bytes = Uint8List(200);

  List<Map<String, dynamic>> additems = [];

  double totalAmount = 0;

  @override
  initState() {
    super.initState();
  }

  void showConfirmedDialog(BuildContext context) {
    Widget okButton = FlatButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text("okay"),
    );

    AlertDialog alert = AlertDialog(
      title: Icon(
        Icons.done,
        color: Colors.red,
        size: MediaQuery.of(context).size.width * 0.25,
      ),
      content: Text(
        "Payment Successful",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: <Widget>[
        okButton,
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void showPaymentdialog(BuildContext context) {
    Widget cancelbutton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget confirmbutton = FlatButton(
        onPressed: () {
          setState(() {
            additems.clear();
            totalAmount = 0;
          });
          Navigator.pop(context);
          showConfirmedDialog(context);
        },
        child: Text("confirm"));

    AlertDialog alert = AlertDialog(
      title: Text(
        "Confirm Payment?",
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.065,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        "Subtotal: $totalAmount",
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.05,
        ),
      ),
      actions: <Widget>[cancelbutton, confirmbutton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Barcode Scanner",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: Colors.white,
            onPressed: () => _scan(),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                child: ListView.builder(
                  itemCount: additems.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: IconButton(
                                icon: Icon(Icons.remove),
                                color: Colors.white,
                                onPressed: () {
                                  setState(() {
                                    additems.removeAt(index);
                                  });
                                }),
                          ),
                          title: Text(additems[index]["name"]),
                          trailing: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(additems[index]["price"].toString()),
                          ),
                        ),
                        Divider(),
                      ],
                    );
                  },
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: RaisedButton(
                      onPressed: () {
                        showPaymentdialog(context);
                      },
                      child: Text(
                        "Pay",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      elevation: 3.0,
                      splashColor: Colors.redAccent,
                      color: Colors.red,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "\$ ${totalAmount.toString()}",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.06),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future _scan() async {
    String barcode = await scanner.scan();

    print(barcode);
    setState(() {
      this.barcode = barcode;
      double price =
          double.parse(barcode.substring((barcode.indexOf(",") + 1)));
      this.totalAmount += price;
      String name = barcode.substring(0, barcode.indexOf(","));
      print("name is $name");
      print("price is $price");
      this.additems.add({"name": name, "price": price});
    });
  }
}
