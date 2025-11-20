import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/widgets/menu_item.dart';
import '/pages/image_page.dart';
import '/pages/video_page.dart';
import '/pages/stat_page.dart';
import '/pages/compare_page.dart';
import '/pages/chat_page.dart';
import '/pages/account_page.dart';
import '/pages/about_page.dart';
import '/pages/settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFE8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF6DBE45),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Xin chào 👋",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Chào mừng đến AgriVision!",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ===== GRID MENU =====
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 0.95,
                children: [
                  // Trang chủ -> AboutPage
                  MenuItem(
                    icon: Icons.home,
                    title: "Trang chủ",
                    subtitle: "Giới thiệu hệ thống",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    ),
                  ),

                  // Cài đặt
                  MenuItem(
                    icon: Icons.settings,
                    title: "Cài đặt",
                    subtitle: "Tùy chỉnh ứng dụng",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                  ),

                  // Phân tích ảnh
                  MenuItem(
                    icon: Icons.image_search,
                    title: "Phân tích ảnh",
                    subtitle: "Upload & nhận dạng",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ImagePage()),
                    ),
                  ),

                  // Video / Webcam – cho xuống 2 dòng
                  MenuItem(
                    icon: Icons.videocam,
                    title: "Video\nWebcam",
                    subtitle: "Phát hiện real-time",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VideoPage()),
                    ),
                  ),

                  // Thống kê
                  MenuItem(
                    icon: Icons.bar_chart,
                    title: "Thống kê",
                    subtitle: "Hiển thị dữ liệu",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StatPage()),
                    ),
                  ),

                  // So sánh YOLOv8 – 2 dòng
                  MenuItem(
                    icon: Icons.compare,
                    title: "So sánh\nYOLOv8",
                    subtitle: "Đánh giá model",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ComparePage()),
                    ),
                  ),

                  // Chat AgriVision – 2 dòng
                  MenuItem(
                    icon: Icons.chat,
                    title: "Chat\nAgriVision",
                    subtitle: "Tương tác AI",
                    onTap: () {
                      final user = Supabase.instance.client.auth.currentUser;
                      if (user == null) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(userId: user.id),
                        ),
                      );
                    },
                  ),

                  // Tài khoản
                  MenuItem(
                    icon: Icons.person,
                    title: "Tài khoản",
                    subtitle: "Thông tin cá nhân",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AccountPage()),
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
