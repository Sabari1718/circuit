import 'dart:io';

void main() {
  final logFile = File(r'C:\Users\welcome\.gemini\antigravity-ide\brain\4d0423e6-a938-43e0-9be1-11d1ddcf5f48\.system_generated\tasks\task-758.log');
  if (!logFile.existsSync()) return;

  final lines = logFile.readAsLinesSync();
  final errors = lines.where((l) => l.contains("Undefined name 'context'"));
  
  final fileToLines = <String, Set<int>>{};
  for (final error in errors) {
    final parts = error.split(' - ');
    if (parts.length >= 3) {
      final fileLineCol = parts[1].trim().split(':'); // wait, error is `error - lib\path:line:col - Undefined name`
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
      final idx = lineNum - 1;
      if (idx >= 0 && idx < contentLines.length) {
        // Find: (Theme.of(context).brightness == Brightness.dark) ? A : B
        contentLines[idx] = contentLines[idx].replaceAllMapped(
          RegExp(r'\(Theme\.of\(context\)\.brightness == Brightness\.dark\)\s*\?\s*([^:]+)\s*:\s*([^,)\s;\]}]+)'), 
          (match) => match.group(2)!
        );
      }
    }
    file.writeAsStringSync(contentLines.join('\n'));
    print('Fixed context in $filePath');
  }

  // Also fix lib\upgrade\post_job_page.dart:50 and 55: The default value of an optional parameter must be constant
  final postJob = File(r'lib\upgrade\post_job_page.dart');
  if (postJob.existsSync()) {
      var content = postJob.readAsStringSync();
      content = content.replaceAll('List<String> items = [],', 'List<String> items = const [],');
      postJob.writeAsStringSync(content);
      print('Fixed post_job_page.dart');
  }
}
