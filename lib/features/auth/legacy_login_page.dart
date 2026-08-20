import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sva_business_user/core/services/api_service.dart';
import 'package:sva_business_user/features/home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int _currentStep = 0; // 0: Phone, 1: Phone OTP, 2: Password, 3: Email, 4: Email OTP
  
  // Shared Data
  String _mobileNumber = "";
  String _verificationId = "";
  final _apiService = ApiService();

  void _nextStep() => setState(() => _currentStep++);
  void _prevStep() => setState(() => _currentStep--);
  void _reset() => setState(() => _currentStep = 0);

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case 0: return _PhoneInputStep(onOtpSent: (num, id) { _mobileNumber = num; _verificationId = id; _nextStep(); });
      case 1: return _PhoneOtpStep(mobileNumber: _mobileNumber, verificationId: _verificationId, onVerified: _nextStep, onBack: _prevStep);
      case 2: return _PasswordStep(mobileNumber: _mobileNumber, onSet: _nextStep, onBack: _prevStep);
      case 3: return _EmailInputStep(onOtpSent: _nextStep, onBack: _prevStep);
      case 4: return _EmailOtpStep(onVerified: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(userName: "Sabari", email: "test@example.com"))), onBack: _prevStep);
      default: return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}

// --- STEP 0: PHONE INPUT ---
class _PhoneInputStep extends StatefulWidget {
  final Function(String, String) onOtpSent;
  const _PhoneInputStep({required this.onOtpSent});

  @override
  State<_PhoneInputStep> createState() => _PhoneInputStepState();
}

class _PhoneInputStepState extends State<_PhoneInputStep> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.replaceAll(' ', '');
    if (phone.length != 10) return;

    setState(() => _isLoading = true);
    final res = await ApiService().sendOtp(phone);
    setState(() => _isLoading = false);

    if (res['status'] == 'success' || res['responseCode'] == 200) {
      widget.onOtpSent(phone, res['data']?['verificationId'] ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Welcome back", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Enter your phone number to sign in", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                decoration: InputDecoration(
                  hintText: "Phone Number",
                  prefixText: "+91 ",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendOtp,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Continue", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- STEP 1: PHONE OTP ---
class _PhoneOtpStep extends StatefulWidget {
  final String mobileNumber;
  final String verificationId;
  final VoidCallback onVerified;
  final VoidCallback onBack;
  const _PhoneOtpStep({required this.mobileNumber, required this.verificationId, required this.onVerified, required this.onBack});

  @override
  State<_PhoneOtpStep> createState() => _PhoneOtpStepState();
}

class _PhoneOtpStepState extends State<_PhoneOtpStep> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 4) return;

    setState(() => _isLoading = true);
    final res = await ApiService().validateOtp(widget.mobileNumber, code, widget.verificationId);
    setState(() => _isLoading = false);

    if (res['status'] == 'success' || res['responseCode'] == 200) {
      widget.onVerified();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Verification", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Enter OTP sent to +91 ${widget.mobileNumber}"),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (i) => SizedBox(
                width: 60,
                child: TextField(
                  controller: _controllers[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [LengthLimitingTextInputFormatter(1)],
                  onChanged: (v) { if (v.isNotEmpty && i < 3) FocusScope.of(context).nextFocus(); },
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
              )),
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _verifyOtp, child: const Text("Verify")),
          ],
        ),
      ),
    );
  }
}

// --- STEP 2: PASSWORD ---
class _PasswordStep extends StatefulWidget {
  final String mobileNumber;
  final VoidCallback onSet;
  final VoidCallback onBack;
  const _PasswordStep({required this.mobileNumber, required this.onSet, required this.onBack});

  @override
  State<_PasswordStep> createState() => _PasswordStepState();
}

class _PasswordStepState extends State<_PasswordStep> {
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Set Password", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: "Password",
                suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscure = !_obscure)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: widget.onSet, child: const Text("Continue")),
          ],
        ),
      ),
    );
  }
}

// --- STEP 3: EMAIL INPUT ---
class _EmailInputStep extends StatelessWidget {
  final VoidCallback onOtpSent;
  final VoidCallback onBack;
  const _EmailInputStep({required this.onOtpSent, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Contact Info", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextField(decoration: InputDecoration(hintText: "Email Address", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: onOtpSent, child: const Text("Send Verification")),
          ],
        ),
      ),
    );
  }
}

// --- STEP 4: EMAIL OTP ---
class _EmailOtpStep extends StatelessWidget {
  final VoidCallback onVerified;
  final VoidCallback onBack;
  const _EmailOtpStep({required this.onVerified, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Verify Email", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            const Text("Check your inbox for codes"),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: onVerified, child: const Text("Complete Registration")),
          ],
        ),
      ),
    );
  }
}

