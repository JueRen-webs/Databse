import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// 常量定义
const Color kPrimaryBlue = Color(0xFF0025CC);

// ==========================================
// A. 外部调用的入口函数 (Main Entry)
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
            Text("Hostel Services", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.app_registration, color: kPrimaryBlue),
              title: const Text("Registration"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HostelRegistrationFormPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.flash_on, color: Colors.amber),
              title: const Text("Electrical Sticker"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ElectricalStickerPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.report_problem_outlined, color: Colors.redAccent),
              title: const Text("Complaint (Aduan)"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ComplaintPage()));
              },
            ),
          ],
        ),
      );
    },
  );
}

// ==========================================
// B. Hostel & Electrical Sticker
// ==========================================

// 1. Hostel Registration Form
class HostelRegistrationFormPage extends StatefulWidget {
  const HostelRegistrationFormPage({super.key});

  @override
  State<HostelRegistrationFormPage> createState() => _HostelRegistrationFormPageState();
}

class _HostelRegistrationFormPageState extends State<HostelRegistrationFormPage> {
  String? selectedBlock;
  final TextEditingController roomController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<String> blocks = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'N'];

  void _submitForm() async {
    if (_formKey.currentState!.validate() && selectedBlock != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pop(context); 
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HostelResultPage(block: selectedBlock!, room: roomController.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please complete the form")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Hostel Registration", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
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
              Text("Select Your Accommodation", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              LayoutBuilder(builder: (context, constraints) {
                return DropdownMenu<String>(
                  width: constraints.maxWidth,
                  initialSelection: selectedBlock,
                  label: const Text("Block"),
                  onSelected: (val) => setState(() => selectedBlock = val),
                  dropdownMenuEntries: blocks.map((val) => DropdownMenuEntry(value: val, label: "Block $val")).toList(),
                );
              }),
              const SizedBox(height: 20),
              TextFormField(
                controller: roomController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitForm(),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Z]'))],
                decoration: InputDecoration(
                  labelText: "Room Number",
                  hintText: "e.g. 404A",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text("Submit Application", style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. Hostel Result Page
class HostelResultPage extends StatelessWidget {
  final String block;
  final String room;
  const HostelResultPage({super.key, required this.block, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Registration Result", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 10),
                Text("Application Successful", style: GoogleFonts.inter(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
              child: Column(children: [
                _buildInfoRow("Name", "Lee Rou"), const Divider(),
                _buildInfoRow("Metric No.", "AI210254"), const Divider(),
                _buildInfoRow("College", "Kolej Kediaman Tun Dr. Ismail"), const Divider(),
                _buildInfoRow("Block", block, isHighlight: true), const Divider(),
                _buildInfoRow("Room", room, isHighlight: true), const Divider(),
                _buildInfoRow("Semester", "1 2024/2025"), const Divider(),
                _buildInfoRow("Status", "Approved", isStatus: true),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false, bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14)),
          if (isStatus)
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)), child: Text(value, style: GoogleFonts.inter(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12)))
          else
            Text(value, style: GoogleFonts.inter(color: isHighlight ? kPrimaryBlue : Colors.black87, fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

// 3. Electrical Sticker Page
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
  final List<Map<String, dynamic>> history = [{"id": 1, "name": "KETTLE", "price": 5, "session": "20242025"}];

  int _calculateTotal() => items.fold(0, (sum, item) => sum + (item['selected'] ? (item['price'] as int) : 0));

  void _processPayment() async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return; Navigator.pop(context);
    setState(() {
      final purchased = items.where((i) => i['selected']).toList();
      for (var p in purchased) {
        history.add({"id": history.length + 1, "name": p['name'], "price": p['price'], "session": "20242025"});
        p['selected'] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Successful!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("STICKER ELEKTRIK", style: GoogleFonts.inter(color: const Color(0xFF007BFF), fontWeight: FontWeight.w800)), centerTitle: true, backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFDC3545), borderRadius: BorderRadius.circular(4)), child: Text("Senarai Sticker : 20242025 / 2", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold))),
            // ... Items List ...
            ListView.separated(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length, separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final item = items[idx];
                return ListTile(
                  onTap: () => setState(() => item['selected'] = !item['selected']),
                  leading: Text("${item['id']}"),
                  title: Text(item['name'], style: GoogleFonts.inter(fontSize: 14)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    // 无论勾选与否都显示图标，只是图标样式不同
                    Icon(
                      item['selected'] ? Icons.check_box : Icons.check_box_outline_blank, 
                      color: item['selected'] ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), 
                      decoration: BoxDecoration(color: const Color(0xFFDC3545), borderRadius: BorderRadius.circular(10)), 
                      child: Text("RM ${item['price']}", style: const TextStyle(color: Colors.white, fontSize: 12))
                    ),
                  ]),
                );
              },
            ),
            // ... History ...
            Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)), child: Text("Sejarah Senarai Sticker", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold))),
            ListView.separated(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: history.length, separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final h = history[idx];
                return ListTile(leading: Text("${idx+1}"), title: Text(h['name']), trailing: Text(h['session']));
              }
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            const Text("Total Payment:", style: TextStyle(color: Colors.grey)),
            Text("RM ${_calculateTotal()}", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryBlue)),
          ]),
          ElevatedButton(onPressed: _calculateTotal() > 0 ? _processPayment : null, style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue), child: const Text("Pay Now", style: TextStyle(color: Colors.white)))
        ]),
      ),
    );
  }
}

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
    {"id": "20250400324", "title": "Paip broken", "location": "L2-05C", "status": "END", "updateBy": "MHNAZRI", "updateTime": "07/04/2025 04:25 PTG"}
  ];

  void _navigateToNewReport() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const NewComplaintPage()));
    if (result != null && result is Map<String, String>) {
      setState(() => reports.insert(0, result));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("New Complaint Created Successfully")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Complaint", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text("Reports", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 10),
          Expanded(
            child: reports.isEmpty ? const Center(child: Text("No complaints found")) : ListView.separated(
              itemCount: reports.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final r = reports[idx];
                return Card(
                  elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ComplaintDetailPage())),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(children: [
                        Column(children: [const Icon(Icons.apartment, color: Colors.green, size: 30), Text(r["id"]!, style: const TextStyle(fontSize: 10, color: Colors.grey))]),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r["title"]!, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: kPrimaryBlue, borderRadius: BorderRadius.circular(4)), child: Text(r["location"]!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                          const SizedBox(height: 8),
                          Text("Update: ${r["updateBy"]} • ${r["updateTime"]}", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ])),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)), child: const Text("View", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _navigateToNewReport, backgroundColor: kPrimaryBlue, icon: const Icon(Icons.add, color: Colors.white), label: const Text("New Report", style: TextStyle(color: Colors.white))),
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
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return; Navigator.pop(context);
      final newReport = {
        "id": "2025${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        "title": _titleController.text, "type": "facility", "location": _locationController.text, "status": "PENDING", "updateBy": "YOU", "updateTime": "Just Now"
      };
      if (!mounted) return; Navigator.pop(context, newReport);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Complaint", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5, iconTheme: const IconThemeData(color: Colors.black)),
      body: Container(color: Colors.white, padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: ListView(children: [
        TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Required" : null),
        const SizedBox(height: 20),
        TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: "Location", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Required" : null),
        const SizedBox(height: 20),
        TextFormField(controller: _descController, maxLines: 4, decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder())),
        const SizedBox(height: 30),
        SizedBox(height: 50, child: ElevatedButton(onPressed: _submitReport, style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue), child: const Text("Submit", style: TextStyle(color: Colors.white)))),
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
      appBar: AppBar(title: const Text("Report Details", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        _buildTimelineItem(date: "06 Apr, 2025", headerColor: const Color(0xFF6F42C1), icon: Icons.email_outlined, title: "AI240160 Proses DiHantar", tag: "SND", time: "03:53:18 PTG", content: "Paip broken"),
        _buildTimelineItem(date: "07 Apr, 2025", headerColor: const Color(0xFF28A745), icon: Icons.person, title: "MHNAZRI Proses DiTerima", tag: "RCV", time: "09:24:32 PG", content: "TINDAKAN CONSTANT"),
        _buildTimelineItem(date: "15 Apr, 2025", headerColor: const Color(0xFF17A2B8), icon: Icons.person, title: "MHNAZRI Proses Selesai", tag: "END", time: "11:02:59 PG", content: "SELESAI", isEnd: true),
      ])),
    );
  }

  Widget _buildTimelineItem({required String date, required Color headerColor, required IconData icon, required String title, required String tag, required String time, required String content, bool isEnd = false}) {
    return Padding(padding: const EdgeInsets.only(bottom: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: headerColor, borderRadius: BorderRadius.circular(4)), child: Text(date, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        child: Column(children: [
          Padding(padding: const EdgeInsets.all(12), child: Row(children: [
            Icon(icon, color: headerColor), const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.bold)), Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11))])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)), child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
          ])),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16), child: isEnd ? Row(children: [Text(content), const SizedBox(width: 5), const Icon(Icons.check_circle, color: Colors.green, size: 16)]) : Text(content)),
        ]),
      )
    ]));
  }
}

