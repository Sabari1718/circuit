import 'package:http/http.dart' as http;
void main() async {
  final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTQyLCJlbWFpbCI6InNhYmFyaXNod2FyYW4xNzE4QGdtYWlsLmNvbSIsInBob25lX251bWJlciI6IjgwMTIxMDc2MjYiLCJ1c2VyX21haW5faWQiOiIyMTQ2NjEwMjEzIiwidmlydHVhbF9pZCI6IjIyODM5ODMwNjMzNzE3IiwidXNlcl9uYW1lIjoic2FiYXJpaSIsInVzZXJfdHlwZSI6Imd1ZXN0IiwiaWF0IjoxNzg3NzM2ODIyLCJleHAiOjE3ODc4MjMyMjJ9.uLwVavJIfUBclamQ4-gggmT434W6H4nmGH_sZ-Jea1Q';
  
  final r2 = await http.get(Uri.parse('https://user.jobes24x7.com/api/grid-card/2761846435'), headers: {'Authorization': 'Bearer ' + token, 'Accept': 'application/json'});
  print('user 2761846435: ' + r2.statusCode.toString() + ' - ' + r2.body);
}
