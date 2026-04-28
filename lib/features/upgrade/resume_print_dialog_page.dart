import 'package:flutter/material.dart';

class ResumePrintDialogPage extends StatefulWidget {
  const ResumePrintDialogPage({super.key});

  @override
  State<ResumePrintDialogPage> createState() => _ResumePrintDialogPageState();
}

class _ResumePrintDialogPageState extends State<ResumePrintDialogPage> {
  // Settings Panel State
  String _destination = "Microsoft Print to PDF";
  String _pages = "All";
  String _layout = "Portrait";
  String _color = "Color";

  // More Settings Expansion State
  bool _isExpanded = false;

  // More Settings State
  String _paperSize = "Letter";
  String _pagesPerSheet = "1";
  String _margins = "Default";
  String _scale = "Default";

  // Options State
  bool _headersAndFooters = true;
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
          style: TextStyle(color: Color(0xFF323639), fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildPreviewArea(),
                ),
                Container(
                  width: 320,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(left: BorderSide(color: Color(0xFFDADCE0))),
                  ),
                  child: _buildSettingsPanel(),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildPreviewArea(height: 400),
                  _buildSettingsPanel(),
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
      color: const Color(0xFF525659), // Standard Chrome PDF/Print preview background
      padding: const EdgeInsets.all(32),
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
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(Icons.description_rounded, size: 80, color: Colors.grey[200]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "1",
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Print",
                  style: TextStyle(fontSize: 18, color: Color(0xFF202124), fontWeight: FontWeight.normal),
                ),
                const Text(
                  "2 sheets of paper",
                  style: TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
                ),
                const SizedBox(height: 24),
                
                _buildDropdownRow(
                  label: "Destination",
                  value: _destination,
                  items: ["Microsoft Print to PDF", "Save as PDF", "See more..."],
                  onChanged: (val) => setState(() => _destination = val!),
                ),
                _buildDropdownRow(
                  label: "Pages",
                  value: _pages,
                  items: ["All", "Odd pages only", "Even pages only", "Custom"],
                  onChanged: (val) => setState(() => _pages = val!),
                ),
                _buildDropdownRow(
                  label: "Layout",
                  value: _layout,
                  items: ["Portrait", "Landscape"],
                  onChanged: (val) => setState(() => _layout = val!),
                ),
                _buildDropdownRow(
                  label: "Color",
                  value: _color,
                  items: ["Black and white", "Color"],
                  onChanged: (val) => setState(() => _color = val!),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Color(0xFFDADCE0)),
                ),
                
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          "More settings",
                          style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                        ),
                        Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (_isExpanded) ...[
                  _buildDropdownRow(
                    label: "Paper size",
                    value: _paperSize,
                    items: [
                      "Letter", "Tabloid", "Legal", "Statement", "Executive", 
                      "A3", "A4", "A5", "B4 (JIS)", "B5 (JIS)", 
                      "Envelope #9", "Envelope #10", "C size sheet", "D size sheet", "E size sheet", "Envelope DL"
                    ],
                    onChanged: (val) => setState(() => _paperSize = val!),
                  ),
                  _buildDropdownRow(
                    label: "Pages per sheet",
                    value: _pagesPerSheet,
                    items: ["1", "2", "4", "6", "9", "16"],
                    onChanged: (val) => setState(() => _pagesPerSheet = val!),
                  ),
                  _buildDropdownRow(
                    label: "Margins",
                    value: _margins,
                    items: ["Default", "None", "Minimum", "Custom"],
                    onChanged: (val) => setState(() => _margins = val!),
                  ),
                  _buildDropdownRow(
                    label: "Scale",
                    value: _scale,
                    items: ["Default", "Custom"],
                    onChanged: (val) => setState(() => _scale = val!),
                  ),
                ],
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Color(0xFFDADCE0)),
                ),
                
                const Text(
                  "Options",
                  style: TextStyle(fontSize: 13, color: Color(0xFF202124), fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 8),
                _buildCheckboxRow("Headers and footers", _headersAndFooters, (val) => setState(() => _headersAndFooters = val!)),
                _buildCheckboxRow("Background graphics", _backgroundGraphics, (val) => setState(() => _backgroundGraphics = val!)),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        _buildBottomActions(),
      ],
    );
  }

  Widget _buildDropdownRow({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                items: items.map((String val) {
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
      padding: const EdgeInsets.symmetric(vertical: 2.0),
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
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF323639))),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDADCE0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              // Mock print logic
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
