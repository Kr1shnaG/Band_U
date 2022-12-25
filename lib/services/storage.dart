import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _token = 'token';
  static const _refreshToken = 'refresh_token';
  static const _loggedInName = '_loggedin_name';
  static const _loggedInImg = '_loggedin_img';

  static Future setToken(String token) async => await _storage.write(key: _token, value: token);

  static Future<String?> getToken() async => await _storage.read(key: _token);

  static Future deleteToken() async => await _storage.delete(key: _token);

  static Future setRefreshToken(String token) async => await _storage.write(key: _refreshToken, value: token);

  static Future<String?> getRefreshToken() async => await _storage.read(key: _refreshToken);

  static Future deleteRefreshToken() async => await _storage.delete(key: _refreshToken);

  static Future setLoggedInName(String name) async => await _storage.write(key: _loggedInName, value: name);

  static Future<String?> getLoggedInName() async => await _storage.read(key: _loggedInName);

  static Future deleteLoggedInName() async => await _storage.delete(key: _loggedInName);

  static Future setLoggedInImg(String img) async => await _storage.write(key: _loggedInImg, value: img);

  static Future<String?> getLoggedInImg() async => await _storage.read(key: _loggedInImg);

  static Future deleteLoggedInImg() async => await _storage.delete(key: _loggedInImg);
}
