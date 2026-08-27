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

    // Pattern to find the createState line and extract the class name
    final stateRegex = RegExp(r'State<([a-zA-Z0-9_]+)>\s+createState\(\)\s*=>\s*_([a-zA-Z0-9_]+)\(\);\s*\}\s*class _\$\{?className\}?State extends State<\$?className>\s*\{');
    
    if (stateRegex.hasMatch(content)) {
      content = content.replaceAllMapped(stateRegex, (match) {
        final widgetClass = match.group(1);
        final stateClass = match.group(2);
        return 'State<$widgetClass> createState() => _$stateClass();\n}\n\nclass _$stateClass extends State<$widgetClass> {';
      });
      modified = true;
    }

    // Sometimes it might just be: class _${className}State extends State<$className> { 
    // And what if the above regex misses because of newlines? Let's do a more robust approach if it's there
    // If the string `class _\${className}State` exists, but stateRegex didn't match, we need another pass:
    if (content.contains(r'class _${className}State')) {
        final match = RegExp(r'State<([a-zA-Z0-9_]+)>\s+createState\(\)\s*=>').firstMatch(content);
        if (match != null) {
            final className = match.group(1);
            content = content.replaceAll(r'class _${className}State extends State<$className> {', 'class _$className\State extends State<$className> {');
            modified = true;
        }
    }
    
    // Also in previous script, I might have output: class _\${className}State extends State<\$className> {
    if (content.contains(r'class _${className}State extends State<$className> {')) {
        final match = RegExp(r'State<([a-zA-Z0-9_]+)>\s+createState\(\)\s*=>').firstMatch(content);
        if (match != null) {
            final className = match.group(1);
            content = content.replaceAll(r'class _${className}State extends State<$className> {', 'class _$className\State extends State<$className> {');
            modified = true;
        }
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Fixed state class in \${file.path}');
      fixedFiles++;
    }
  }

  print('Fixed \$fixedFiles files.');
}
