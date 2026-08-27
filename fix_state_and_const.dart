import 'dart:io';

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('lib directory not found.');
    return;
  }

  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  int fixedFiles = 0;

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    // Fix 1: Restore deleted State classes
    // Regex looks for createState() => _SomethingState();
    // followed by }
    // followed by bool get isDark...
    final stateRegex = RegExp(r'State<([a-zA-Z0-9_]+)>\s+createState\(\)\s*=>\s*_([a-zA-Z0-9_]+)\(\);\s*\}\s*bool get isDark\s*=>');
    
    if (stateRegex.hasMatch(content)) {
      content = content.replaceAllMapped(stateRegex, (match) {
        final widgetClass = match.group(1);
        final stateClass = match.group(2);
        return 'State<$widgetClass> createState() => _$stateClass();\n}\n\nclass _$stateClass extends State<$widgetClass> {\n  bool get isDark =>';
      });
      modified = true;
    }

    // Fix 2: Remove invalid `const` modifiers on lines containing `isDark`
    final lines = content.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('isDark') && lines[i].contains('const ')) {
        // We will just remove `const ` if the line has `isDark` and is part of a widget declaration
        // E.g., `child: const Text(..., color: isDark ? ...)` -> `child: Text(..., color: isDark ? ...)`
        // E.g., `style: const TextStyle(..., color: isDark ? ...)` -> `style: TextStyle(..., color: isDark ? ...)`
        // Wait, what if there's multiple `const`? We can remove `const ` entirely from the line, except for const Color(0xFF...) which is valid.
        
        // Let's specifically replace `const Text(` -> `Text(`, `const TextStyle(` -> `TextStyle(`, 
        // `const IconThemeData(` -> `IconThemeData(`, `const Icon(` -> `Icon(`, 
        // `const SizedBox(` -> `SizedBox(`, `const Expanded(` -> `Expanded(`, `const Padding(` -> `Padding(`, `const CircularProgressIndicator(` -> `CircularProgressIndicator(`
        
        final constWidgets = ['Text', 'TextStyle', 'IconThemeData', 'Icon', 'SizedBox', 'Expanded', 'Padding', 'CircularProgressIndicator', 'FittedBox', 'Container'];
        for (var widget in constWidgets) {
          lines[i] = lines[i].replaceAll('const $widget(', '$widget(');
        }
      }
    }
    
    final newContent = lines.join('\n');
    if (newContent != content) {
      content = newContent;
      modified = true;
    }

    // Fix 3: Remove const from BoxShadow, BoxDecoration, etc if they contain isDark
    for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('isDark')) {
             lines[i] = lines[i].replaceAll('const BoxDecoration(', 'BoxDecoration(');
             lines[i] = lines[i].replaceAll('const BoxShadow(', 'BoxShadow(');
        }
    }
    
    if (lines.join('\n') != content) {
        content = lines.join('\n');
        modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Fixed \${file.path}');
      fixedFiles++;
    }
  }

  print('Fixed \$fixedFiles files.');
}
