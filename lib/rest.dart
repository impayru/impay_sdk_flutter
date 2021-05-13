import 'package:http/http.dart' as http;
import 'dart:convert' show json;

const SERVER_IP = 'https://api.impay.ru';

class Rest {

  static Future? getToken(int partnerId) async {
    try {
      var res = await http.post(
          Uri.parse("$SERVER_IP/v1/sdk/token"),
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: {
            "ID": partnerId.toString()
          }
      );
      if (res.statusCode == 200) {
        var r = json.decode(res.body);
        if (r['status'] == 1) {
          return r;
        }
      }
    } catch(e) {
      print(e);
    }
    return null;
  }

}