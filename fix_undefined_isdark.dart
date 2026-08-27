import 'dart:io';

void main() {
  final logFile = File(r'C:\Users\welcome\.gemini\antigravity-ide\brain\4d0423e6-a938-43e0-9be1-11d1ddcf5f48\.system_generated\tasks\task-725.log');
  if (!logFile.existsSync()) {
    print('Log file not found');
    return;
  }

  final lines = logFile.readAsLinesSync();
  final errors = lines.where((l) => l.contains("Undefined name 'isDark'"));
  
  // Group errors by file
  final fileToLines = <String, Set<int>>{};
  for (final error in errors) {
    // Format: error - Undefined name 'isDark'. ... - lib\path\to\file.dart:75:42 - undefined_identifier
    final parts = error.split(' - ');
    if (parts.length >= 3) {
      final fileLineCol = parts[2].split(':');
      if (fileLineCol.length >= 3) {
        final filePath = fileLineCol[0].trim();
        final lineNum = int.tryParse(fileLineCol[1].trim());
        if (filePath.isNotEmpty && lineNum != null) {
          fileToLines.putIfAbsent(filePath, () => {}).add(lineNum);
        }
      }
    }
  }

  for (final filePath in fileToLines.keys) {
    final file = File(filePath);
    if (!file.existsSync()) continue;

    final contentLines = file.readAsLinesSync();
    final errorLines = fileToLines[filePath]!;
    
    for (final lineNum in errorLines) {
      // lineNum is 1-based
      final idx = lineNum - 1;
      if (idx >= 0 && idx < contentLines.length) {
        contentLines[idx] = contentLines[idx].replaceAll(
          RegExp(r'\bisDark\b'), 
          '(Theme.of(context).brightness == Brightness.dark)'
        );
      }
    }

    file.writeAsStringSync(contentLines.join('\n'));
    print('Fixed isDark in $filePath');
  }
}
