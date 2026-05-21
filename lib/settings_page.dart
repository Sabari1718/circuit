import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appName = "UserPortal";
  String _version = "1.0.0";
  String _buildNumber = "1";
  String _softwareVersion = "Android 13 / iOS 17"; // Example placeholder

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appName = info.appName;
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("App Information"),
              _buildInfoCard([
                _buildInfoRow(Icons.info_outline, "App Name", _appName),
                _buildDivider(),
                _buildInfoRow(Icons.numbers, "Build Number", _buildNumber),
                _buildDivider(),
                _buildInfoRow(Icons.system_update, "App Version", _version),
                _buildDivider(),
                _buildInfoRow(Icons.code, "Software Version", _softwareVersion),
              ]),
              const SizedBox(height: 30),
              _buildSectionTitle("Appearance"),
              _buildThemeCard(themeProvider),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icon/app_icon.png', // Assuming this exists based on pubspec
                      height: 60,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.layers_rounded, size: 60, color: Color(0xFFF59E0B)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Made with ❤️ for UserPortal",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(ThemeProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            provider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            size: 22,
            color: Colors.orange,
          ),
          const SizedBox(width: 16),
          const Text(
            "Dark Mode",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const Spacer(),
          Switch.adaptive(
            value: provider.isDarkMode,
            onChanged: (value) => provider.toggleTheme(),
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 20,
      endIndent: 20,
      color: Colors.grey.withOpacity(0.2),
    );
  }
}
