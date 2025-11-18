import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/widgets/custom_input.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFE8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 60),
        child: Column(
          children: [
            SvgPicture.asset("assets/images/logo.svg", height: 120),
            const SizedBox(height: 15),

            const Text(
              "AGRI VISION",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6DBE45),
              ),
            ),
            const SizedBox(height: 10),

            CustomInput(
              icon: Icons.email,
              label: "Địa chỉ email",
              hint: "example@gmail.com",
              controller: emailCtrl,
            ),
            const SizedBox(height: 20),

            CustomInput(
              icon: Icons.lock,
              label: "Mật khẩu",
              hint: "Nhập mật khẩu...",
              controller: passCtrl,
              obscure: obscure1,
              onToggleObscure: () => setState(() => obscure1 = !obscure1),
            ),
            const SizedBox(height: 20),

            CustomInput(
              icon: Icons.lock_outline,
              label: "Xác nhận mật khẩu",
              hint: "Nhập lại mật khẩu...",
              controller: confirmCtrl,
              obscure: obscure2,
              onToggleObscure: () => setState(() => obscure2 = !obscure2),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final email = emailCtrl.text.trim();
                  final pass = passCtrl.text.trim();
                  final confirm = confirmCtrl.text.trim();

                  if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Vui lòng nhập đầy đủ thông tin"),
                      ),
                    );
                    return;
                  }

                  if (pass != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Mật khẩu không khớp")),
                    );
                    return;
                  }

                  try {
                    await Supabase.instance.client.auth.signUp(
                      email: email,
                      password: pass,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Đăng ký thành công! Hãy kiểm tra email để xác thực.",
                        ),
                        duration: Duration(seconds: 4),
                      ),
                    );

                    Navigator.pushReplacementNamed(context, "/login");
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
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
                  "Tạo tài khoản",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Đã có tài khoản? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                  child: const Text(
                    "Đăng nhập",
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
    );
  }
}
