import 'dart:math';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';

class PrinterService{
  bool connected=false;
  List availableBluetoothDevices = [];
  int batteryLevel=0;

  PrinterService();

  bool getConnectedState(){
    return connected;
  }

  List getAvailableDevices(){
    return availableBluetoothDevices;
  }

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    availableBluetoothDevices = bluetooths!;
  }

  Future<bool> setConnect(String mac) async {
    final String? result = await BluetoothThermalPrinter.connect(mac);
    if (result == "true") {
      connected = true;
      return connected;
    }
    connected = false;
    return connected;
  }

  Future<String?> getConnectionStatus() async {
    final String? result = await BluetoothThermalPrinter.connectionStatus;
    return result;
  }

  Future<void> getPrinterBatteryLevel() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      batteryLevel = (await BluetoothThermalPrinter.getBatteryLevel)!;
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<void> print() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getPrint();
      await BluetoothThermalPrinter.writeBytes(bytes);
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTicket();
      await BluetoothThermalPrinter.writeBytes(bytes);
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<void> printGraphics() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getGraphics();
      await BluetoothThermalPrinter.writeBytes(bytes);
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<void> printImage() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getImage();
      await BluetoothThermalPrinter.writeBytes(bytes);
    } else {
      //Hadnle Not Connected Senario
    }
  }


  Future<List<int>> getPrint() async {

    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    bytes += generator.feed(1);
    bytes += generator.hr(ch: '-', linesAfter: 0);
    bytes += generator.text( "Impresion de texto de prueba", styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr(ch: '-', linesAfter: 0);
    bytes += generator.feed(4);
    return bytes;
  }

  Future<List<int>> getTicket() async {

    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    var rng = Random();
    int sum=0;
    int randomInt;

    final ByteData data = await rootBundle.load('assets/images/logo.png');
    final Uint8List byteses = data.buffer.asUint8List();
    var image = decodeImage(byteses);
    bytes += generator.image(image!);

    bytes += generator.text( " Estado de Mexico, Mexico", styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('+52 5543522237', styles: const PosStyles(align: PosAlign.center));

    bytes += generator.feed(1);
    bytes += generator.text('Cliente #', styles: const PosStyles(align: PosAlign.left));
    sum+=rng.nextInt(1000);
    bytes += generator.row([
      PosColumn(
          text: 'Producto 1',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "$sum  ",
          width: 7,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    randomInt=rng.nextInt(1000);
    sum+=randomInt;
    bytes += generator.row([
      PosColumn(
          text: 'Producto 2',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "$randomInt  ",
          width: 7,
          styles: const PosStyles(
              align: PosAlign.right,
              bold: true,
              height: PosTextSize.size1
          )),
    ]);
    randomInt=rng.nextInt(1000);
    sum+=randomInt;
    bytes += generator.row([
      PosColumn(
          text: 'Producto 3',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "$randomInt  ",
          width: 7,
          styles: const PosStyles(
              align: PosAlign.right,
              bold: true
          )),
    ]);

    bytes += generator.row([
      PosColumn(
          text: 'Total',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "$sum  ",
          width: 7,
          styles: const PosStyles(
              align: PosAlign.right,
              bold: true,
              height: PosTextSize.size3
          )),
    ]);

    bytes += generator.feed(4);
    bytes += generator.hr(ch: '-', linesAfter: 0);
    bytes += generator.text('Firma',styles: const PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.feed(1);
    bytes += generator.text("${DateFormat.yMd().format(DateTime.now())} ${DateFormat.jm().format(DateTime.now())}",
        styles: const PosStyles(align: PosAlign.center), linesAfter: 0);
    bytes += generator.feed(5);

    return bytes;
  }

  Future<List<int>> getGraphics() async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    bytes += generator.qrcode('https://bluicesoftware.com/');

    bytes += generator.hr();

    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    bytes += generator.feed(3);//bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> getImage() async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    final ByteData data = await rootBundle.load('assets/images/logo.png');
    final Uint8List byteses = data.buffer.asUint8List();
    var image = decodeImage(byteses);
    bytes += generator.image(image!);

    bytes += generator.feed(3);

    return bytes;
  }
}