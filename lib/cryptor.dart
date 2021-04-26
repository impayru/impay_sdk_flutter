import 'dart:convert';
import 'package:crypton/crypton.dart';

class Cryptor {
  static Future<String> tokenize(String card, String srok, String cvv, String token) async {
    RSAPublicKey rsaKey = RSAPublicKey.fromPEM(token);
    return rsaKey.encrypt(json.encode({
      "number": card,
      "holder": '',
      "year": srok.substring(2, 4),
      "month": srok.substring(0, 2),
      "cvc": cvv
    }));
  }
}