// ==========================================
// D. Vehicle Management (Full Integrated Flow)
// ==========================================

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});
  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  List<Map<String, String>> vehicles = [
    {"session": "20252026", "plate": "VML2141", "sticker": "04253", "date": "29-OCT-25", "type": "MOTORCAR", "model": "PROTON PERSONA", "color": "SILVER"},
    {"session": "20242025", "plate": "JSU1234", "sticker": "0", "date": "10-JAN-25", "type": "MOTORCAR", "model": "PERODUA MYVI", "color": "BLUE"},
    {"session": "20252026", "plate": "WEB8888", "sticker": "NONE", "date": "-", "type": "MOTORCAR", "model": "HONDA CIVIC", "color": "WHITE"},
  ];

  void _refresh() => setState(() {});

  // Modified: Register -> Auto Redirect to Apply Sticker
  void _navigateToNewVehicle() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const NewVehiclePage()));
    if (result != null && result is Map<String, String>) {
      setState(() {
        vehicles.insert(0, result);
      });
      // Automatic redirection to Apply Sticker Page after successful registration
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (context) => ApplyStickerPage(vehicles: vehicles, initialSelection: result['plate'])));
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Vehicle Record", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("LIST OF REGISTERED VEHICLES", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF333333))),
          const Divider(thickness: 2, color: kPrimaryBlue),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true, 
            physics: const NeverScrollableScrollPhysics(), 
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final v = vehicles[index];
              String stickerDisplay;
              Color stickerColor;
              if (v['sticker'] == "0") {
                stickerDisplay = "Application Failed";
                stickerColor = Colors.red;
              } else if (v['sticker'] == "PENDING") {
                stickerDisplay = "Pending Review";
                stickerColor = Colors.orange;
              } else if (v['sticker'] == "NONE" || v['sticker'] == "") {
                stickerDisplay = "Not Applied";
                stickerColor = Colors.grey;
              } else {
                stickerDisplay = v['sticker']!;
                stickerColor = kPrimaryBlue;
              }

              return Card(
                elevation: 2, margin: const EdgeInsets.only(bottom: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(v['plate']!, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryBlue)),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)), child: Text(v['session']!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)))
                  ]),
                  const Divider(),
                  _row("Type", v['type']!), _row("Model", v['model']!), _row("Color", v['color']!),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Sticker No.", style: TextStyle(color: Colors.grey)), Text(stickerDisplay, style: TextStyle(fontWeight: FontWeight.bold, color: stickerColor))])),
                  _row("Reg. Date", v['date']!),
                ])),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (context) => ApplyStickerPage(vehicles: vehicles))); _refresh(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87), child: const Text("Apply Sticker"))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(onPressed: _navigateToNewVehicle, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF17A2B8), foregroundColor: Colors.white), child: const Text("Register New Vehicle", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)))),
          ]),
          const SizedBox(height: 50),
        ]),
      ),
    );
  }
  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Colors.grey)), Text(v)]));
}

