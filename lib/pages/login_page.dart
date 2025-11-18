import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/widgets/custom_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFE8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/images/logo.svg", height: 120),
              const SizedBox(height: 12),

              const Text(
                "AGRI VISION",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const Text(
                "Ứng dụng nhận dạng và phân loại độ chín trái mít",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 35),

              CustomInput(
                icon: Icons.email,
                label: "Email",
                hint: "example@gmail.com",
                controller: emailCtrl,
              ),
              const SizedBox(height: 20),

              CustomInput(
                icon: Icons.lock,
                label: "Mật khẩu",
                hint: "Nhập mật khẩu...",
                controller: passCtrl,
                obscure: obscure,
                onToggleObscure: () {
                  setState(() => obscure = !obscure);
                },
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = emailCtrl.text.trim();
                    final pass = passCtrl.text.trim();

                    if (email.isEmpty || pass.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Vui lòng nhập đầy đủ thông tin"),
                        ),
                      );
                      return;
                    }

                    try {
                      final res = await Supabase.instance.client.auth
                          .signInWithPassword(email: email, password: pass);

                      final user = res.user;

                      if (user == null) {
                        throw "Không tìm thấy người dùng";
                      }

                      if (user.emailConfirmedAt == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Email chưa được xác thực! Vui lòng kiểm tra email của bạn.",
                            ),
                            duration: Duration(seconds: 4),
                          ),
                        );
                        return;
                      }

                      Navigator.pushReplacementNamed(context, "/home");
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Sai email hoặc mật khẩu"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6DBE45),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Đăng nhập",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chưa có tài khoản? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/register");
                    },
                    child: const Text(
                      "Đăng ký",
                      style: TextStyle(
                        color: Color(0xFF6DBE45),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
