import 'dart:io';

void main() {
  final partnerContent = File('lib/upgrade/create_partner_business_page.dart').readAsStringSync();
  
  // 1. Extract _buildCategoryDropdownCard
  final startCard = partnerContent.indexOf('Widget _buildCategoryDropdownCard({');
  final endCard = partnerContent.indexOf('// STEP 7: Business Categories');
  final categoryCardStr = partnerContent.substring(startCard, endCard);
  
  // 2. Extract _buildStep7
  final startStep7 = partnerContent.indexOf('Widget _buildStep7(Color color, bool isDark) {');
  final endStep7 = partnerContent.indexOf('// HELPERS');
  var step7Str = partnerContent.substring(startStep7, endStep7);
  step7Str = step7Str.replaceFirst('Widget _buildStep7', 'Widget _buildStep6');
  
  // 3. Extract SearchableDropdown
  final startDropdown = partnerContent.indexOf('// Custom Searchable Dropdown widget');
  final dropdownStr = partnerContent.substring(startDropdown);
  
  final supplierContent = File('lib/upgrade/create_supplier_business_page.dart').readAsStringSync();
  
  // 4. Replace _buildStep6
  final startStep6 = supplierContent.indexOf('Widget _buildStep6(Color color, bool isDark) {');
  final endStep6 = supplierContent.indexOf('Widget _buildGridTile(');
  // Need to find exactly the previous line before Widget _buildGridTile
  final beforeGridTile = supplierContent.substring(0, endStep6).lastIndexOf('  }');
  
  final newSupplier1 = supplierContent.substring(0, startStep6) + categoryCardStr + step7Str + supplierContent.substring(beforeGridTile + 3);
  
  // 5. Replace SearchableDropdown
  final startDropdownSupp = newSupplier1.indexOf('class SearchableDropdown extends StatefulWidget {');
  final newSupplier2 = newSupplier1.substring(0, startDropdownSupp) + dropdownStr;
  
  File('lib/upgrade/create_supplier_business_page.dart').writeAsStringSync(newSupplier2);
  print('Successfully updated create_supplier_business_page.dart');
}