class NewVehiclePage extends StatefulWidget {
  const NewVehiclePage({super.key});
  @override
  State<NewVehiclePage> createState() => _NewVehiclePageState();
}

class _NewVehiclePageState extends State<NewVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _plate = TextEditingController();
  final _model = TextEditingController();
  final _color = TextEditingController();
  String _type = "MOTORCAR";

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return; Navigator.pop(context);
      
      final nv = {
        "session": "20252026", 
        "plate": _plate.text.toUpperCase(), 
        "sticker": "NONE", 
        "date": "JUST NOW", 
        "type": _type, 
        "model": _model.text.toUpperCase(), 
        "color": _color.text.toUpperCase()
      };
      if (!mounted) return; Navigator.pop(context, nv);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register New Vehicle", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5, iconTheme: const IconThemeData(color: Colors.black)),
      body: Container(color: Colors.white, padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: ListView(children: [
        // Updated Plate Number field
        TextFormField(
          controller: _plate, 
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            // Only allow uppercase letters and digits, no spaces or symbols
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          ],
          decoration: const InputDecoration(
            labelText: "Plate Number", 
            hintText: "e.g. VML2141",
            border: OutlineInputBorder()
          ), 
          validator: (v) {
            if (v == null || v.isEmpty) return "Required";
            // Check if it contains both letters and numbers
            final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(v);
            final hasDigit = RegExp(r'[0-9]').hasMatch(v);
            if (!hasLetter || !hasDigit) {
              return "Must contain both letters and numbers";
            }
            return null;
          }
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField(initialValue: _type, decoration: const InputDecoration(labelText: "Vehicle Type", border: OutlineInputBorder()), items: ["MOTORCAR", "MOTORCYCLE"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setState(() => _type = v!)),
        const SizedBox(height: 20),
        TextFormField(controller: _model, decoration: const InputDecoration(labelText: "Model", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Required" : null),
        const SizedBox(height: 20),
        TextFormField(controller: _color, decoration: const InputDecoration(labelText: "Colour", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Required" : null),
        const SizedBox(height: 30),
        SizedBox(height: 50, child: ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue), child: const Text("Register", style: TextStyle(color: Colors.white)))),
      ]))),
    );
  }
}

