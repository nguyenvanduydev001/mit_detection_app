import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatPage extends StatefulWidget {
  const StatPage({super.key});

  @override
  State<StatPage> createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  List<dynamic> history = [];
  bool loadingHistory = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // ================= LOAD SUPABASE =================
  Future<void> loadHistory() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() => loadingHistory = false);
        return;
      }

      final res = await supabase
          .from("compare_history")
          .select()
          .eq("user_id", user.id)
          .order("created_at", ascending: false);

      setState(() {
        history = res;
        loadingHistory = false;
      });
    } catch (e) {
      debugPrint("LOAD ERROR: $e");
      setState(() => loadingHistory = false);
    }
  }

  // ========================== UI SECTION TITLE ==========================
  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF447A2E),
        ),
      ),
    );
  }

  // ========================== 1) ẢNH ==========================
  Widget buildImageStats() {
    // Fake data
    final totalImages = 134;
    final diseased = 48;
    final healthy = totalImages - diseased;

    final percentDisease = (diseased / totalImages * 100).toStringAsFixed(1);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.image, color: Color(0xFF6DBE45)),
                SizedBox(width: 10),
                Text(
                  "Thống kê phân tích ảnh",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            statRow("Tổng ảnh đã phân tích", "$totalImages ảnh"),
            statRow("Ảnh phát hiện bệnh", "$diseased ảnh"),
            statRow("Ảnh bình thường", "$healthy ảnh"),
            statRow("Tỷ lệ bệnh", "$percentDisease%"),
          ],
        ),
      ),
    );
  }

  // ========================== 2) VIDEO / WEBCAM ==========================
  Widget buildVideoStats() {
    // Fake data
    final videoCount = 21;
    final avgDuration = "14.2 giây";
    final detections = 63;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.videocam, color: Color(0xFF6DBE45)),
                SizedBox(width: 10),
                Text(
                  "Thống kê video / webcam",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            statRow("Số video đã phân tích", "$videoCount lần"),
            statRow("Thời gian phân tích TB", avgDuration),
            statRow("Tổng số đối tượng phát hiện", "$detections lần"),
          ],
        ),
      ),
    );
  }

  // ========================== 3) LỊCH SỬ COMPARE MODEL ==========================
  Widget buildCompareCard(Map record) {
    final modelA = record["model_a"];
    final modelB = record["model_b"];

    final rawTime = record["created_at"];
    final time = rawTime == null
        ? "Không rõ thời gian"
        : DateFormat(
            "dd/MM/yyyy - HH:mm",
          ).format(DateTime.parse(rawTime).toLocal());

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.history, color: Color(0xFF6DBE45)),
                SizedBox(width: 8),
                Text(
                  "Lịch sử so sánh",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(time, style: const TextStyle(color: Colors.black54)),

            const SizedBox(height: 14),

            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                tableHeader(),
                tableRow("Precision", modelA["precision"], modelB["precision"]),
                tableRow("Recall", modelA["recall"], modelB["recall"]),
                tableRow("F1-score", modelA["f1"], modelB["f1"]),
                tableRow("mAP50", modelA["map50"], modelB["map50"]),
                tableRow("mAP50-95", modelA["map5095"], modelB["map5095"]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow tableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.green.shade100),
      children: const [
        Padding(
          padding: EdgeInsets.all(10),
          child: Text("Chỉ số", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Text("Model A", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Text("Model B", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  TableRow tableRow(String label, double a, double b) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(10), child: Text(label)),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            a.toStringAsFixed(3),
            style: const TextStyle(color: Colors.green),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            b.toStringAsFixed(3),
            style: const TextStyle(color: Colors.orange),
          ),
        ),
      ],
    );
  }

  Widget statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6DBE45),
            ),
          ),
        ],
      ),
    );
  }

  // ========================== PAGE BUILD ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6DBE45),
        centerTitle: true,
        title: const Text(
          "Thống kê dữ liệu",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // === 1) ẢNH ===
          sectionTitle("Ảnh đã phân tích"),
          buildImageStats(),

          // === 2) VIDEO ===
          sectionTitle("Video / Webcam"),
          buildVideoStats(),

          // === 3) LỊCH SỬ SO SÁNH MODEL ===
          sectionTitle("Lịch sử so sánh mô hình YOLO"),
          loadingHistory
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6DBE45)),
                )
              : history.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text("Chưa có lịch sử")),
                )
              : Column(children: [...history.map((e) => buildCompareCard(e))]),
        ],
      ),
    );
  }
}
