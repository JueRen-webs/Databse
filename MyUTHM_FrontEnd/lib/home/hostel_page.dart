import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

// ==========================================
// Hostel 入口菜单
// ==========================================

void showHostelMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text("Hostel Services",
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.app_registration, color: kPrimaryBlue),
              title: const Text("Registration"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const HostelRegistrationFormPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.flash_on, color: Colors.amber),
              title: const Text("Electrical Sticker"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ElectricalStickerPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.report_problem_outlined,
                  color: Colors.redAccent),
              title: const Text("Complaint (Aduan)"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ComplaintPage()));
              },
            ),
          ],
        ),
      );
    },
  );
}

// ==========================================
// 1. Hostel Registration Form
// ==========================================

class HostelRegistrationFormPage extends StatefulWidget {
  const HostelRegistrationFormPage({super.key});

  @override
  State<HostelRegistrationFormPage> createState() =>
      _HostelRegistrationFormPageState();
}

class _HostelRegistrationFormPageState
    extends State<HostelRegistrationFormPage> {
  String? selectedBlock;
  final TextEditingController roomController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<String> blocks = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'N'];

  void _submitForm() async {
    if (_formKey.currentState!.validate() && selectedBlock != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator()),
      );
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pop(context);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HostelResultPage(
              block: selectedBlock!, room: roomController.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete the form")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Hostel Registration",
            style: GoogleFonts.inter(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Your Accommodation",
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              LayoutBuilder(builder: (context, constraints) {
                return DropdownMenu<String>(
                  width: constraints.maxWidth,
                  initialSelection: selectedBlock,
                  label: const Text("Block"),
                  onSelected: (val) => setState(() => selectedBlock = val),
                  dropdownMenuEntries: blocks
                      .map((val) =>
                          DropdownMenuEntry(value: val, label: "Block $val"))
                      .toList(),
                );
              }),
              const SizedBox(height: 20),
              TextFormField(
                controller: roomController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitForm(),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Z]'))
                ],
                decoration: InputDecoration(
                  labelText: "Room Number",
                  hintText: "e.g. 404A",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.meeting_room),
                ),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text("Submit Application",
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
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
// 2. Hostel Result Page
// ==========================================

class HostelResultPage extends StatelessWidget {
  final String block;
  final String room;
  const HostelResultPage({super.key, required this.block, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Registration Result",
            style: GoogleFonts.inter(
                color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 10),
                Text("Application Successful",
                    style: GoogleFonts.inter(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ]),
              child: Column(children: [
                _buildInfoRow("Name", "Lee Rou"),
                const Divider(),
                _buildInfoRow("Metric No.", "AI210254"),
                const Divider(),
                _buildInfoRow("College", "Kolej Kediaman Tun Dr. Ismail"),
                const Divider(),
                _buildInfoRow("Block", block, isHighlight: true),
                const Divider(),
                _buildInfoRow("Room", room, isHighlight: true),
                const Divider(),
                _buildInfoRow("Semester", "1 2024/2025"),
                const Divider(),
                _buildInfoRow("Status", "Approved", isStatus: true),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isHighlight = false, bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)),
          if (isStatus)
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(value,
                    style: GoogleFonts.inter(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)))
          else
            Text(value,
                style: GoogleFonts.inter(
                    color: isHighlight ? kPrimaryBlue : Colors.black87,
                    fontWeight:
                        isHighlight ? FontWeight.w900 : FontWeight.w600,
                    fontSize: 14)),
        ],
      ),
    );
  }
}

// ==========================================
// 3. Electrical Sticker Page
// ==========================================

class ElectricalStickerPage extends StatefulWidget {
  const ElectricalStickerPage({super.key});
  @override
  State<ElectricalStickerPage> createState() => _ElectricalStickerPageState();
}

class _ElectricalStickerPageState extends State<ElectricalStickerPage> {
  final List<Map<String, dynamic>> items = [
    {"id": 1, "name": "KETTLE", "price": 5, "selected": false},
    {"id": 2, "name": "COMPUTER/LAPTOP", "price": 1, "selected": false},
    {"id": 3, "name": "PRINTER", "price": 1, "selected": false},
    {"id": 4, "name": "FAN", "price": 5, "selected": false},
    {"id": 5, "name": "HANDPHONE CHARGER", "price": 1, "selected": false},
  ];
  final List<Map<String, dynamic>> history = [
    {"id": 1, "name": "KETTLE", "price": 5, "session": "20242025"}
  ];

  int _calculateTotal() => items.fold(
      0, (sum, item) => sum + (item['selected'] ? (item['price'] as int) : 0));

