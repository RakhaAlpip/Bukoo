import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import 'home_page.dart';

// Enum untuk melacak status animasi karakter
enum AuthStatus { idle, typingUsername, typingPassword, loading, success, failure }

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> with TickerProviderStateMixin {
  bool isLogin = true;
  
  // State untuk melihat/menyembunyikan password
  bool _isPasswordVisible = false;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  // Controller Animasi
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;

  AuthStatus _currentStatus = AuthStatus.idle;

  @override
  void initState() {
    super.initState();

    // 1. Setup Animasi Napas (Idle)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // 2. Setup Animasi Zoom Transisi
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _zoomAnimation = Tween<double>(begin: 1.0, end: 35.0).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInExpo),
    );

    // 3. Listener Focus
    _emailFocus.addListener(_updateStatus);
    _passFocus.addListener(_updateStatus);
  }

  void _updateStatus() {
    if (_currentStatus == AuthStatus.loading || _currentStatus == AuthStatus.success) return;

    if (_passFocus.hasFocus) {
      setState(() => _currentStatus = AuthStatus.typingPassword);
    } else if (_emailFocus.hasFocus) {
      setState(() => _currentStatus = AuthStatus.typingUsername);
    } else {
      setState(() => _currentStatus = AuthStatus.idle);
    }
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passFocus.dispose();
    _breathingController.dispose();
    _zoomController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  // --- LOGIC AUTH ---
  void _handleAuth() async {
    FocusScope.of(context).unfocus(); // Tutup keyboard

    setState(() => _currentStatus = AuthStatus.loading);

    // Simulasi Loading (Wajib ada biar animasinya sempat tampil di video)
    await Future.delayed(const Duration(seconds: 2));

    bool isSuccess = false;

    // --- SKENARIO 1: BYPASS UNTUK DEMO TUGAS ---
    // Gunakan ini saat merekam video agar pasti berhasil
    if (_emailCtrl.text == "admin" && _passCtrl.text == "123456") {
      isSuccess = true;
    } 
    // --- SKENARIO 2: KONEKSI FIREBASE ASLI ---
    else {
      final auth = ref.read(authProvider);
      if (isLogin) {
        // Kita tunggu (await) jawaban dari provider: true atau false?
        isSuccess = await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());
      } else {
        isSuccess = await auth.signUp(_emailCtrl.text.trim(), _passCtrl.text.trim(), _nameCtrl.text.trim());
      }
    }

    // --- EKSEKUSI ANIMASI BERDASARKAN HASIL ---
    if (isSuccess) {
      // 1. Ubah status jadi sukses (Ikon Centang Hijau)
      setState(() => _currentStatus = AuthStatus.success);
      
      // 2. Jalankan Animasi Zoom In
      await _zoomController.forward();

      // 3. Pindah Halaman ke Home
      Get.offAll(() => const HomePage(), transition: Transition.fade, duration: const Duration(milliseconds: 500));
      
    } else {
      // Gagal
      setState(() => _currentStatus = AuthStatus.failure);
      
      // Tahan ekspresi sedih 2 detik
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _currentStatus = AuthStatus.idle);
      
      // Jika demo admin salah password, kasih hint
      if (_emailCtrl.text == "admin" && _passCtrl.text != "123456") {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password Demo Salah! (Coba: 123456)"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _buildAnimatedAvatar() {
    IconData iconData;
    Color color;

    switch (_currentStatus) {
      case AuthStatus.typingPassword:
        // Kalau user tekan tombol "Lihat Password", maskotnya NGINTIP (Buka mata)
        iconData = _isPasswordVisible ? Icons.visibility : Icons.visibility_off_rounded;
        color = Colors.orange;
        break;
      case AuthStatus.typingUsername:
        iconData = Icons.person_outline_rounded;
        color = Colors.blue;
        break;
      case AuthStatus.loading:
        iconData = Icons.hourglass_top_rounded;
        color = Colors.grey;
        break;
      case AuthStatus.success:
        iconData = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case AuthStatus.failure:
        iconData = Icons.error_outline_rounded;
        color = Colors.red;
        break;
      case AuthStatus.idle:
      default:
        iconData = Icons.face_rounded;
        color = Colors.blueAccent;
        break;
    }

    return ScaleTransition(
      scale: _zoomAnimation,
      child: ScaleTransition(
        scale: _breathingAnimation,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Container(
            key: ValueKey<AuthStatus>(_currentStatus),
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: _currentStatus == AuthStatus.success ? color : color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
            ),
            child: Icon(
              iconData,
              size: 60,
              color: _currentStatus == AuthStatus.success ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        alignment: Alignment.center,
        children: [
          // LAYER 1: FORM (Di Bawah)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 140), // Spacer biar avatar punya tempat
                  
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _currentStatus == AuthStatus.success ? 0.0 : 1.0,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLogin ? "Masuk" : "Daftar",
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                            const SizedBox(height: 24),
                            
                            if (!isLogin) ...[
                              TextField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(labelText: "Nama Lengkap", prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            TextField(
                              controller: _emailCtrl,
                              focusNode: _emailFocus,
                              decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 16),
                            
                            // INPUT PASSWORD DENGAN FITUR LIHAT PASSWORD
                            TextField(
                              controller: _passCtrl,
                              focusNode: _passFocus,
                              obscureText: !_isPasswordVisible, // Logic hide/show
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(Icons.lock),
                                border: const OutlineInputBorder(),
                                // Tombol Mata (Suffix Icon)
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                      // Trigger update status biar maskotnya ngintip/tutup mata
                                      _updateStatus();
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _currentStatus == AuthStatus.loading || _currentStatus == AuthStatus.success ? null : _handleAuth,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: _currentStatus == AuthStatus.failure ? Colors.red : Colors.blueAccent,
                                ),
                                child: _currentStatus == AuthStatus.loading
                                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text(isLogin ? "MASUK" : "DAFTAR", style: const TextStyle(color: Colors.white)),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isLogin = !isLogin;
                                  _currentStatus = AuthStatus.idle;
                                });
                              },
                              child: Text(isLogin ? "Belum punya akun? Daftar sekarang" : "Sudah punya akun? Login"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // LAYER 2: AVATAR (Di Atas)
          Positioned(
            top: 80,
            child: _buildAnimatedAvatar(),
          ),
        ],
      ),
    );
  }
}