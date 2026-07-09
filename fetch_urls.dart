import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  
  Future<String?> getImageUrl(String title) async {
    final req = await client.getUrl(Uri.parse('https://en.wikipedia.org/w/api.php?action=query&titles=$title&prop=pageimages&format=json&pithumbsize=800'));
    req.headers.set('User-Agent', 'Mozilla/5.0');
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    final data = jsonDecode(body);
    final pages = data['query']['pages'] as Map<String, dynamic>;
    final page = pages.values.first;
    if (page.containsKey('thumbnail')) {
      return page['thumbnail']['source'];
    }
    return null;
  }
  
  final titles = [
    'Meenakshi_Amman_Temple',
    'Brihadisvara_Temple',
    'Makkah_Masjid',
    'Santhome_Church',
  ];
  
  for (final title in titles) {
    final url = await getImageUrl(title);
    print('$title: $url');
  }
  
  client.close();
}