class ApplyStickerPage extends StatefulWidget {
  final List<Map<String, String>> vehicles;
  final String? initialSelection;
  const ApplyStickerPage({super.key, required this.vehicles, this.initialSelection});
  @override
  State<ApplyStickerPage> createState() => _ApplyStickerPageState();
}

class _ApplyStickerPageState extends State<ApplyStickerPage> {
  String? selectedPlate;

  @override
  void initState() {
    super.initState();
    selectedPlate = widget.initialSelection;
  }
  
  // Logic to determine price based on existing stickers
  int _calculatePrice() {
    if (selectedPlate == null) return 0;
    
    // Find the currently selected vehicle object
    final selectedVehicle = widget.vehicles.firstWhere((v) => v['plate'] == selectedPlate);
    final String type = selectedVehicle['type']!; // MOTORCAR or MOTORCYCLE

    // Count how many vehicles of the SAME TYPE already have a sticker or are pending
    int count = widget.vehicles.where((v) {
      bool isSameType = v['type'] == type;
      bool hasSticker = v['sticker'] != "0" && v['sticker'] != "NONE" && v['sticker'] != "FAILED";
      return isSameType && hasSticker;
    }).length;

    // If 1 or more already exist, this new one is the "Second", so RM 10
    return count >= 1 ? 10 : 2;
  }

  bool _isAlreadyIssued(String s) {
    if (s == "0" || s == "PENDING" || s == "FAILED" || s == "NONE") return false;
    return double.tryParse(s) != null;
  }

