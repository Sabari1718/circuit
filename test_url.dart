import 'package:http/http.dart' as http;

void main() async {
  final url1 = 'https://managelogin.jobes24x7.com/uploads/employee_docs/80a58893-def1-4dae-8ab2-1251a5ca1bd7.jpg';
  final url2 = 'https://managelogin.jobes24x7.com/api/uploads/employee_docs/80a58893-def1-4dae-8ab2-1251a5ca1bd7.jpg';
  
  final res1 = await http.head(Uri.parse(url1));
  print('URL1: ${res1.statusCode} ${res1.headers['content-type']}');
  
  final res2 = await http.head(Uri.parse(url2));
  print('URL2: ${res2.statusCode} ${res2.headers['content-type']}');
}
