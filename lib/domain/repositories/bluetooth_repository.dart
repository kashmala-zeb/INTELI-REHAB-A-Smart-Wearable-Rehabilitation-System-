import 'package:inteli_rehab/domain/entities/wearable.dart';

abstract class BluetoothRepository {
  Future<List<WearableDevice>> scanDevices();
}