  void _apply() async {
    if (selectedPlate == null) return;

    int price = _calculatePrice();

    // 1. Show Payment Dialog with Dynamic Price
    bool? confirmPayment = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Make Payment"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Vehicle: $selectedPlate"),
            const SizedBox(height: 8),
            Text("Fee Tier: ${price == 10 ? 'Second Vehicle' : 'First Vehicle'}"),
            const Divider(),
            Text("Total Amount: RM $price.00", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryBlue)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green), 
            child: const Text("Pay Now", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );

    if (confirmPayment != true) return;

    // 2. Process logic
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return; Navigator.pop(context); 

    for (var vehicle in widget.vehicles) {
      if (vehicle['plate'] == selectedPlate) {
        vehicle['sticker'] = "PENDING"; 
      }
    }

    // 3. Final Success Dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 15),
            Text("Payment Successful", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            Text("Your application is now PENDING review.", textAlign: TextAlign.center),
          ],
        ),
        actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableVehicles = widget.vehicles.where((v) {
      String s = v['sticker'] ?? "";
      return s != "0" && s != "PENDING" && s != "FAILED" && !_isAlreadyIssued(s);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Apply Vehicle Sticker", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Fee Information (Reference only)
          Container(
            padding: const EdgeInsets.all(12), 
            decoration: BoxDecoration(color: const Color(0xFFFFF3CD), border: Border.all(color: const Color(0xFFFFEEBA)), borderRadius: BorderRadius.circular(4)), 
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("UTHM STICKER INFO", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _fee("Motorcar (First)", "RM 2.00"), 
              _fee("Motorcar (Second)", "RM 10.00"),
              _fee("Motorcycle (First)", "RM 2.00"), 
              _fee("Motorcycle (Second)", "RM 10.00"),
            ]),
          ),
          const SizedBox(height: 30),
          const Text("Select Vehicle for Application:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          // Material 3 Dropdown Selection
          LayoutBuilder(
            builder: (context, constraints) {
              return DropdownMenu<String>(
                width: constraints.maxWidth, // Matches parent width
                initialSelection: selectedPlate,
                hintText: availableVehicles.isEmpty ? "No eligible vehicles found" : "Choose your vehicle",
                label: const Text("Vehicle List"),
                onSelected: (String? value) {
                  setState(() => selectedPlate = value);
                },
                dropdownMenuEntries: availableVehicles.map((v) {
                  return DropdownMenuEntry<String>(
                    value: v['plate']!,
                    label: "${v['plate']} (${v['model']})",
                    leadingIcon: const Icon(Icons.directions_car_filled_outlined, size: 20),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 30),
          // Submit Button
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
            onPressed: (selectedPlate == null) ? null : _apply,
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text("Submit Application", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          )),
        ]),
      ),
    );
  }

  Widget _fee(String l, String p) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l), Text(p, style: const TextStyle(fontWeight: FontWeight.bold))]));
}

// ==========================================
// E. Course Management (Updated)
// ==========================================

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});
  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  // 数据列表中包含 section: 27 用于 English 课程
  List<Map<String, dynamic>> courses = [
    {"code": "BIC10103", "name": "DISCRETE STRUCTURE", "section": "1", "status": "DT", "credit": 3},
    {"code": "BIC20803", "name": "OPERATING SYSTEM", "section": "1", "status": "DT", "credit": 3},
    {"code": "BIC20904", "name": "OBJECT-ORIENTED PROGRAMMING", "section": "1", "status": "DT", "credit": 4},
    {"code": "BIM30503", "name": "HUMAN COMPUTER INTERACTION", "section": "1", "status": "DT", "credit": 3},
    {"code": "BIS20503", "name": "SOFTWARE SECURITY", "section": "1", "status": "DT", "credit": 3},
    {"code": "UHB23103", "name": "ENGLISH FOR TECHNICAL COMMUNICATION", "section": "27", "status": "DT", "credit": 3},
  ];
  int get totalCredits => courses.fold(0, (sum, item) => sum + (item['credit'] as int));

  void _addCourse() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterCoursePage()));
    if (result != null && result is Map<String, dynamic>) {
      setState(() => courses.add(result));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course Added Successfully")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Course Management", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: _card("12", "Min Credits", Colors.orange)), const SizedBox(width: 10), Expanded(child: _card("20", "Max Credits", const Color(0xFFD9534F)))]),
        const SizedBox(height: 10), _card(totalCredits.toString(), "Credits Registered", const Color(0xFF00AEEF)),
        const SizedBox(height: 24),
        Text("REGISTRATION INFORMATION", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF333333))),
        const Divider(thickness: 2, color: kPrimaryBlue),
        _regTable(),
        const SizedBox(height: 24),
        Text("COURSES REGISTERED", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[800])),
        const Divider(thickness: 2, color: Colors.green),
        _courseTable(),
        Container(padding: const EdgeInsets.all(12), alignment: Alignment.centerRight, child: Text("TOTAL CREDITS: $totalCredits", style: const TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 80),
      ])),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addCourse, backgroundColor: kPrimaryBlue, icon: const Icon(Icons.add, color: Colors.white), label: const Text("Register New Course", style: TextStyle(color: Colors.white))),
    );
  }

  Widget _card(String n, String l, Color c) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)), Text(l, style: const TextStyle(color: Colors.white, fontSize: 12))]));

  Widget _regTable() => Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)), child: Column(children: [
    Container(color: const Color(0xFF000080), padding: const EdgeInsets.all(8), child: const Row(children: [Expanded(flex: 2, child: Text("SESSION", style: TextStyle(color: Colors.white, fontSize: 10))), Expanded(flex: 3, child: Text("DATES (CLOSED)", style: TextStyle(color: Colors.white, fontSize: 10)))])),
    Container(color: Colors.white, padding: const EdgeInsets.all(12), child: const Row(children: [Expanded(flex: 2, child: Text("20252026/1")), Expanded(flex: 3, child: Text("10/09/2025 - 12/09/2025"))])),
  ]));

  // 修复：添加 SECT 和 STATUS 列，字体调小
  Widget _courseTable() => Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200)), child: Column(children: [
    Container(color: Colors.green[800], padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), child: const Row(children: [
      SizedBox(width: 30, child: Text("NO", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))), 
      SizedBox(width: 70, child: Text("CODE", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))), 
      Expanded(child: Text("NAME", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))), 
      SizedBox(width: 40, child: Text("SECT", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))), 
      SizedBox(width: 50, child: Text("STATUS", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))), 
      SizedBox(width: 30, child: Text("CR", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))
    ])),
    ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: courses.length, itemBuilder: (ctx, i) {
      final c = courses[i];
      return Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200)), color: i % 2 == 0 ? Colors.white : Colors.grey.shade50), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 30, child: Text("${i + 1}", style: const TextStyle(fontSize: 10))), 
        SizedBox(width: 70, child: Text(c['code'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10))), 
        Expanded(child: Text(c['name'], style: const TextStyle(fontSize: 10))), 
        SizedBox(width: 40, child: Text(c['section'], style: const TextStyle(fontSize: 10))), 
        SizedBox(width: 50, child: Text(c['status'], style: const TextStyle(fontSize: 10))), 
        SizedBox(width: 30, child: Text("${c['credit']}", style: const TextStyle(fontSize: 10)))
      ]));
    })
  ]));
}

