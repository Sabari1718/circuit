import 'package:flutter/material.dart';
import 'store_opening_hours_widget.dart';
import '../../core/services/api_service.dart';

class StoreConfigurationWidget extends StatefulWidget {
  final VoidCallback onContinue;

  const StoreConfigurationWidget({super.key, required this.onContinue});

  @override
  State<StoreConfigurationWidget> createState() => _StoreConfigurationWidgetState();
}

class _StoreConfigurationWidgetState extends State<StoreConfigurationWidget> {
  int _currentView = 0; // 0 = Overview, 1 = Payment Gateways, 2 = Opening Hours

  void _navigateToView(int viewIndex) {
    setState(() {
      _currentView = viewIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (_currentView == 1) {
      return StorePaymentGatewaysWidget(
        onBack: () => _navigateToView(0),
        onContinue: () => _navigateToView(2), // Continues to Opening Hours
      );
    } else if (_currentView == 2) {
      return StoreOpeningHoursWidget(
        onBack: () => _navigateToView(0),
        onSave: widget.onContinue,
      );
    }

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Store Configuration",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Set up payment options and business hours",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          isMobile
              ? Column(
                  children: [
                    _buildConfigCard(
                      icon: Icons.credit_card,
                      iconColor: const Color(0xFF6366F1), // Indigo
                      title: "Store Payment Gateways",
                      pillText: "1 payment channels configured",
                      subtitle: "Set up and enable payment options like Cash, Cards, UPI, Wallets, etc.",
                      actionText: "Configure Gateways",
                      onAction: () => _navigateToView(1),
                    ),
                    const SizedBox(height: 24),
                    _buildConfigCard(
                      icon: Icons.access_time,
                      iconColor: const Color(0xFF8B5CF6), // Purple
                      title: "Opening & Closing Time",
                      pillText: "Open 6 of 7 days a week",
                      subtitle: "Manage your store opening and closing times, operational days, and weekend timings.",
                      actionText: "Set Store Hours",
                      onAction: () => _navigateToView(2),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildConfigCard(
                        icon: Icons.credit_card,
                        iconColor: const Color(0xFF6366F1), // Indigo
                        title: "Store Payment Gateways",
                        pillText: "1 payment channels configured",
                        subtitle: "Set up and enable payment options like Cash, Cards, UPI, Wallets, etc.",
                        actionText: "Configure Gateways",
                        onAction: () => _navigateToView(1),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildConfigCard(
                        icon: Icons.access_time,
                        iconColor: const Color(0xFF8B5CF6), // Purple
                        title: "Opening & Closing Time",
                        pillText: "Open 6 of 7 days a week",
                        subtitle: "Manage your store opening and closing times, operational days, and weekend timings.",
                        actionText: "Set Store Hours",
                        onAction: () => _navigateToView(2),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    ));
  }

  Widget _buildConfigCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String pillText,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    pillText,
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          InkWell(
            onTap: onAction,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      actionText,
                      style: const TextStyle(
                        color: Color(0xFF4F46E5), // Indigo
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF4F46E5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentChannelFolder {
  String name;
  List<String> children;
  PaymentChannelFolder(this.name, this.children);
}

class StorePaymentGatewaysWidget extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const StorePaymentGatewaysWidget({
    super.key,
    required this.onBack,
    required this.onContinue,
  });

  @override
  State<StorePaymentGatewaysWidget> createState() => _StorePaymentGatewaysWidgetState();
}

class _StorePaymentGatewaysWidgetState extends State<StorePaymentGatewaysWidget> {
  final _methodNameCtrl = TextEditingController();
  final _languageCtrl = TextEditingController();

  String _selectedParent = 'Top-Level Channel (No Parent)';
  
  List<PaymentChannelFolder> _folders = [];
  List<String> _languages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final apiService = ApiService();
    try {
      final gatewaysData = await apiService.getStorePaymentGateways();
      final languagesData = await apiService.getStoreSupportedLanguages();

      final parsedFolders = <PaymentChannelFolder>[];
      for (var item in gatewaysData) {
        if (item['payment_type'] == 'category' && item['status'] == 'Active') {
          final folderName = item['payment_name'] as String;
          final childrenList = item['children'] as List<dynamic>? ?? [];
          final childrenNames = childrenList.map((c) => c['payment_name'].toString()).toList();
          parsedFolders.add(PaymentChannelFolder(folderName, childrenNames));
        }
      }

      final parsedLanguages = <String>[];
      for (var item in languagesData) {
        if (item['status'] == 'Active') {
          parsedLanguages.add(item['language_name'].toString());
        }
      }

      setState(() {
        _folders = parsedFolders;
        _languages = parsedLanguages;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() => _isLoading = false);
    }
  }

  String? _editingFolderName;
  String? _editingChannelFolder; 
  String? _editingChannelName;
  final _editCtrl = TextEditingController();

  @override
  void dispose() {
    _methodNameCtrl.dispose();
    _languageCtrl.dispose();
    _editCtrl.dispose();
    super.dispose();
  }

  void _startEditingFolder(String folderName) {
    setState(() {
      _editingFolderName = folderName;
      _editingChannelName = null;
      _editingChannelFolder = null;
      _editCtrl.text = folderName;
    });
  }

  void _saveFolderEdit(String oldName) {
    final newName = _editCtrl.text.trim();
    if (newName.isEmpty || newName == oldName) {
      _cancelEdit();
      return;
    }
    setState(() {
      final index = _folders.indexWhere((f) => f.name == oldName);
      if (index != -1) {
        _folders[index].name = newName;
        if (_selectedParent == oldName) {
           _selectedParent = newName;
        }
      }
      _cancelEdit();
    });
  }

  void _startEditingChannel(String folderName, String channelName) {
    setState(() {
      _editingFolderName = null;
      _editingChannelFolder = folderName;
      _editingChannelName = channelName;
      _editCtrl.text = channelName;
    });
  }

  void _saveChannelEdit(String folderName, String oldName) {
    final newName = _editCtrl.text.trim();
    if (newName.isEmpty || newName == oldName) {
      _cancelEdit();
      return;
    }
    setState(() {
      final folderIndex = _folders.indexWhere((f) => f.name == folderName);
      if (folderIndex != -1) {
        final childIndex = _folders[folderIndex].children.indexOf(oldName);
        if (childIndex != -1) {
          _folders[folderIndex].children[childIndex] = newName;
        }
      }
      _cancelEdit();
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingFolderName = null;
      _editingChannelName = null;
      _editingChannelFolder = null;
    });
  }

  Future<void> _addChannel() async {
    final method = _methodNameCtrl.text.trim();
    if (method.isEmpty) return;

    final isTopLevel = _selectedParent == 'Top-Level Channel (No Parent)';
    final payload = {
      "parent_id": isTopLevel ? null : "1", 
      "payment_name": method,
      "display_order": _folders.length + 1,
      "status": "Active",
      "user_main_id": null,
      "business_id": null
    };

    final success = await ApiService().createStorePaymentGateway(payload);
    if (success) {
      setState(() {
        if (isTopLevel) {
          _folders.add(PaymentChannelFolder(method, []));
        } else {
          final folder = _folders.firstWhere((f) => f.name == _selectedParent);
          folder.children.add(method);
        }
        _methodNameCtrl.clear();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add payment gateway')),
        );
      }
    }
  }

  Future<void> _addLanguage() async {
    final lang = _languageCtrl.text.trim().toUpperCase();
    if (lang.isEmpty) return;

    final payload = {
      "language_name": lang,
      "language_code": lang.length >= 2 ? lang.substring(0, 2).toLowerCase() : lang.toLowerCase(),
      "display_order": _languages.length + 1,
      "status": "Active",
      "user_main_id": null,
      "business_id": null
    };

    final success = await ApiService().createStoreSupportedLanguage(payload);
    if (success) {
      setState(() {
        if (!_languages.contains(lang)) {
          _languages.add(lang);
        }
        _languageCtrl.clear();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add language')),
        );
      }
    }
  }

  void _removeLanguage(String lang) {
    setState(() {
      _languages.remove(lang);
    });
  }

  void _removeFolder(PaymentChannelFolder folder) {
    setState(() {
      _folders.remove(folder);
      if (_selectedParent == folder.name) {
        _selectedParent = 'Top-Level Channel (No Parent)';
      }
    });
  }

  void _removeChannel(PaymentChannelFolder folder, String child) {
    setState(() {
      folder.children.remove(child);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    List<String> dropdownOptions = ['Top-Level Channel (No Parent)'];
    dropdownOptions.addAll(_folders.map((f) => f.name));

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Header
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: widget.onBack,
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back, size: 20, color: Color(0xFF1E293B)),
                          SizedBox(width: 8),
                          Text(
                            "Back to Configuration",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Store Configuration > Store Payment Gateways",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: widget.onBack,
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back, size: 20, color: Color(0xFF1E293B)),
                          SizedBox(width: 8),
                          Text(
                            "Back to Configuration",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      "Store Configuration > Store Payment Gateways",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
          const SizedBox(height: 32),
          
          Expanded(
            child: isMobile
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildLeftColumn(dropdownOptions),
                        const SizedBox(height: 24),
                        _buildRightColumn(),
                      ],
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildLeftColumn(dropdownOptions),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: _buildRightColumn(),
                      ),
                    ],
                  ),
          ),
          
          // Footer
          const SizedBox(height: 24),
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: widget.onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1), // Indigo
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Continue to Business Hours", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: widget.onBack,
                      child: const Text(
                        "Back to Overview",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: widget.onBack,
                      child: const Text(
                        "Back to Overview",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: widget.onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1), // Indigo
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        children: [
                          Text("Continue to Business Hours", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn(List<String> dropdownOptions) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Column(
      children: [
        // Add Payment Channel
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF3B82F6), size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Add Payment Channel",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CUSTOM PAYMENT DETAILS",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedParent,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                          items: dropdownOptions.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedParent = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    isMobile 
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _methodNameCtrl,
                                decoration: InputDecoration(
                                  hintText: "Method Name",
                                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                onFieldSubmitted: (_) => _addChannel(),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _addChannel,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text("Add Channel", style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _methodNameCtrl,
                                  decoration: InputDecoration(
                                    hintText: "Method Name (e.g. PayPal)",
                                    hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                  onFieldSubmitted: (_) => _addChannel(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _addChannel,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text("Add Channel", style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5), // Indigo
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "* Note: Creating a payment channel registers it globally in the database.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Custom Languages Preview
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.language, color: Color(0xFF3B82F6), size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Custom Languages Preview",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isMobile 
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _languageCtrl,
                                decoration: InputDecoration(
                                  hintText: "Add language",
                                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                onFieldSubmitted: (_) => _addLanguage(),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _addLanguage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _languageCtrl,
                                  decoration: InputDecoration(
                                    hintText: "Add language (e.g. Italian)",
                                    hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                  onFieldSubmitted: (_) => _addLanguage(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _addLanguage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5), // Indigo
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                    if (_languages.isNotEmpty) const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _languages.map((lang) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                lang,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _removeLanguage(lang),
                                child: const Icon(Icons.close, size: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF), // Light purple
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.layers, color: Color(0xFF9333EA), size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                "Payment Channels Hierarchy",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_folders.isEmpty)
            const Text("No payment channels configured yet.", style: TextStyle(color: Colors.grey)),
          ..._folders.map((folder) => _buildFolderWidget(folder)).toList(),
        ],
      ),
    );
  }

  Widget _buildFolderWidget(PaymentChannelFolder folder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.folder_open, color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 12),
              _editingFolderName == folder.name
                ? Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _editCtrl,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Color(0xFF6366F1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Color(0xFF6366F1)),
                              ),
                            ),
                            onFieldSubmitted: (_) => _saveFolderEdit(folder.name),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _saveFolderEdit(folder.name),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text("Save"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            minimumSize: const Size(0, 40),
                          ),
                        ),
                        TextButton(
                          onPressed: _cancelEdit,
                          child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: Text(
                      folder.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
              if (_editingFolderName != folder.name) ...[
                InkWell(
                  onTap: () => _startEditingFolder(folder.name),
                  child: const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () => _removeFolder(folder),
                  child: const Icon(Icons.delete_outline, size: 16, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
        if (folder.children.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 10, top: 4, bottom: 8),
            padding: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              ),
            ),
            child: Column(
              children: folder.children.map((child) => _buildChildWidget(folder, child)).toList(),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildChildWidget(PaymentChannelFolder folder, String child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, color: Color(0xFFF59E0B), size: 16),
          const SizedBox(width: 12),
          _editingChannelFolder == folder.name && _editingChannelName == child
            ? Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _editCtrl,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFF6366F1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFF6366F1)),
                          ),
                        ),
                        onFieldSubmitted: (_) => _saveChannelEdit(folder.name, child),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _saveChannelEdit(folder.name, child),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Icon(Icons.check, size: 16),
                    ),
                    TextButton(
                      onPressed: _cancelEdit,
                      child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              )
            : Expanded(
                child: Text(
                  child,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
          if (!(_editingChannelFolder == folder.name && _editingChannelName == child)) ...[
            InkWell(
              onTap: () => _startEditingChannel(folder.name, child),
              child: const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () => _removeChannel(folder, child),
              child: const Icon(Icons.delete_outline, size: 16, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