  void _processPayment() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context);
    setState(() {
      final purchased = items.where((i) => i['selected']).toList();
      for (var p in purchased) {
        history.add({
          "id": history.length + 1,
          "name": p['name'],
          "price": p['price'],
          "session": "20242025"
        });
        p['selected'] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text("STICKER ELEKTRIK",
              style: GoogleFonts.inter(
                  color: const Color(0xFF007BFF),
                  fontWeight: FontWeight.w800)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFFDC3545),
                    borderRadius: BorderRadius.circular(4)),
                child: Text("Senarai Sticker : 20242025 / 2",
                    style: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final item = items[idx];
                return ListTile(
                  onTap: () =>
                      setState(() => item['selected'] = !item['selected']),
                  leading: Text("${item['id']}"),
                  title: Text(item['name'],
                      style: GoogleFonts.inter(fontSize: 14)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      item['selected']
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: item['selected'] ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFFDC3545),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text("RM ${item['price']}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                  ]),
                );
              },
            ),
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4)),
                child: Text("Sejarah Senarai Sticker",
                    style: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, idx) {
                  final h = history[idx];
                  return ListTile(
                      leading: Text("${idx + 1}"),
                      title: Text(h['name']),
                      trailing: Text(h['session']));
                }),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5))
            ]),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Total Payment:",
                        style: TextStyle(color: Colors.grey)),
                    Text("RM ${_calculateTotal()}",
                        style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryBlue)),
                  ]),
              ElevatedButton(
                  onPressed:
                      _calculateTotal() > 0 ? _processPayment : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue),
                  child: const Text("Pay Now",
                      style: TextStyle(color: Colors.white)))
            ]),
      ),
    );
  }
}

// ==========================================
// 4. Complaint Pages (Hostel Complaint)
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
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const NewComplaintPage()));
    if (result != null && result is Map<String, String>) {
      setState(() => reports.insert(0, result));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New Complaint Created Successfully")));
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
          iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text("Reports",
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.bold)))
          ]),
          const SizedBox(height: 10),
          Expanded(
            child: reports.isEmpty
                ? const Center(child: Text("No complaints found"))
                : ListView.separated(
                    itemCount: reports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                            child: Row(children: [
                              Column(children: [
                                const Icon(Icons.apartment,
                                    color: Colors.green, size: 30),
                                Text(r["id"]!,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey))
                              ]),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(r["title"]!,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: kPrimaryBlue,
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Text(r["location"]!,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold))),
                                    const SizedBox(height: 8),
                                    Text(
                                        "Update: ${r["updateBy"]} • ${r["updateTime"]}",
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600)),
                                  ])),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: const Text("View",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold))),
                            ]),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _navigateToNewReport,
          backgroundColor: kPrimaryBlue,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("New Report",
              style: TextStyle(color: Colors.white))),
    );
  }
}

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
          builder: (_) => const Center(child: CircularProgressIndicator()));
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
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black)),
      body: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Form(
              key: _formKey,
              child: ListView(children: [
                TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Required" : null),
                const SizedBox(height: 20),
                TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                        labelText: "Location",
                        border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Required" : null),
                const SizedBox(height: 20),
                TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder())),
                const SizedBox(height: 30),
                SizedBox(
                    height: 50,
                    child: ElevatedButton(
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBlue),
                        child: const Text("Submit",
                            style: TextStyle(color: Colors.white)))),
              ]))),
    );
  }
}

class ComplaintDetailPage extends StatelessWidget {
  const ComplaintDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
          title: const Text("Report Details",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _buildTimelineItem(
                date: "06 Apr, 2025",
                headerColor: const Color(0xFF6F42C1),
                icon: Icons.email_outlined,
                title: "AI240160 Proses DiHantar",
                tag: "SND",
                time: "03:53:18 PTG",
                content: "Paip broken"),
            _buildTimelineItem(
                date: "07 Apr, 2025",
                headerColor: const Color(0xFF28A745),
                icon: Icons.person,
                title: "MHNAZRI Proses DiTerima",
                tag: "RCV",
                time: "09:24:32 PG",
                content: "TINDAKAN CONSTANT"),
            _buildTimelineItem(
                date: "15 Apr, 2025",
                headerColor: const Color(0xFF17A2B8),
                icon: Icons.person,
                title: "MHNAZRI Proses Selesai",
                tag: "END",
                time: "11:02:59 PG",
                content: "SELESAI",
                isEnd: true),
          ])),
    );
  }

  Widget _buildTimelineItem(
      {required String date,
      required Color headerColor,
      required IconData icon,
      required String title,
      required String tag,
      required String time,
      required String content,
      bool isEnd = false}) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: BorderRadius.circular(4)),
              child: Text(date,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300)),
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
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
                                  color: Colors.grey, fontSize: 11))
                        ])),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(tag,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold))),
                  ])),
              const Divider(height: 1),
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: isEnd
                      ? Row(children: [
                          Text(content),
                          const SizedBox(width: 5),
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 16)
                        ])
                      : Text(content)),
            ]),
          )
        ]));
  }
}
