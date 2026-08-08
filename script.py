import re

def main():
    with open('lib/upgrade/create_partner_business_page.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    with open('lib/upgrade/create_business_user_page.dart', 'r', encoding='utf-8') as f:
        biz_content = f.read()

    # Extract _buildCategoryDropdownCard from biz_content
    card_pattern = re.compile(r'Widget _buildCategoryDropdownCard\(\{.*?\n  \}', re.DOTALL)
    card_match = card_pattern.search(biz_content)
    if not card_match:
        print('Error finding card widget')
        return
    card_code = card_match.group(0)

    # Extract SearchableDropdown classes from biz_content
    searchable_pattern = re.compile(r'// Custom Searchable Dropdown widget\s*class SearchableDropdown extends StatefulWidget \{.*?class _DropdownSearchDialogState extends State<_DropdownSearchDialog> \{.*?    \);\s*\}\s*\}', re.DOTALL)
    searchable_match = searchable_pattern.search(biz_content)
    if not searchable_match:
        print('Error finding SearchableDropdown widget')
        return
    searchable_code = searchable_match.group(0)

    # Replace SearchableDropdown in partner page
    old_searchable_pattern = re.compile(r'// Custom Searchable Dropdown widget\s*class SearchableDropdown extends StatefulWidget \{.*?class _DropdownSearchDialogState extends State<_DropdownSearchDialog> \{.*?    \);\s*\}\s*\}', re.DOTALL)
    
    content = old_searchable_pattern.sub(searchable_code, content)

    # We also need to replace _buildStep7. It's too complex to regex safely, so we will replace it directly.
    # Let's find the start of _buildStep7
    step7_start = content.find('Widget _buildStep7(Color color, bool isDark) {')
    if step7_start == -1:
        print('Error finding _buildStep7')
        return
    
    # We will find where it ends by looking for Widget _buildFileUpload
    step7_end = content.find('Widget _buildFileUpload(', step7_start)
    if step7_end == -1:
        print('Error finding end of _buildStep7')
        return
    
    # Let's construct the new _buildStep7
    new_step7 = '''Widget _buildCategoryDropdownCard({
    required int index,
    required Color color,
    required String title,
    required int selectedCount,
    required IconData prefixIcon,
    required String hint,
    required bool isDark,
    required List<String> items,
    required String? value,
    required ValueChanged<String> onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                index.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? Colors.white70 : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ' Selected',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                const SizedBox(height: 12),
                SearchableDropdown(
                  label: '',
                  value: value,
                  items: items,
                  isDark: isDark,
                  hint: hint,
                  enabled: enabled,
                  onChanged: onChanged,
                  prefixIcon: prefixIcon,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep7(Color color, bool isDark) {
    final sectorTitles = _categoriesData.keys.toList();
    final sectors = _selectedSectorTitle != null ? _categoriesData[_selectedSectorTitle]!.keys.toList() : <String>[];
    final subSectors = (_selectedSectorTitle != null && _selectedSector != null)
        ? _categoriesData[_selectedSectorTitle]![_selectedSector]!.keys.toList()
        : <String>[];

    final primaryCategories = (_selectedSectorTitle != null && _selectedSector != null && _selectedSubSector != null)
        ? _categoriesData[_selectedSectorTitle]![_selectedSector]![_selectedSubSector]!.keys.toList()
        : <String>[];

    final subCategoriesList = (_selectedSectorTitle != null && _selectedSector != null && _selectedSubSector != null && _activePrimaryCategory != null)
        ? (_categoriesData[_selectedSectorTitle]![_selectedSector]![_selectedSubSector]![_activePrimaryCategory] ?? <String>[])
        : <String>[];

    String? selectedSub = _selectedSubCategories.isNotEmpty ? _selectedSubCategories.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.business_center, color: color, size: 24),
            const SizedBox(width: 8),
            const Text('Business Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Select the sector and categories that best describe your business activity.', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 24),
        if (_isLoadingCategories)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
        else ...[
          _buildResponsiveRow(
            _buildCategoryDropdownCard(
              index: 1,
              color: Colors.deepPurpleAccent,
              title: 'Sector Title',
              selectedCount: _selectedSectorTitle != null ? 1 : 0,
              prefixIcon: Icons.folder,
              hint: 'Select Sector Title...',
              isDark: isDark,
              items: sectorTitles,
              value: _selectedSectorTitle,
              onChanged: (val) {
                setState(() {
                  _selectedSectorTitle = val;
                  _selectedSector = null;
                  _selectedSubSector = null;
                  _activePrimaryCategory = null;
                  _selectedSubCategories.clear();
                });
              },
            ),
            _buildCategoryDropdownCard(
              index: 4,
              color: Colors.green,
              title: 'Primary Categories',
              selectedCount: _activePrimaryCategory != null ? 1 : 0,
              prefixIcon: Icons.local_offer,
              hint: 'Select Primary Categories...',
              isDark: isDark,
              items: primaryCategories,
              value: _activePrimaryCategory,
              enabled: primaryCategories.isNotEmpty,
              onChanged: (val) {
                setState(() {
                  _activePrimaryCategory = val;
                  _selectedSubCategories.clear();
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            _buildCategoryDropdownCard(
              index: 2,
              color: Colors.blue,
              title: 'Sector',
              selectedCount: _selectedSector != null ? 1 : 0,
              prefixIcon: Icons.business_center,
              hint: 'Select Sector...',
              isDark: isDark,
              items: sectors,
              value: _selectedSector,
              enabled: _selectedSectorTitle != null,
              onChanged: (val) {
                setState(() {
                  _selectedSector = val;
                  _selectedSubSector = null;
                  _activePrimaryCategory = null;
                  _selectedSubCategories.clear();
                });
              },
            ),
            _buildCategoryDropdownCard(
              index: 5,
              color: Colors.orange,
              title: 'Sub Categories',
              selectedCount: _selectedSubCategories.length,
              prefixIcon: Icons.style,
              hint: 'Select Sub Categories...',
              isDark: isDark,
              items: subCategoriesList.toSet().toList(),
              value: selectedSub,
              enabled: subCategoriesList.isNotEmpty,
              onChanged: (val) {
                setState(() {
                  _selectedSubCategories.clear();
                  _selectedSubCategories.add(val);
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            _buildCategoryDropdownCard(
              index: 3,
              color: Colors.teal,
              title: 'Sub Sector',
              selectedCount: _selectedSubSector != null ? 1 : 0,
              prefixIcon: Icons.layers,
              hint: 'Select Sub Sector...',
              isDark: isDark,
              items: subSectors,
              value: _selectedSubSector,
              enabled: _selectedSector != null,
              onChanged: (val) {
                setState(() {
                  _selectedSubSector = val;
                  _activePrimaryCategory = null;
                  _selectedSubCategories.clear();
                });
              },
            ),
            _buildCategoryDropdownCard(
              index: 6,
              color: Colors.pinkAccent,
              title: 'Brand',
              selectedCount: 0,
              prefixIcon: Icons.workspace_premium,
              hint: 'Select Brands...',
              isDark: isDark,
              items: [],
              value: null,
              enabled: false,
              onChanged: (val) {},
            ),
          ),
        ],
      ],
    );
  }

  '''
    
    # To properly construct the final string, we inject the new step7
    final_content = content[:step7_start] + new_step7 + content[step7_end:]
    
    with open('lib/upgrade/create_partner_business_page.dart', 'w', encoding='utf-8') as f:
        f.write(final_content)

    print('Successfully updated create_partner_business_page.dart')

if __name__ == '__main__':
    main()
