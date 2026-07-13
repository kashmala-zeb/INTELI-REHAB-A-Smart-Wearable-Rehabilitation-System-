import 'package:inteli_rehab/domain/entities/wearable.dart';
import 'package:inteli_rehab/domain/repositories/bluetooth_repository.dart';

class BluetoothRepositoryImpl implements BluetoothRepository {
  @override
  Future<List<WearableDevice>> scanDevices() async => [];
}