class RegisterCoursePage extends StatefulWidget {
  const RegisterCoursePage({super.key});
  @override
  State<RegisterCoursePage> createState() => _RegisterCoursePageState();
}

class _RegisterCoursePageState extends State<RegisterCoursePage> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> results = [];
  final List<Map<String, dynamic>> db = [
    {"code": "BIT20203", "name": "DATA VISUALIZATION", "credit": 3, "sections": [{"no": "1", "time": "Mon 08:00 - 10:00", "location": "BS1", "capacity": "25/30"}, {"no": "2", "time": "Tue 14:00 - 16:00", "location": "BK2", "capacity": "10/30"}, {"no": "3", "time": "Wed 10:00 - 12:00", "location": "Lab 4", "capacity": "FULL"}]},
    {"code": "BIM10103", "name": "PROGRAMMING I", "credit": 3, "sections": [{"no": "1", "time": "Thu 08:00 - 11:00", "location": "Lab 1", "capacity": "12/30"}]},
    {"code": "UHB10102", "name": "ENGLISH FOR ACADEMIC", "credit": 2, "sections": [{"no": "10", "time": "Mon 14:00 - 16:00", "location": "G3-102", "capacity": "20/30"}]},
  ];

  void _doSearch(String q) {
    if (q.isEmpty) { setState(() => results = []); return; }
    setState(() => results = db.where((c) => c['code'].toString().toLowerCase().contains(q.toLowerCase()) || c['name'].toString().toLowerCase().contains(q.toLowerCase())).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      appBar: AppBar(title: const Text("Register Course", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: TextField(controller: _search, onChanged: _doSearch, decoration: const InputDecoration(hintText: "Search Course Code (e.g. BIT20203)", prefixIcon: Icon(Icons.search), border: InputBorder.none, contentPadding: EdgeInsets.all(14)))),
        const SizedBox(height: 20),
        Expanded(child: results.isEmpty ? const Center(child: Text("Enter code to search")) : ListView.builder(itemCount: results.length, itemBuilder: (ctx, i) {
          final c = results[i];
          return Card(margin: const EdgeInsets.only(bottom: 16), child: ExpansionTile(
            title: Text("${c['code']} - ${c['name']}", style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("${c['credit']} Credits"),
            children: [
              Container(padding: const EdgeInsets.all(16), color: Colors.grey.shade50, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Select a Section:", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 10),
                ...(c['sections'] as List).map((s) {
                  bool full = s['capacity'] == "FULL";
                  return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Section ${s['no']}", style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryBlue)), Text(s['time']), Text(s['location'])]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(s['capacity'], style: TextStyle(color: full ? Colors.red : Colors.green)), const SizedBox(height: 8), ElevatedButton(onPressed: full ? null : () => Navigator.pop(context, {"code": c['code'], "name": c['name'], "section": s['no'], "status": "DT", "credit": c['credit']}), style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue, minimumSize: const Size(60, 30)), child: const Text("Add", style: TextStyle(color: Colors.white)))])
                  ]));
                }),
              ]))
            ],
          ));
        }))
      ])),
    );
  }
}

