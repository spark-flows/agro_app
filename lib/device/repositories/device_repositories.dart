// coverage:ignore-file
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:agro_app/app/app.dart';
import 'package:agro_app/data/data.dart';
import 'package:agro_app/device/device.dart';
import 'package:agro_app/domain/domain.dart';

/// Repositories that communicate with the platform e.g. GPS
class DeviceRepository extends DomainRepository {
  /// initialize flutter secure storage
  final _flutterSecureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// initialize the hive box
  Future<void> init({bool isTest = false}) async {
    if (isTest) {
      Hive.init('HIVE_TEST');
      await Hive.openBox<dynamic>(StringConstants.appName);
    } else {
      await Hive.initFlutter();
      await Hive.openBox<dynamic>(StringConstants.appName);
    }
  }

  /// Returns the box in which the data is stored.
  Box _getBox() => Hive.box<dynamic>(StringConstants.appName);

  @override
  Future<void> clearData(dynamic key) async {
    await _getBox().delete(key);
  }

  /// Delete the box
  @override
  Future<void> deleteBox() async {
    try {
      await _getBox().clear();
    } catch (_) {}
  }

  /// returns stored string value
  @override
  String getStringValue(String key) {
    var box = _getBox();
    var defaultValue = '';
    if (key == DeviceConstants.localLang) {
      defaultValue = DataConstants.defaultLang;
    }
    var raw = box.get(key, defaultValue: defaultValue);
    return raw?.toString() ?? defaultValue;
  }

  /// store the data
  @override
  Future<void> saveValue(dynamic key, dynamic value) async {
    await _getBox().put(key, value);
  }

  /// return bool value
  @override
  bool getBoolValue(String key) {
    var raw = _getBox().get(key, defaultValue: false);
    if (raw is bool) return raw;
    if (raw is String) return raw.toLowerCase() == 'true';
    return false;
  }

  /// Get data from secure storage
  @override
  Future<String> getSecuredValue(String key) async {
    try {
      var value = await _flutterSecureStorage.read(key: key);
      if (value == null || value.isEmpty) {
        value = '';
      }
      return value;
    } catch (error) {
      return '';
    }
  }

  /// Save data in secure storage
  @override
  Future<void> saveValueSecurely(String key, String value) async {
    try {
      await _flutterSecureStorage.write(key: key, value: value);
    } catch (_) {}
  }

  /// Delete data from secure storage
  @override
  Future<void> deleteSecuredValue(String key) async {
    try {
      await _flutterSecureStorage.delete(key: key);
    } catch (_) {}
  }

  /// Delete all data from secure storage
  @override
  Future<void> deleteAllSecuredValues() async {
    try {
      await _flutterSecureStorage.deleteAll();
    } catch (_) {}
  }

  /// API to get the IP of the user
  @override
  Future<String> getIp() {
    throw UnimplementedError();
  }
}
