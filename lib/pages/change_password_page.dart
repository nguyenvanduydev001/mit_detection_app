import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

const primaryColor = Color(0xFF6DBE45);

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController oldPass = TextEditingController();
  final TextEditingController newPass = TextEditingController();
  final TextEditingController confirmPass = TextEditingController();

  bool loading = false;
  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;

  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  void showToast(String message, {bool success = false}) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? primaryColor : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  // -----------------------------
  // Xử lý đổi mật khẩu
  // -----------------------------
  Future<void> changePassword() async {
    final client = Supabase.instance.client;

    if (newPass.text != confirmPass.text) {
      showToast("Mật khẩu xác nhận không khớp!");
      return;
    }

    if (newPass.text.length < 6) {
      showToast("Mật khẩu mới cần ít nhất 6 ký tự.");
      return;
    }

    setState(() => loading = true);

    try {
      final email = client.auth.currentUser!.email!;

      // Re-auth
      final signInResp = await client.auth.signInWithPassword(
        email: email,
        password: oldPass.text,
      );

      if (signInResp.user == null) {
        showToast("Mật khẩu hiện tại không đúng!");
        setState(() => loading = false);
        return;
      }

      // Đổi mật khẩu
      final response = await client.auth.updateUser(
        UserAttributes(password: newPass.text),
      );

      if (response.user != null) {
        showToast("Đổi mật khẩu thành công!", success: true);
        Navigator.pop(context);
      }
    } catch (e) {
      showToast("Lỗi: $e");
    }

    setState(() => loading = false);
  }

  // -----------------------------
  // UI Input
  // -----------------------------
  InputDecoration _field(String label, bool show, VoidCallback toggle) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      suffixIcon: IconButton(
        icon: Icon(show ? Icons.visibility : Icons.visibility_off),
        onPressed: toggle,
      ),
    );
  }

  // -----------------------------
  // UI BUILD
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F2),
      appBar: AppBar(
        title: const Text("Đổi mật khẩu"),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mật khẩu cũ
                TextField(
                  controller: oldPass,
                  obscureText: !showOld,
                  decoration: _field(
                    "Mật khẩu hiện tại",
                    showOld,
                    () => setState(() => showOld = !showOld),
                  ),
                ),

                const SizedBox(height: 18),

                // Mật khẩu mới
                TextField(
                  controller: newPass,
                  obscureText: !showNew,
                  decoration: _field(
                    "Mật khẩu mới",
                    showNew,
                    () => setState(() => showNew = !showNew),
                  ),
                ),

                const SizedBox(height: 18),

                // Nhập lại mật khẩu
                TextField(
                  controller: confirmPass,
                  obscureText: !showConfirm,
                  decoration: _field(
                    "Nhập lại mật khẩu mới",
                    showConfirm,
                    () => setState(() => showConfirm = !showConfirm),
                  ),
                ),

                const SizedBox(height: 28),

                // Nút xác nhận
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loading ? null : changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Xác nhận đổi mật khẩu",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