// ==========================================
// F. Reservation Page (Refined & Upgraded)
// ==========================================

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});
  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  String? selectedPurpose;
  String? selectedVenue;
  
  // State variables
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _selectedSlot; // { "date": DateTime, "time": String }

  // Simulating booked slots (format: yyyy-MM-dd_Time)
  // Example: 9 AM today is booked
  late final Set<String> _bookedSlots;

  @override
  void initState() {
    super.initState();
    DateTime today = DateTime.now();
    _bookedSlots = {
      _getDateKey(today, "09:00 AM - 10:00 AM"), // 9 AM today is booked
      _getDateKey(today.add(const Duration(days: 1)), "02:00 PM - 03:00 PM"), // Tomorrow 2 PM booked
    };
  }

  // 8 AM to 10 PM
  final List<String> timeSlots = [
    "08:00 AM - 09:00 AM", "09:00 AM - 10:00 AM", "10:00 AM - 11:00 AM",
    "11:00 AM - 12:00 PM", "12:00 PM - 01:00 PM", "01:00 PM - 02:00 PM",
    "02:00 PM - 03:00 PM", "03:00 PM - 04:00 PM", "04:00 PM - 05:00 PM",
    "05:00 PM - 06:00 PM", "06:00 PM - 07:00 PM", "07:00 PM - 08:00 PM",
    "08:00 PM - 09:00 PM", "09:00 PM - 10:00 PM"
  ];

  // Helper to remove time component for comparison
  DateTime _normalize(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  // Get week days (Mon-Sun) based on selected date
  List<DateTime> _getWeekDays(DateTime date) {
    int diff = date.weekday - 1; 
    DateTime monday = date.subtract(Duration(days: diff));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  String _getDateKey(DateTime date, String time) {
    return "${date.year}-${date.month}-${date.day}_$time";
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // Disable past dates in picker
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: kPrimaryBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null;
      });
    }
  }

  void _submitReservation() async {
    if (selectedPurpose == null || selectedVenue == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select Purpose, Venue, and a Time Slot")));
      return;
    }

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return; Navigator.pop(context);

    DateTime d = _selectedSlot!['date'];
    String t = _selectedSlot!['time'];
    String dateStr = "${d.day}/${d.month}/${d.year}";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 10), Text("Booking Successful")]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _info("Purpose", selectedPurpose!),
          _info("Venue", selectedVenue!),
          _info("Date", dateStr),
          _info("Time", t),
        ]),
        actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text("OK"))]
      ),
    );
  }

  Widget _info(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 60, child: Text(l, style: const TextStyle(color: Colors.grey))), Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.bold)))]));

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDates = _getWeekDays(_selectedDate);
    List<String> weekHeaders = ["Time", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    //DateTime today = _normalize(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Facility Reservation", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0.5, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Facility Reservation", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimaryBlue)),
          const SizedBox(height: 20),
          
          // Refined Form Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFE1F5FE), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade100)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: _dropdown("Purpose / Game", ["Volleyball", "Badminton", "Futsal", "Tennis", "Basketball", "Gym", "Squash"], selectedPurpose, (v) => setState(() => selectedPurpose = v))),
                const SizedBox(width: 10),
                Expanded(child: _dropdown("Court / Venue", ["Court A", "Court B", "Court C", "Main Hall", "Open Field", "Gymnasium"], selectedVenue, (v) => setState(() => selectedVenue = v))),
              ]),
              const SizedBox(height: 15),
              Text("Location: ${selectedVenue ?? '-'}", style: const TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("Status: ELIGIBLE", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
            ]),
          ),
          const SizedBox(height: 24),

          // Date Picker
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Select Date:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: kPrimaryBlue, borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // Advanced Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(100.0),
                border: TableBorder.all(color: Colors.grey.shade300),
                children: [
                  // Header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    children: List.generate(weekHeaders.length, (index) {
                      String text = weekHeaders[index];
                      Color textColor = Colors.black;
                      
                      if (index > 0) {
                        DateTime d = weekDates[index - 1];
                        text += "\n${d.day}/${d.month}";
                        // Highlight today or selected date? Let's highlight the day selected in picker
                        if (_normalize(d) == _normalize(_selectedDate)) {
                          textColor = kPrimaryBlue;
                        }
                      }
                      return Container(padding: const EdgeInsets.all(8), alignment: Alignment.center, child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor)));
                    })
                  ),
                  // Slots
                  // Inside the Table children in ReservationPage
                  // Locate this section inside the Table widget of ReservationPage
                  ...timeSlots.map((time) {
                    return TableRow(
                      children: List.generate(weekHeaders.length, (colIndex) {
                        if (colIndex == 0) {
                          return Container(
                            padding: const EdgeInsets.all(8), 
                            alignment: Alignment.center, 
                            child: Text(time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))
                          );
                        }
                        
                        DateTime cellDate = weekDates[colIndex - 1];
                        String key = _getDateKey(cellDate, time);
                        
                        // --- Accurate Time Validation Logic ---
                        DateTime now = DateTime.now();
                        bool isToday = _normalize(cellDate) == _normalize(now);
                        
                        // Parse the hour from string "08:00 AM - 09:00 AM"
                        // Takes the first 2 characters of the string
                        int slotStartHour = int.parse(time.substring(0, 2));
                        String amPm = time.substring(6, 8); // Extracts "AM" or "PM"
                        
                        // Convert to 24-hour format for accurate comparison
                        if (amPm == "PM" && slotStartHour != 12) slotStartHour += 12;
                        if (amPm == "AM" && slotStartHour == 12) slotStartHour = 0;

                        // Logic: If it is today, the slot is passed if current hour is >= slot start hour
                        // Example: If it's 11:15 AM, now.hour is 11. 11:00 AM slot (slotStartHour 11) becomes disabled.
                        bool isTimePassed = _normalize(cellDate).isBefore(_normalize(now)) || 
                                          (isToday && now.hour >= slotStartHour);
                        
                        bool isBooked = _bookedSlots.contains(key);
                        bool isSelected = _selectedSlot != null && 
                                        _getDateKey(_selectedSlot!['date'], _selectedSlot!['time']) == key;

                        // Color logic
                        Color cellColor = Colors.white;
                        if (isBooked) {
                          cellColor = Colors.grey.shade400; // Booked slots
                        } else if (isTimePassed) {
                          cellColor = Colors.grey.shade100; // Past slots (Light grey)
                        } else if (isSelected) {
                          cellColor = kPrimaryBlue; // Selected slot
                        }

                        return InkWell(
                          // Disable interaction for past times or booked slots
                          onTap: (isTimePassed || isBooked) ? null : () {
                            setState(() {
                              _selectedSlot = {"date": cellDate, "time": time};
                            });
                          },
                          child: Container(
                            height: 45,
                            alignment: Alignment.center,
                            color: cellColor,
                            child: isBooked 
                              ? const Text("Booked", style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))
                              : (isSelected ? const Icon(Icons.check, color: Colors.white) : null),
                          ),
                        );
                      })
                    );
                  }).toList()
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _submitReservation, style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue), child: const Text("Submit Reservation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))),
          const SizedBox(height: 50),
        ]),
      ),
    );
  }

  // Locate the _dropdown method at the bottom of ReservationPage class and replace it:

Widget _dropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, 
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      const SizedBox(height: 8),
      LayoutBuilder(
        builder: (context, constraints) {
          return DropdownMenu<String>(
            width: constraints.maxWidth, // Matches parent width
            initialSelection: value,
            requestFocusOnTap: false, // Prevents keyboard from showing on mobile
            onSelected: (String? newValue) {
              onChanged(newValue);
            },
            // Material Design 3 Entry
            dropdownMenuEntries: items.map((String item) {
              return DropdownMenuEntry<String>(
                value: item,
                label: item,
              );
            }).toList(),
            // Optional: Matches the theme of your form
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          );
        },
      ),
    ],
  );
}
}