import 'package:demo_porable_printer/printer_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List _devicesList = [];

  bool connected = false;

  PrinterService printerService = PrinterService();

  int batteryLevel=0;

  String printerName='';

  bool printerConnection=false;

  void searchDevices(){
    printerService.getBluetooth().then((value) {
      setState(() {
        _devicesList = printerService.getAvailableDevices();
      });
      if(_devicesList.isEmpty){
        showSnackBar('No se encontraron dispositivos');
      }
    });
  }

  void showSnackBar(String value){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
        margin: const EdgeInsets.all(50),
        elevation: 1,
        duration: const Duration(milliseconds: 800),
        backgroundColor: const Color(0xFF08919C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void printerConnect(int index)async{
    String select = _devicesList[index];
    List list = select.split("#");
    String mac = list[1];
    printerService.setConnect(mac).then((value){
      setState(() {
        connected = printerService.getConnectedState();
        printerName= select.split('#')[0];
      });
    });
    printerService.getPrinterBatteryLevel().then((value) {
      setState(() {
        batteryLevel=printerService.batteryLevel;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    var widthScreen = MediaQuery.of(context).size.width * 0.9;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF00398f),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 0,
          title: const Text('Demo impresora bluetooth'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: widthScreen,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 17
                      ),
                      backgroundColor: const Color(0xFF00398f),
                    ),
                    onPressed: ()=> searchDevices(),
                    child: const Text('Buscar dispositivos')
                )
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black12,
                  width: 1,
                ),
              ),
              height: 200,
              child: ListView.builder(
                itemCount: _devicesList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      printerConnect(index);
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _devicesList[index].toString().split('#')[0],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _devicesList[index].toString().split('#')[0] == printerName ? Colors.blue : Colors.black
                          ),
                        ),
                        Text(_devicesList[index].toString().split('#')[1], style: const TextStyle(fontWeight: FontWeight.w300),)
                      ],
                    ),
                    subtitle: Text(
                        _devicesList[index].toString().split('#')[0] == printerName ? 'Conectado' : "Clic para conectar"
                    ),
                    //trailing: Text(batteryLevel!=0 ? '${batteryLevel.toString()}%' : ''),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
                width: widthScreen,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 17
                      ),
                      backgroundColor: const Color(0xFF08919C),
                    ),
                    onPressed:  connected ? ()=> printerService.print() : null,
                    child: const Text('Texto')
                )
            ),
            SizedBox(
                width: widthScreen,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 17
                      ),
                      backgroundColor: const Color(0xFF08919C),
                    ),
                    onPressed: connected ? ()=> printerService.printTicket() : null,
                    child: const Text('Ticket')
                )
            ),
            SizedBox(
                width: widthScreen,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 17
                      ),
                      backgroundColor: const Color(0xFF08919C),
                    ),
                    onPressed:  connected ? ()=> printerService.printGraphics() : null,
                    child: const Text('Graficos')
                )
            ),
            SizedBox(
                width: widthScreen,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 17
                      ),
                      backgroundColor: const Color(0xFF08919C),
                    ),
                    onPressed: connected ? ()=> printerService.printImage() : null,
                    child: const Text('Imagen')
                )
            ),
            const Spacer()
          ],
        ),
      ),
    );
  }
}
