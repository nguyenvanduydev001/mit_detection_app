import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  Map<String, double>? modelA;
  Map<String, double>? modelB;

  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
  }

  // ================== TOAST ĐẸP ==================
  void showToast(String message, {bool success = true}) {
    fToast.removeQueuedCustomToasts();

    final toast = Container(
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

  // ================== Lưu lịch sử vào Supabase ==================
  Future<void> saveCompareHistory() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        showToast("Bạn chưa đăng nhập!", success: false);
        return;
      }

      await supabase.from("compare_history").insert({
        "user_id": user.id,
        "model_a": modelA,
        "model_b": modelB,
      });

      showToast("Đã lưu lịch sử so sánh");
    } catch (e) {
      debugPrint("SAVE ERROR: $e");
      showToast("Lưu thất bại!", success: false);
    }
  }

  // ================== Convert chuỗi sang double ==================
  double toDouble(String? v) {
    if (v == null) return 0.0;
    return double.tryParse(v.trim()) ?? 0.0;
  }

  // ================== Parse CSV YOLO ==================
  Future<Map<String, double>?> parseCSV(Uint8List data) async {
    try {
      final content = utf8.decode(data);
      final lines = content
          .split("\n")
          .where((e) => e.trim().isNotEmpty)
          .toList();

      if (lines.length < 2) return null;

      final header = lines.first.split(",");
      final last = lines.last.split(",");

      Map<String, String> row = {};
      for (int i = 0; i < header.length; i++) {
        row[header[i].trim().toLowerCase()] = (i < last.length)
            ? last[i].trim()
            : "0";
      }

      double p = toDouble(row["metrics/precision(b)"]);
      double r = toDouble(row["metrics/recall(b)"]);
      double map50 = toDouble(row["metrics/map50(b)"]);
      double map5095 = toDouble(row["metrics/map50-95(b)"]);

      // F1 = 2PR / (P+R)
      double f1 = (p + r == 0) ? 0 : 2 * p * r / (p + r);

      return {
        "precision": p,
        "recall": r,
        "f1": f1,
        "map50": map50,
        "map5095": map5095,
      };
    } catch (e) {
      debugPrint("CSV ERROR: $e");
      return null;
    }
  }

  // ================== Chọn file CSV ==================
  Future<void> pickCSV(bool isA) async {
    final picked = await FilePicker.platform.pickFiles(withData: true);
    if (picked == null || picked.files.first.bytes == null) return;

    final parsed = await parseCSV(picked.files.first.bytes!);
    if (parsed == null) {
      showToast("CSV không hợp lệ!", success: false);
      return;
    }

    setState(() {
      if (isA) {
        modelA = parsed;
        showToast("Model A đã tải thành công");
      } else {
        modelB = parsed;
        showToast("Model B đã tải thành công");
      }
    });

    // Auto save nếu đủ 2 model
    if (modelA != null && modelB != null) saveCompareHistory();
  }

  // ================== TABLE ==================
  Widget buildTable() {
    if (modelA == null || modelB == null) return Container();

    final metrics = ["precision", "recall", "f1", "map50", "map5095"];
    const labels = {
      "precision": "PRECISION",
      "recall": "RECALL",
      "f1": "F1 SCORE",
      "map50": "mAP50",
      "map5095": "mAP50-95",
    };

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.green.shade100),
              children: const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Chỉ số",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Model A",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Model B",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            ...metrics.map(
              (m) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(labels[m]!),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(modelA![m]!.toStringAsFixed(3)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(modelB![m]!.toStringAsFixed(3)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== Bar Chart ==================
  Widget buildChart() {
    if (modelA == null || modelB == null) return const SizedBox();

    const labels = ["P", "R", "F1", "m50", "m50-95"];
    final metrics = ["precision", "recall", "f1", "map50", "map5095"];

    return SizedBox(
      height: 320,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: true, drawVerticalLine: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(labels[v.toInt()]),
                ),
              ),
            ),
          ),
          barGroups: List.generate(
            metrics.length,
            (i) => BarChartGroupData(
              x: i,
              barsSpace: 14,
              barRods: [
                BarChartRodData(
                  toY: modelA![metrics[i]]!,
                  width: 18,
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                BarChartRodData(
                  toY: modelB![metrics[i]]!,
                  width: 18,
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    fToast.init(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FFE8),
      appBar: AppBar(
        title: const Text(
          "So sánh mô hình YOLOv8",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6DBE45),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          uploadCard("Tải CSV cho Model A", Colors.green, () => pickCSV(true)),
          const SizedBox(height: 16),
          uploadCard(
            "Tải CSV cho Model B",
            Colors.orange,
            () => pickCSV(false),
          ),
          const SizedBox(height: 16),
          if (modelA != null && modelB != null) buildTable(),
          if (modelA != null && modelB != null) buildChart(),
        ],
      ),
    );
  }

  // ================== Upload Button ==================
  Widget uploadCard(String label, Color color, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: Icon(Icons.file_upload_outlined, color: color, size: 32),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
