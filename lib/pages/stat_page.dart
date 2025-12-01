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
  List<dynamic> imageHistory = [];
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

      // Lịch sử so sánh model
      final compareRes = await supabase
          .from("compare_history")
          .select()
          .eq("user_id", user.id)
          .order("created_at", ascending: false);

      // Lịch sử phân tích ảnh
      final imageRes = await supabase
          .from("jackfruit_history")
          .select()
          .eq("user_id", user.id)
          .order("created_at", ascending: false);

      setState(() {
        history = compareRes;
        imageHistory = imageRes;
        loadingHistory = false;
      });
    } catch (e) {
      debugPrint("LOAD ERROR: $e");
      setState(() => loadingHistory = false);
    }
  }

  // ========================== LABEL MAP ==========================
  String mapLabel(String raw) {
    switch (raw) {
      case "mit_chin":
        return "Mít chín";
      case "mit_non":
        return "Mít non";
      case "mit_saubenh":
        return "Mít sâu bệnh";
      default:
        return raw;
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

  // ========================== COMPARE MODEL CARD ==========================
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

  // ========================== PAGE UI ==========================
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
          // === LỊCH SỬ PHÂN TÍCH ẢNH ===
          sectionTitle("Lịch sử phân tích hình ảnh"),
          loadingHistory
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6DBE45)),
                )
              : imageHistory.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "Chưa có dữ liệu phân tích.\nVui lòng tải ảnh để phân tích!",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: imageHistory.map((item) {
                    final imageUrl = item["image_url"];
                    final label = mapLabel(
                      item["label"],
                    ); // ✨ đổi sang tiếng Việt
                    final conf = ((item["confidence"] ?? 0.0) * 100)
                        .toStringAsFixed(1);

                    final rawTime = item["created_at"];
                    final time = rawTime == null
                        ? "Không rõ thời gian"
                        : DateFormat(
                            "dd/MM/yyyy - HH:mm",
                          ).format(DateTime.parse(rawTime).toLocal());

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text("Độ tin cậy: $conf%"),
                                  Text(
                                    time,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

          // === LỊCH SỬ SO SÁNH MODEL ===
          sectionTitle("Lịch sử so sánh mô hình YOLO"),
          loadingHistory
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6DBE45)),
                )
              : history.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "Chưa có dữ liệu so sánh.\nVui lòng so sánh để hiển thị!",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(children: [...history.map((e) => buildCompareCard(e))]),
        ],
      ),
    );
  }
}
