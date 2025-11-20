import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'change_password_page.dart';
import 'chat_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notify = true;
  bool cameraAccess = true;

  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    // ❗ KHÔNG init(context) ở đây nữa — dễ lỗi context null khi navigate
  }

  // TOAST GIỮ NGUYÊN ĐẸP NHƯ CŨ
  void showToast(String message, {bool success = true}) {
    fToast.removeQueuedCustomToasts();

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            color: success ? const Color(0xFF6DBE45) : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
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

  @override
  Widget build(BuildContext context) {
    // ❗ FIX LỖI: luôn reset context hợp lệ
    fToast.init(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FFE8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6DBE45),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Cài đặt",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          const Text(
            "Tùy chọn ứng dụng",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),

          _buildSwitchTile(
            icon: Icons.notifications_active,
            title: "Thông báo",
            value: notify,
            onChanged: (v) {
              setState(() => notify = v);
              showToast(
                v ? "Đã bật thông báo" : "Đã tắt thông báo",
                success: v,
              );
            },
          ),

          _buildSwitchTile(
            icon: Icons.camera_alt,
            title: "Quyền truy cập camera",
            value: cameraAccess,
            onChanged: (v) {
              setState(() => cameraAccess = v);
              showToast(
                v ? "Đã cho phép truy cập camera" : "Đã tắt quyền camera",
                success: v,
              );
            },
          ),

          const SizedBox(height: 25),

          const Text(
            "Tài khoản & Bảo mật",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),

          _buildNavTile(
            icon: Icons.lock_reset,
            title: "Đổi mật khẩu",
            subtitle: "Cập nhật mật khẩu đăng nhập",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              );
            },
          ),

          _buildNavTile(
            icon: Icons.security,
            title: "Bảo mật",
            subtitle: "Xác thực & quyền truy cập",
            onTap: () => showToast("Tính năng đang phát triển", success: false),
          ),

          _buildNavTile(
            icon: Icons.delete,
            title: "Xóa lịch sử chat",
            subtitle: "Xóa toàn bộ hội thoại với AI",
            onTap: () async {
              final user = Supabase.instance.client.auth.currentUser;
              if (user == null) return;

              await ChatStorage.clearMessages(user.id);

              showToast("Đã xoá lịch sử chat");
            },
          ),

          _buildNavTile(
            icon: Icons.delete_sweep,
            title: "Xóa lịch sử so sánh mô hình",
            subtitle: "Xóa toàn bộ lịch sử so sánh",
            onTap: () async {
              final supabase = Supabase.instance.client;
              final user = supabase.auth.currentUser;

              if (user == null) {
                showToast("Bạn chưa đăng nhập!", success: false);
                return;
              }

              try {
                await supabase
                    .from("compare_history")
                    .delete()
                    .eq("user_id", user.id);

                showToast("Đã xoá toàn bộ lịch sử so sánh");
              } catch (e) {
                showToast("Lỗi khi xóa!", success: false);
              }
            },
          ),

          const SizedBox(height: 25),

          const Text(
            "Thông tin",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),

          _buildNavTile(
            icon: Icons.info,
            title: "Giới thiệu",
            subtitle: "Thông tin về AgriVision",
            onTap: () => Navigator.pushNamed(context, "/about"),
          ),

          _buildNavTile(
            icon: Icons.contact_support,
            title: "Hỗ trợ",
            subtitle: "Liên hệ đội ngũ phát triển",
            onTap: () =>
                showToast("Liên hệ: agrivision.duy@gmail.com", success: true),
          ),

          _buildNavTile(
            icon: Icons.article,
            title: "Điều khoản & riêng tư",
            subtitle: "Chính sách sử dụng",
            onTap: () => showToast("Tính năng đang phát triển", success: false),
          ),

          _buildNavTile(
            icon: Icons.info_outline,
            title: "Phiên bản ứng dụng",
            subtitle: "AgriVision v1.0.0",
            onTap: () => showToast("Phiên bản: 1.0.0", success: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SwitchListTile(
        dense: true,
        title: Text(title),
        secondary: Icon(icon, color: const Color(0xFF6DBE45)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF6DBE45)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
