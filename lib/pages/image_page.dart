import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> with TickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF6DBE45);

  String? previewImg;

  String detected = "—";
  String status = "—";
  String confidence = "—";

  bool analyzing = false;
  Rect? boxRect;

  Timer? analyzeTimer;

  // fade animation
  late AnimationController fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  // ===== DỮ LIỆU GIẢ =====
  final fakeObjects = ["Mít chín", "Mít non", "Mít sâu bệnh"];

  final fakeStatus = [
    "Tốt – thu hoạch được",
    "Cần chăm thêm",
    "Dấu hiệu sâu bệnh",
  ];

  final fakeImages = [
    "assets/images/sample_ripen.png",
    "assets/images/sample_unripe.png",
    "assets/images/sample_disease.png",
  ];

  @override
  void dispose() {
    analyzeTimer?.cancel();
    fadeCtrl.dispose();
    super.dispose();
  }

  Rect randomBox() {
    final r = Random();
    return Rect.fromLTWH(
      40 + r.nextInt(80).toDouble(),
      40 + r.nextInt(80).toDouble(),
      120 + r.nextInt(60).toDouble(),
      120 + r.nextInt(40).toDouble(),
    );
  }

  void startAnalyze() {
    setState(() {
      analyzing = true;
      previewImg = null;
      boxRect = null;
    });

    analyzeTimer?.cancel();
    analyzeTimer = Timer(const Duration(seconds: 2), () {
      generateFakeResult();
    });
  }

  void generateFakeResult() {
    final r = Random();
    final idx = r.nextInt(3);

    setState(() {
      previewImg = fakeImages[idx];
      detected = fakeObjects[idx];
      status = fakeStatus[idx];
      confidence = "${70 + r.nextInt(30)}%";
      boxRect = randomBox();
      analyzing = false;
    });

    fadeCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FFEA),

      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Phân tích hình ảnh",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _previewBox(),

            const SizedBox(height: 20),

            _buttons(),

            const SizedBox(height: 30),

            _resultBox(),
          ],
        ),
      ),
    );
  }

  // ================= PREVIEW =================
  Widget _previewBox() {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Fade-in image
          previewImg != null
              ? FadeTransition(
                  opacity: fadeCtrl,
                  child: Image.asset(
                    previewImg!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Icon(Icons.image, size: 80, color: Colors.grey[400]),
                ),

          // bounding box + label
          if (boxRect != null)
            Positioned(
              left: boxRect!.left,
              top: boxRect!.top,
              child: Stack(
                children: [
                  Container(
                    width: boxRect!.width,
                    height: boxRect!.height,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.greenAccent, width: 3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Positioned(
                    top: -28,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        detected,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // overlay đang phân tích
          if (analyzing)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Đang phân tích...",
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ================= BUTTONS =================
  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: startAnalyze,
          icon: const Icon(Icons.upload, color: Colors.white),
          label: const Text("Tải ảnh lên"),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        ElevatedButton.icon(
          onPressed: startAnalyze,
          icon: const Icon(Icons.camera_alt, color: Colors.white),
          label: const Text("Chụp ảnh"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  // ================= RESULT =================
  Widget _resultBox() {
    final hasData = previewImg != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: hasData
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kết quả phân tích",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                _item("Nhận dạng:", detected),
                _item("Tình trạng:", status),
                _item("Độ tin cậy:", confidence),
              ],
            )
          : const Text(
              "Chưa có dữ liệu.\nNhấn tải ảnh lên hoặc chụp ảnh để phân tích.",
              style: TextStyle(fontSize: 15),
            ),
    );
  }

  Widget _item(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
