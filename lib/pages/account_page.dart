import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'change_password_page.dart';

const primaryColor = Color(0xFF6DBE45);

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  // Hàm format thời gian đẹp
  String formatDate(String isoString) {
    final date = DateTime.parse(isoString).toLocal();
    return DateFormat('dd/MM/yyyy - HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Thông tin tài khoản"),
        centerTitle: true,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const Center(child: Text("Không tìm thấy người dùng"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 48,
                    // ignore: deprecated_member_use
                    backgroundColor: primaryColor.withOpacity(0.25),
                    child: Text(
                      user.email![0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email
                  Text(
                    user.email ?? "",
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Card thông tin
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _infoRow("User ID", user.id),
                          const Divider(),
                          _infoRow("Email", user.email ?? ""),
                          const Divider(),
                          _infoRow(
                            "Trạng thái",
                            user.emailConfirmedAt == null
                                ? "Chưa xác thực"
                                : "Đã xác thực",
                          ),
                          const Divider(),
                          _infoRow(
                            "Tham gia lúc",
                            user.createdAt != null
                                ? formatDate(user.createdAt!)
                                : "Không rõ",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Nút đổi mật khẩu
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.lock_reset, color: Colors.white),
                    label: const Text(
                      "Đổi mật khẩu",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Nút đăng xuất
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, "/login");
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.logout, color: primaryColor),
                    label: Text(
                      "Đăng xuất",
                      style: TextStyle(color: primaryColor, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Custom row thông tin
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
