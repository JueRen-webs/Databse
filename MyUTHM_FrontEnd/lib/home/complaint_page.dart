import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

// ==========================================
// C. Complaint
// ==========================================

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});
  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final List<Map<String, String>> reports = [
    {
      "id": "20250400324",
      "title": "Paip broken",
      "location": "L2-05C",
      "status": "END",
      "updateBy": "MHNAZRI",
      "updateTime": "07/04/2025 04:25 PTG"
    }
  ];

  void _navigateToNewReport() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const NewComplaintPage()));
    if (result != null && result is Map<String, String>) {
      setState(() => reports.insert(0, result));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("New Complaint Created Successfully")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Complaint",
            style: GoogleFonts.inter(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text("Reports",
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: reports.isEmpty
                  ? const Center(child: Text("No complaints found"))
                  : ListView.separated(
                      itemCount: reports.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (ctx, idx) {
                        final r = reports[idx];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ComplaintDetailPage())),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.apartment,
                                          color: Colors.green, size: 30),
                                      Text(r["id"]!,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(r["title"]!,
                                            style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight:
                                                    FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 6,
                                              vertical: 2),
                                          decoration: BoxDecoration(
                                            color: kPrimaryBlue,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(r["location"]!,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.bold)),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Update: ${r["updateBy"]} • ${r["updateTime"]}",
                                          style: TextStyle(
                                              fontSize: 11,
                                              color:
                                                  Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade400),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: const Text("View",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToNewReport,
        backgroundColor: kPrimaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Report",
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ==========================================
// NewComplaintPage
// ==========================================

class NewComplaintPage extends StatefulWidget {
  const NewComplaintPage({super.key});
  @override
  State<NewComplaintPage> createState() => _NewComplaintPageState();
}

class _NewComplaintPageState extends State<NewComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();

  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              const Center(child: CircularProgressIndicator()));
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pop(context);
      final newReport = {
        "id":
            "2025${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        "title": _titleController.text,
        "type": "facility",
        "location": _locationController.text,
        "status": "PENDING",
        "updateBy": "YOU",
        "updateTime": "Just Now"
      };
      if (!mounted) return;
      Navigator.pop(context, newReport);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Complaint",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                    labelText: "Location",
                    border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue),
                  child: const Text("Submit",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// ComplaintDetailPage
// ==========================================

class ComplaintDetailPage extends StatelessWidget {
  const ComplaintDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Report Details",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTimelineItem(
              date: "06 Apr, 2025",
              headerColor: const Color(0xFF6F42C1),
              icon: Icons.email_outlined,
              title: "AI240160 Proses DiHantar",
              tag: "SND",
              time: "03:53:18 PTG",
              content: "Paip broken",
            ),
            _buildTimelineItem(
              date: "07 Apr, 2025",
              headerColor: const Color(0xFF28A745),
              icon: Icons.person,
              title: "MHNAZRI Proses DiTerima",
              tag: "RCV",
              time: "09:24:32 PG",
              content: "TINDAKAN CONSTANT",
            ),
            _buildTimelineItem(
              date: "15 Apr, 2025",
              headerColor: const Color(0xFF17A2B8),
              icon: Icons.person,
              title: "MHNAZRI Proses Selesai",
              tag: "END",
              time: "11:02:59 PG",
              content: "SELESAI",
              isEnd: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String date,
    required Color headerColor,
    required IconData icon,
    required String title,
    required String tag,
    required String time,
    required String content,
    bool isEnd = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(date,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(icon, color: headerColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    color: kPrimaryBlue,
                                    fontWeight: FontWeight.bold)),
                            Text(time,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(tag,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: isEnd
                      ? Row(
                          children: [
                            Text(content),
                            const SizedBox(width: 5),
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 16),
                          ],
                        )
                      : Text(content),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
