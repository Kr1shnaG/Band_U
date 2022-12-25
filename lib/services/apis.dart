import 'dart:convert';
import 'package:flutter_app/services/storage.dart';
import 'package:http/http.dart' as https;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Apis {
  String credentials = (dotenv.env['CLIENT_ID'] ?? '') +
      ':' +
      (dotenv.env['CLIENT_SECRET'] ?? '');
  Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);

  Future<String> getRefreshToken() async {
    var refreshToken = await https
        .post(Uri.parse('https://accounts.spotify.com/api/token'), body: {
      'grant_type': 'refresh_token',
      'refresh_token': await SecureStorage.getRefreshToken(),
    }, headers: {
      'Authorization': 'Basic ${stringToBase64Url.encode(credentials)}',
    });
    if (refreshToken.statusCode == 200) {
      var access_token = json.decode(refreshToken.body)['access_token'];
      return access_token;
    } else {
      return '';
    }
  }
}
