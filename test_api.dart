import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final response = await http.post(
    Uri.parse('https://tringgo.site/api/v1/motorcycle/auth/login'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({'email': 'test@test.com', 'password': 'password'})
  );
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
  print('Body length: ${response.body.length}');
  final d = jsonDecode(response.body);
  print('Is Map: ${d is Map<String, dynamic>}');
}
