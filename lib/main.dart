import 'package:flutter/material.dart';
import 'package:inteli_rehab/app.dart';
import 'package:inteli_rehab/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}
