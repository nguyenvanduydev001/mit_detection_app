import 'dart:async';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> with TickerProviderStateMixin {
  String mode = "video";
  String? selectedFile;
  bool webcamActive = false;

  double confidence = 0.8;

  Timer? webcamTimer;
  Timer? videoTimer;

  // Fake preview image
  String? previewImg;

  // Animation for fade-in
  late AnimationController fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  // Animation for mode switch
  late AnimationController switchCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  // Fake bounding box
  Rect? fakeBox;

  // =============================
  //   DATA
  // =============================
  final fakeObjects = ["Mít chín", "Mít non", "Mít sâu bệnh"];
  final fakeStatus = ["Tốt", "Cần theo dõi", "Cần xử lý"];
  final fakeImages = [
    "assets/images/sample_ripen.png",
    "assets/images/sample_unripe.png",
    "assets/images/sample_disease.png",
  ];

  String detected = "—";
  String status = "—";
  String count = "—";

  @override
  void dispose() {
    webcamTimer?.cancel();
    videoTimer?.cancel();
    fadeCtrl.dispose();
    switchCtrl.dispose();
    super.dispose();
  }

  Rect _randomBox() {
    final r = Random();
    return Rect.fromLTWH(
      40 + r.nextInt(80).toDouble(),
      40 + r.nextInt(80).toDouble(),
      120 + r.nextInt(60).toDouble(),
      120 + r.nextInt(50).toDouble(),
    );
  }

  void generateResult() {
    final r = Random();
    final idx = r.nextInt(3);

    setState(() {
      previewImg = fakeImages[idx];
      detected = fakeObjects[idx];
      status = fakeStatus[idx];
      confidence = 0.6 + r.nextDouble() * 0.4;

      count = idx == 0
          ? "1 trái (mít chín)"
          : idx == 1
          ? "3 trái (mít non)"
          : "1 trái (mít sâu bệnh)";

      fakeBox = _randomBox();
    });

    fadeCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6DBE45),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Phân tích Video / Webcam",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ScaleTransition(
              scale: Tween(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: switchCtrl, curve: Curves.easeOut),
              ),
              child: _modeSelector(),
            ),

            const SizedBox(height: 20),
            _preview(),
            const SizedBox(height: 20),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: mode == "video" ? _uploadBtn() : _webcamBtn(),
            ),

            const SizedBox(height: 25),
            _confidenceSlider(),
            const SizedBox(height: 20),

            _resultBox(),
          ],
        ),
      ),
    );
  }

  // ================= MODE PICKER =================
  Widget _modeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          _modeItem("video", Icons.video_file, "Video"),
          _modeItem("webcam", Icons.videocam, "Webcam"),
        ],
      ),
    );
  }

  Widget _modeItem(String id, IconData icon, String label) {
    final active = id == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          switchCtrl.forward(from: 0);

          webcamTimer?.cancel();
          videoTimer?.cancel();

          setState(() {
            mode = id;
            previewImg = null;
            fakeBox = null;
            selectedFile = null;
            webcamActive = false;
            detected = "—";
            status = "—";
            count = "—";
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF6DBE45) : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            children: [
              Icon(icon, color: active ? Colors.white : Colors.grey[700]),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PREVIEW + OVERLAY =================
  Widget _preview() {
    final analyzing =
        (selectedFile != null && previewImg == null) ||
        (webcamActive && previewImg == null);

    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6DBE45), width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
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
                  child: Icon(
                    mode == "video" ? Icons.video_file : Icons.videocam,
                    size: 90,
                    color: Colors.white70,
                  ),
                ),

          if (fakeBox != null)
            Positioned(
              left: fakeBox!.left,
              top: fakeBox!.top,
              child: Container(
                width: fakeBox!.width,
                height: fakeBox!.height,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

          if (analyzing)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Đang phân tích…",
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
  Widget _uploadBtn() {
    return ElevatedButton.icon(
      onPressed: () async {
        final picked = await FilePicker.platform.pickFiles(
          type: FileType.video,
        );

        if (picked != null) {
          setState(() {
            previewImg = null;
            fakeBox = null;
            selectedFile = picked.files.first.name;
          });

          // Simulate 10-second analysis
          videoTimer?.cancel();
          videoTimer = Timer(const Duration(seconds: 10), () {
            generateResult();
          });
        }
      },
      icon: const Icon(Icons.upload, color: Colors.white),
      label: const Text("Tải video lên", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6DBE45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _webcamBtn() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() => webcamActive = !webcamActive);

        if (webcamActive) {
          previewImg = null;
          fakeBox = null;

          generateResult();
          webcamTimer = Timer.periodic(const Duration(seconds: 1), (_) {
            generateResult();
          });
        } else {
          webcamTimer?.cancel();
        }
      },
      icon: Icon(
        webcamActive ? Icons.stop : Icons.videocam,
        color: Colors.white,
      ),
      label: Text(
        webcamActive ? "Dừng Webcam" : "Bắt đầu Webcam",
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: webcamActive ? Colors.red : const Color(0xFF6DBE45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ================= SLIDER =================
  Widget _confidenceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Độ tin cậy",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: confidence,
          min: 0.2,
          max: 1.0,
          divisions: 8,
          activeColor: const Color(0xFF6DBE45),
          onChanged: (v) => setState(() => confidence = v),
        ),
      ],
    );
  }

  // ================= RESULT =================
  Widget _resultBox() {
    final hasData = previewImg != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: hasData
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kết quả",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _row("Nhận dạng:", detected),
                _row("Số trái:", count),
                _row("Độ tin cậy:", "${(confidence * 100).round()}%"),
                _row("Tình trạng:", status),
              ],
            )
          : const Text(
              "Chưa có dữ liệu.\nTải video hoặc bật webcam để phân tích.",
              style: TextStyle(fontSize: 15),
            ),
    );
  }

  Widget _row(String a, String b) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              a,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          Expanded(
            child: Text(
              b,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
