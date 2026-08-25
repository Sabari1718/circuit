import 'package:http/http.dart' as http;
void main() async {
  final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTQyLCJlbWFpbCI6InNhYmFyaXNod2FyYW4xNzE4QGdtYWlsLmNvbSIsInBob25lX251bWJlciI6IjgwMTIxMDc2MjYiLCJ1c2VyX21haW5faWQiOiIyMTQ2NjEwMjEzIiwidmlydHVhbF9pZCI6IjIyODM5ODMwNjMzNzE3IiwidXNlcl9uYW1lIjoic2FiYXJpaSIsInVzZXJfdHlwZSI6Imd1ZXN0IiwiaWF0IjoxNzg3NzM2ODIyLCJleHAiOjE3ODc4MjMyMjJ9.uLwVavJIfUBclamQ4-gggmT434W6H4nmGH_sZ-Jea1Q';
  
  final r2 = await http.get(Uri.parse('https://managelogin.jobes24x7.com/api/grid-card/2146610213'), headers: {'Authorization': 'Bearer ' + token, 'Accept': 'application/json'});
  print('managelogin 2146610213: ' + r2.statusCode.toString() + ' - ' + r2.body);
  
  final r4 = await http.get(Uri.parse('https://managelogin.jobes24x7.com/api/api/grid-card/2146610213'), headers: {'Authorization': 'Bearer ' + token, 'Accept': 'application/json'});
  print('managelogin api/api 2146610213: ' + r4.statusCode.toString() + ' - ' + r4.body);

  final r5 = await http.get(Uri.parse('https://user.jobes24x7.com/api/grid-card/9508383027'), headers: {'Authorization': 'Bearer ' + token, 'Accept': 'application/json'});
  print('user 9508383027: ' + r5.statusCode.toString() + ' - ' + r5.body);
  
  // Try with phone number
  final r6 = await http.get(Uri.parse('https://user.jobes24x7.com/api/grid-card/8012107626'), headers: {'Authorization': 'Bearer ' + token, 'Accept': 'application/json'});
  print('user phone: ' + r6.statusCode.toString() + ' - ' + r6.body);
}
