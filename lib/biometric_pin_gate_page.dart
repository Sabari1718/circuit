import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'app_lock_service.dart';
import 'auth_service.dart';
import 'home_page.dart';
import 'login_page.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// BiometricPinGatePage
///
/// Shown every time a logged-in user reopens the app.
///
/// Flow:
///   1. If biometrics available → auto-trigger fingerprint prompt
///      └─ Success → HomePage
///      └─ Fail/Cancel → 6-digit PIN keypad
///   2. 6-digit PIN → POST to Login API (PIN as `password` field)
///      └─ API success → HomePage
///      └─ API fail   → error + retry (max 5 attempts)
///
/// On Web: biometrics skipped (kIsWeb), goes straight to PIN.
/// ─────────────────────────────────────────────────────────────────────────────
class BiometricPinGatePage extends StatefulWidget {
  final String userName;
  final String email;
  final String phone;

  const BiometricPinGatePage({
    super.key,
    required this.userName,
    required this.email,
    required this.phone,
  });

  @override
  State<BiometricPinGatePage> createState() => _BiometricPinGatePageState();
}

enum _GateStep { biometric, methodSelect, pin, password }

class _BiometricPinGatePageState extends State<BiometricPinGatePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // ── Services ────────────────────────────────────────────────────────────────
  final AppLockService _lockService = AppLockService();
  final AuthService _authService = AuthService();

  // ── State ───────────────────────────────────────────────────────────────────
  _GateStep _step = _GateStep.biometric;

  final List<String> _enteredPin = [];
  final TextEditingController _passwordController = TextEditingController();

  bool _canUseBiometric = false;
  bool _isAuthenticatingBio = false;
  bool _isCheckingPin = false;
  bool _isCheckingPassword = false;
  bool _obscurePassword = true;
  bool _navigatedAway = false;

  int _pinAttempts = 0;
  static const int _maxPinAttempts = 5;

  String _errorMessage = '';

  // ── Animation ───────────────────────────────────────────────────────────────
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(_shakeController);

    // Init biometrics and optionally trigger fingerprint
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (kIsWeb) {
        // Biometrics not supported on web — go straight to PIN
        if (mounted) setState(() => _step = _GateStep.pin);
        return;
      }

      final canBio = await _lockService.canAuthenticateWithBiometrics();
      if (!mounted) return;

      setState(() {
        _canUseBiometric = canBio;
        _step = canBio ? _GateStep.biometric : _GateStep.pin;
      });

      if (canBio) {
        _triggerBiometric();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shakeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-trigger biometric when the user comes back from the system prompt
    if (state == AppLifecycleState.resumed &&
        !_navigatedAway &&
        _step == _GateStep.biometric &&
        _canUseBiometric) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_navigatedAway) _triggerBiometric();
      });
    }
  }

  // ── Biometric ────────────────────────────────────────────────────────────────
  Future<void> _triggerBiometric() async {
    if (_isAuthenticatingBio || _navigatedAway || !_canUseBiometric) return;

    setState(() {
      _isAuthenticatingBio = true;
      _errorMessage = '';
    });

    final success = await _lockService.authenticateBiometric();

    if (!mounted) return;

    setState(() => _isAuthenticatingBio = false);

    if (success) {
      _navigateToHome();
    } else {
      // Fingerprint failed/cancelled → show method selector
      setState(() {
        _step = _GateStep.methodSelect;
        _errorMessage = '';
      });
    }
  }

  // ── PIN input ────────────────────────────────────────────────────────────────
  void _onDigit(String digit) {
    if (_isCheckingPin) return;
    if (_enteredPin.length >= 6) return;

    setState(() {
      _enteredPin.add(digit);
      _errorMessage = '';
    });

    if (_enteredPin.length == 6) {
      _verifyPinViaApi();
    }
  }

  void _onBackspace() {
    if (_isCheckingPin) return;
    if (_enteredPin.isEmpty) return;
    setState(() => _enteredPin.removeLast());
  }

  Future<void> _verifyPinViaApi() async {
    if (_isCheckingPin) return;

    final String pin = _enteredPin.join();

    // Determine the identifier: prefer phone, fallback to email
    final String identifier = widget.phone.isNotEmpty
        ? widget.phone
        : widget.email;

    if (identifier.isEmpty) {
      // No stored identifier — force full re-login
      _forceReLogin(reason: 'No account identifier found. Please log in again.');
      return;
    }

    setState(() {
      _isCheckingPin = true;
      _errorMessage = '';
    });

    try {
      await _authService.login(
        identifier: identifier,
        password: pin,
      );

      if (!mounted) return;

      // API returned success (token saved inside AuthService.login)
      _navigateToHome();
    } on AuthException catch (e) {
      if (!mounted) return;
      _pinAttempts++;
      _triggerShake();

      setState(() {
        _enteredPin.clear();
        _isCheckingPin = false;

        if (_pinAttempts >= _maxPinAttempts) {
          _errorMessage =
              'Too many incorrect PINs. Please log in with your password.';
        } else {
          final remaining = _maxPinAttempts - _pinAttempts;
          _errorMessage = 'Incorrect PIN: ${e.message}. $remaining attempt${remaining == 1 ? '' : 's'} left.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      _pinAttempts++;
      _triggerShake();

      setState(() {
        _enteredPin.clear();
        _isCheckingPin = false;
        _errorMessage = 'Connection error. Check your network and try again.';
      });
    }
  }

  // ── Password verify ───────────────────────────────────────────────────────────
  Future<void> _verifyPasswordViaApi() async {
    if (_isCheckingPassword) return;

    final String password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password.');
      return;
    }

    final String identifier =
        widget.phone.isNotEmpty ? widget.phone : widget.email;

    if (identifier.isEmpty) {
      _forceReLogin(reason: 'No account identifier found. Please log in again.');
      return;
    }

    setState(() {
      _isCheckingPassword = true;
      _errorMessage = '';
    });

    try {
      await _authService.login(identifier: identifier, password: password);
      if (!mounted) return;
      _navigateToHome();
    } on AuthException catch (e) {
      if (!mounted) return;
      _triggerShake();
      setState(() {
        _isCheckingPassword = false;
        _errorMessage = 'Incorrect password: ${e.message}.';
      });
    } catch (e) {
      if (!mounted) return;
      _triggerShake();
      setState(() {
        _isCheckingPassword = false;
        _errorMessage = 'Connection error. Check your network and try again.';
      });
    }
  }

  // ── Navigation helpers ────────────────────────────────────────────────────────
  void _navigateToHome() {
    if (_navigatedAway) return;
    _navigatedAway = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(
          userName: widget.userName,
          email: widget.email,
        ),
      ),
    );
  }

  void _forceReLogin({String? reason}) {
    if (_navigatedAway) return;
    _navigatedAway = true;

    if (reason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(reason)),
      );
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // ── Misc helpers ─────────────────────────────────────────────────────────────
  void _triggerShake() {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0);
  }

  String get _identifier =>
      widget.phone.isNotEmpty ? widget.phone : widget.email;

  String get _maskedIdentifier {
    if (widget.phone.isNotEmpty && widget.phone.length >= 4) {
      return '••••${widget.phone.substring(widget.phone.length - 4)}';
    }
    if (widget.email.contains('@')) {
      final parts = widget.email.split('@');
      final local = parts[0];
      final masked = local.length > 2
          ? '${local[0]}${'•' * (local.length - 2)}${local[local.length - 1]}'
          : local;
      return '$masked@${parts[1]}';
    }
    return _identifier;
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation — auth is mandatory
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      ),
                      child: _step == _GateStep.biometric
                          ? _buildBiometricSection()
                          : _step == _GateStep.methodSelect
                              ? _buildMethodSelectSection()
                              : _step == _GateStep.password
                                  ? _buildPasswordSection()
                                  : _buildPinSection(),
                    ),
                    const SizedBox(height: 24),
                    _buildErrorMessage(),
                    const SizedBox(height: 16),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        // Lock icon ring
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            _step == _GateStep.biometric
                ? Icons.fingerprint_rounded
                : _step == _GateStep.password
                    ? Icons.lock_outline_rounded
                    : Icons.pin_outlined,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Verify Identity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.userName.isNotEmpty)
          Text(
            'Welcome back, ${widget.userName.split(' ').first}',
            style: const TextStyle(
              color: Color(0xFF6366F1),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 6),
        Text(
          _step == _GateStep.biometric
              ? 'Use fingerprint to unlock your account'
              : _step == _GateStep.methodSelect
                  ? 'Choose how you want to verify'
                  : _step == _GateStep.password
                      ? 'Enter your account password\n$_maskedIdentifier'
                      : 'Enter your 6-digit PIN\n$_maskedIdentifier',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Biometric section ─────────────────────────────────────────────────────────
  Widget _buildBiometricSection() {
    return Column(
      children: [
        // Large fingerprint icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white12),
          ),
          child: _isAuthenticatingBio
              ? const Padding(
                  padding: EdgeInsets.all(34),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                )
              : const Icon(
                  Icons.fingerprint_rounded,
                  color: Color(0xFF6366F1),
                  size: 56,
                ),
        ),
        const SizedBox(height: 28),

        // Use Fingerprint button
        _PrimaryButton(
          label: _isAuthenticatingBio ? 'Authenticating…' : 'Use Fingerprint',
          isLoading: _isAuthenticatingBio,
          onPressed: _isAuthenticatingBio ? null : _triggerBiometric,
        ),
        const SizedBox(height: 14),

        // Use PIN instead
        _SecondaryButton(
          label: 'Use PIN instead',
          onPressed: () {
            setState(() {
              _step = _GateStep.pin;
              _errorMessage = '';
            });
          },
        ),
      ],
    );
  }

  // ── Method selector ──────────────────────────────────────────────────────────
  Widget _buildMethodSelectSection() {
    return Column(
      children: [
        // PIN option card
        _MethodCard(
          icon: Icons.pin_outlined,
          title: 'PIN',
          subtitle: 'Enter your 6-digit PIN',
          onTap: () => setState(() {
            _step = _GateStep.pin;
            _enteredPin.clear();
            _errorMessage = '';
          }),
        ),
        const SizedBox(height: 16),
        // Password option card
        _MethodCard(
          icon: Icons.lock_outline_rounded,
          title: 'Password',
          subtitle: 'Enter your account password',
          onTap: () => setState(() {
            _step = _GateStep.password;
            _passwordController.clear();
            _errorMessage = '';
          }),
        ),
        const SizedBox(height: 24),
        // Retry fingerprint (if available)
        if (_canUseBiometric && !kIsWeb)
          _SecondaryButton(
            label: 'Try Fingerprint Again',
            onPressed: () {
              setState(() {
                _step = _GateStep.biometric;
                _errorMessage = '';
              });
              _triggerBiometric();
            },
          ),
      ],
    );
  }

  // ── Password section ──────────────────────────────────────────────────────────
  Widget _buildPasswordSection() {
    return Column(
      children: [
        // Password text field
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          autofocus: true,
          onSubmitted: (_) => _verifyPasswordViaApi(),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your account password',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.07),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
            ),
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white38),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white38,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _PrimaryButton(
          label: 'Verify Password',
          isLoading: _isCheckingPassword,
          onPressed: _isCheckingPassword ? null : _verifyPasswordViaApi,
        ),
        const SizedBox(height: 14),
        _SecondaryButton(
          label: 'Back',
          onPressed: () => setState(() {
            _step = _GateStep.methodSelect;
            _errorMessage = '';
          }),
        ),
      ],
    );
  }

  // ── PIN section ───────────────────────────────────────────────────────────────
  Widget _buildPinSection() {
    return Column(
      children: [
        // 6 dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            final filled = i < _enteredPin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? const Color(0xFF6366F1) : Colors.transparent,
                border: Border.all(
                  color: filled ? Colors.white : Colors.white38,
                  width: 2,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),

        // Attempts info
        if (_pinAttempts > 0 && _pinAttempts < _maxPinAttempts)
          Text(
            '${_maxPinAttempts - _pinAttempts} attempt${(_maxPinAttempts - _pinAttempts) == 1 ? '' : 's'} remaining',
            style: const TextStyle(
              color: Colors.orangeAccent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

        const SizedBox(height: 28),

        // Numpad
        ...[
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ].map(
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map(_buildDigit).toList(),
            ),
          ),
        ),

        // Bottom row: blank | 0 | backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Biometric shortcut (if available + not web)
            if (_canUseBiometric && !kIsWeb)
              _buildIconKey(
                icon: Icons.fingerprint_rounded,
                color: const Color(0xFF6366F1),
                onTap: () {
                  setState(() {
                    _step = _GateStep.biometric;
                    _enteredPin.clear();
                    _errorMessage = '';
                  });
                  _triggerBiometric();
                },
              )
            else
              const SizedBox(width: 72),

            _buildDigit('0'),
            _buildBackspace(),
          ],
        ),

        const SizedBox(height: 24),

        // Loading overlay when calling API
        if (_isCheckingPin)
          Column(
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Verifying…',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),

        // Too many attempts → force login
        if (_pinAttempts >= _maxPinAttempts)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _PrimaryButton(
              label: 'Login with Password',
              onPressed: () => _forceReLogin(reason: null),
            ),
          ),
      ],
    );
  }

  // ── Error message ─────────────────────────────────────────────────────────────
  Widget _buildErrorMessage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _errorMessage.isNotEmpty
          ? Text(
              _errorMessage,
              key: ValueKey(_errorMessage),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return TextButton(
      onPressed: () => _forceReLogin(reason: null),
      child: const Text(
        'Use a different account',
        style: TextStyle(color: Colors.white38, fontSize: 12),
      ),
    );
  }

  // ── Digit key ─────────────────────────────────────────────────────────────────
  Widget _buildDigit(String d) {
    return InkWell(
      onTap: () => _onDigit(d),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          d,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Backspace key ─────────────────────────────────────────────────────────────
  Widget _buildBackspace() {
    return InkWell(
      onTap: _onBackspace,
      borderRadius: BorderRadius.circular(40),
      child: const SizedBox(
        width: 72,
        height: 72,
        child: Icon(Icons.backspace_outlined, color: Colors.white54, size: 26),
      ),
    );
  }

  // ── Icon key (biometric shortcut) ─────────────────────────────────────────────
  Widget _buildIconKey({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}

// ── Method card ───────────────────────────────────────────────────────────────
class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF6366F1), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Reusable button widgets ───────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _PrimaryButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          disabledBackgroundColor: Colors.white10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _SecondaryButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
