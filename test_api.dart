import 'package:http/http.dart' as http;
void main() async {
  final url = 'https://managelogin.jobes24x7.com/api/user_register/user/9508383027';
  final res = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json'});
  print('Status: ${res.statusCode}');
  print('Body: ${res.body}');
}
