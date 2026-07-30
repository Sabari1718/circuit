import 'package:http/http.dart' as http;
void main() async {
  final url1 = 'https://managelogin.jobes24x7.com/api/user_register/user/5319073341';
  final url2 = 'https://managelogin.jobes24x7.com/api/user_register/5319073341';
  final url3 = 'https://managelogin.jobes24x7.com/api/user-register/user/5319073341';
  
  for (var u in [url1, url2, url3]) {
    final res = await http.get(Uri.parse(u), headers: {'Content-Type': 'application/json'});
    print('$u -> Status: ${res.statusCode}, Body: ${res.body}');
  }
}
