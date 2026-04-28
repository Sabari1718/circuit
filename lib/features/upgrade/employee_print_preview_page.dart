import 'package:flutter/material.dart';

class EmployeePrintPreviewPage extends StatefulWidget {
  const EmployeePrintPreviewPage({super.key});

  @override
  State<EmployeePrintPreviewPage> createState() => _EmployeePrintPreviewPageState();
}

class _EmployeePrintPreviewPageState extends State<EmployeePrintPreviewPage> {
  // Selection State
  String _destination = "Microsoft Print to PDF";
  String _pages = "All";
  String _layout = "Portrait";
  String _color = "Color";

  // More Settings (Expandable)
  bool _isMoreSettingsExpanded = false;
  String _paperSize = "Letter";
  String _pagesPerSheet = "1";
  String _margins = "Default";
  String _scale = "Default";

  // Options
  bool _headersFooters = true;
  bool _backgroundGraphics = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF5F6368)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Print",
          style: TextStyle(
            color: Color(0xFF3C4043),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 800;
          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 3, child: _buildPreviewArea()),
                _buildSettingsPanel(320),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildPreviewArea(height: 400),
                  _buildSettingsPanel(double.infinity),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildPreviewArea({double? height}) {
    return Container(
      height: height,
      color: const Color(0xFF525659), // Chrome PDF background
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: _layout == "Portrait" ? 0.707 : 1.414,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.description_rounded,
                    size: 80,
                    color: Colors.grey[200],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "1",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPanel(double width) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Color(0xFFDADCE0))),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Print",
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF202124),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "2 sheets of paper",
                    style: TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildDropdownRow(
                    "Destination",
                    _destination,
                    ["Microsoft Print to PDF", "Save as PDF", "See more..."],
                    (val) => setState(() => _destination = val!),
                  ),
                  _buildDropdownRow(
                    "Pages",
                    _pages,
                    ["All", "Odd pages only", "Even pages only", "Custom"],
                    (val) => setState(() => _pages = val!),
                  ),
                  _buildDropdownRow(
                    "Layout",
                    _layout,
                    ["Portrait", "Landscape"],
                    (val) => setState(() => _layout = val!),
                  ),
                  _buildDropdownRow(
                    "Color",
                    _color,
                    ["Black and white", "Color"],
                    (val) => setState(() => _color = val!),
                  ),
                  
                  const Divider(height: 32, color: Color(0xFFDADCE0)),
                  
                  InkWell(
                    onTap: () => setState(() => _isMoreSettingsExpanded = !_isMoreSettingsExpanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Text(
                            "More settings",
                            style: TextStyle(fontSize: 13, color: Color(0xFF202124)),
                          ),
                          Icon(
                            _isMoreSettingsExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 18,
                            color: const Color(0xFF5F6368),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (_isMoreSettingsExpanded) ...[
                    const SizedBox(height: 8),
                    _buildDropdownRow(
                      "Paper size",
                      _paperSize,
                      [
                        "Letter", "Tabloid", "Legal", "Statement", "Executive",
                        "A3", "A4", "A5", "B4 (JIS)", "B5 (JIS)",
                        "Envelope #9", "Envelope #10", "C size sheet", "D size sheet", "E size sheet", "Envelope DL"
                      ],
                      (val) => setState(() => _paperSize = val!),
                    ),
                    _buildDropdownRow(
                      "Pages per sheet",
                      _pagesPerSheet,
                      ["1", "2", "4", "6", "9", "16"],
                      (val) => setState(() => _pagesPerSheet = val!),
                    ),
                    _buildDropdownRow(
                      "Margins",
                      _margins,
                      ["Default", "None", "Minimum", "Custom"],
                      (val) => setState(() => _margins = val!),
                    ),
                    _buildDropdownRow(
                      "Scale",
                      _scale,
                      ["Default", "Custom"],
                      (val) => setState(() => _scale = val!),
                    ),
                  ],
                  
                  const Divider(height: 32, color: Color(0xFFDADCE0)),
                  
                  const Text(
                    "Options",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF202124),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCheckboxRow("Headers and footers", _headersFooters, (val) => setState(() => _headersFooters = val!)),
                  _buildCheckboxRow("Background graphics", _backgroundGraphics, (val) => setState(() => _backgroundGraphics = val!)),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF5F6368))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F4),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF5F6368), size: 20),
                style: const TextStyle(fontSize: 13, color: Color(0xFF202124)),
                items: options.map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow(String label, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              activeColor: const Color(0xFF1A73E8),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF3C4043))),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDADCE0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              // Print logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text("Print", style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1A73E8),
              side: const BorderSide(color: Color(0xFFDADCE0)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
