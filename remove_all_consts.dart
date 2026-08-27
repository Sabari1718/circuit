import 'dart:io';

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) return;

  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  int fixedFiles = 0;

  final constWidgets = [
    'Text(', 'TextStyle(', 'IconThemeData(', 'Icon(', 'SizedBox(', 'Expanded(', 
    'Padding(', 'CircularProgressIndicator(', 'FittedBox(', 'Container(', 
    'BoxDecoration(', 'BoxShadow(', 'LinearGradient(', 'EdgeInsets.', 'Border.',
    'Center(', 'Align(', 'Row(', 'Column(', 'ListView(', 'GridView(', 'Positioned(',
    'Stack(', 'Wrap(', 'Flexible(', 'ColorFilter.', 'ThemeData(', 'ColorScheme.',
    'ListTile(', 'DrawerHeader(', 'CircleAvatar(', 'Divider(', 'Opacity(', 'Card(',
    'RichText(', 'TextSpan('
  ];

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    // A simple approach: remove `const ` before any widget we know might have been marked const
    // For example: `const Text(` -> `Text(`
    for (var widget in constWidgets) {
      if (content.contains('const $widget')) {
        content = content.replaceAll('const $widget', widget);
        modified = true;
      }
    }
    
    // Also remove `const []` if it contains isDark (we can just replace `const [` with `[` if there is `isDark` in the file)
    if (content.contains('isDark') && content.contains('const [')) {
      content = content.replaceAll('const [', '[');
      modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      fixedFiles++;
    }
  }

  print('Removed const from $fixedFiles files.');
}
