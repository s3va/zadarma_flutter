import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

Future<String> getJSStringParam(String method, String param) async {
  print("^^^^^^^^^^^ $method ^^^ $param ^^^^^^^");
  final EncryptedSharedPreferences eShPr = EncryptedSharedPreferences();

  String _myInd = await eShPr.getString('myInd');
  print("++++++!!+++------+++++++ myInd: $_myInd ++++++++++++-----++++++");
  String _mySec = await eShPr.getString('mySec$_myInd');
  print("++++!!+++++------+++++++ mySec$_myInd $_mySec +++++++++++-----++++++");
  String _myKey = await eShPr.getString('myKey$_myInd');
  print("++++!!+++++----+++++++++ myKey$_myInd $_myKey +++++++++++-----++++++");

  var bsec = utf8.encode(_mySec);
  var hmac = Hmac(sha1, bsec);
  var md = md5.convert(utf8.encode("$param"));
  var dgist = hmac.convert(utf8.encode("$method$param$md"));
  var b64dgist = base64.encode(utf8.encode(dgist.toString()));
  print("_ Digest as bytes: ${dgist.bytes}");
  print("_ Digest as hex string: $dgist");
  print("_ Base64: $b64dgist");

  HttpClient httpClient = new HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 15);
  httpClient.idleTimeout = const Duration(seconds: 15);
  print("https://api.zadarma.com$method?$param");
  HttpClientRequest request = await httpClient.getUrl(Uri.parse("https://api.zadarma.com$method?$param")).timeout(const Duration(seconds: 15));

  request.headers.add("Authorization", "$_myKey:$b64dgist", preserveHeaderCase: true);
  HttpClientResponse response = await request.close().timeout(const Duration(seconds: 15));

  String reply = await response.transform(utf8.decoder).join();
  print(reply);
  httpClient.close();

  print("_ @@@headers@@@@ ${response.headers}");
  print("_ @@@statusCode@@@@ ${response.statusCode}");
  print("_ @@@@reasonPhrase@@@ ${response.reasonPhrase}");
  print("_ @@@@reply@@@ $reply");
  return reply;
}
