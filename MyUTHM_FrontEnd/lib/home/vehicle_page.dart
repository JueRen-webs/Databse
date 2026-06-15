import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'constants.dart';
import '../database_helper.dart';





class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});
  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {

  List<Map<String, String>> vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadFromDatabase();
  }


  Future<void> _loadFromDatabase() async {
    try {
      final dbData = await DatabaseHelper.instance.getVehiclesByStudent('AI240166');

      List<Map<String, String>> loadedVehicles = [];
      for (var row in dbData) {
        String uiStickerState = "NONE";
        String status = row['Sticker_Status']?.toString() ?? '';

        if (status == 'Application Failed') {
          uiStickerState = "0";
        } else if (status == 'PENDING') {
          uiStickerState = "PENDING";
        } else if (status == 'Approved' && row['Sticker_Number'] != null) {
          uiStickerState = row['Sticker_Number'].toString();
        }

        loadedVehicles.add({
          "session": row['Session_Year']?.toString() ?? "",
          "plate": row['Plate_Number']?.toString() ?? "",
          "sticker": uiStickerState,
          "date": row['Registration_Date']?.toString() ?? "",
          "type": row['type']?.toString() ?? "MOTORCAR",
          "model": row['Model']?.toString() ?? "",
          "color": row['Color']?.toString() ?? ""
        });
      }

      if (mounted) {
        setState(() {
          vehicles = loadedVehicles;
        });
      }
    } catch (e) {
      print("❌ 读取数据库失败: $e");
    }
  }

  void _refresh() => _loadFromDatabase();

  void _navigateToNewVehicle() async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const NewVehiclePage()));
    if (result != null && result is Map<String, String>) {

      setState(() {
        vehicles.insert(0, result);
      });
      if (!mounted) return;
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ApplyStickerPage(
                  vehicles: vehicles, initialSelection: result['plate'])));
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text("Vehicle Record",
              style: GoogleFonts.inter(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("LIST OF REGISTERED VEHICLES",
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333))),
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
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(v['plate']!,
                                    style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: kPrimaryBlue)),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius:
                                        BorderRadius.circular(4)),
                                    child: Text(v['session']!,
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)))
                              ]),
                          const Divider(),
                          _row("Type", v['type']!),
                          _row("Model", v['model']!),
                          _row("Color", v['color']!),
                          Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Sticker No.",
                                        style:
                                        TextStyle(color: Colors.grey)),
                                    Text(stickerDisplay,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: stickerColor))
                                  ])),
                          _row("Reg. Date", v['date']!),
                        ])),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ApplyStickerPage(vehicles: vehicles)));
                      _refresh();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87),
                    child: const Text("Apply Sticker"))),
            const SizedBox(width: 10),
            Expanded(
                child: ElevatedButton(
                    onPressed: _navigateToNewVehicle,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF17A2B8),
                        foregroundColor: Colors.white),
                    child: const Text("Register New Vehicle",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12)))),
          ]),
          const SizedBox(height: 50),
        ]),
      ),
    );
  }

  Widget _row(String l, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: const TextStyle(color: Colors.grey)),
        Text(v)
      ]));
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
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()));

      try {

        String todayDate = DateFormat('dd-MMM-yy').format(DateTime.now()).toUpperCase();

        int typeId = _type == "MOTORCAR" ? 1 : 2;


        await DatabaseHelper.instance.insertVehicle({
          "Student_ID": "AI240166",
          "Vehicle_Type_ID": typeId,
          "Plate_Number": _plate.text.toUpperCase(),
          "Model": _model.text.toUpperCase(),
          "Color": _color.text.toUpperCase(),
          "Registration_Date": todayDate,
          "Session_Year": "20252026",
          "Sticker_Number": null,
          "Sticker_Status": "Not Applied"
        });

        if (!mounted) return;
        Navigator.pop(context);


        final nv = {
          "session": "20252026",
          "plate": _plate.text.toUpperCase(),
          "sticker": "NONE",
          "date": todayDate,
          "type": _type,
          "model": _model.text.toUpperCase(),
          "color": _color.text.toUpperCase()
        };
        Navigator.pop(context, nv);
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        print("❌ 插入数据库失败: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Register New Vehicle",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                  controller: _plate,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  ],
                  decoration: const InputDecoration(
                      labelText: "Plate Number",
                      hintText: "e.g. VML2141",
                      border: OutlineInputBorder()),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Required";
                    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(v);
                    final hasDigit = RegExp(r'[0-9]').hasMatch(v);
                    if (!hasLetter || !hasDigit) {
                      return "Must contain both letters and numbers";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField(
                    initialValue: _type,
                    decoration: const InputDecoration(
                        labelText: "Vehicle Type",
                        border: OutlineInputBorder()),
                    items: ["MOTORCAR", "MOTORCYCLE"]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _type = v!)),
                const SizedBox(height: 20),
                TextFormField(
                    controller: _model,
                    decoration: const InputDecoration(
                        labelText: "Model",
                        border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Required" : null),
                const SizedBox(height: 20),
                TextFormField(
                    controller: _color,
                    decoration: const InputDecoration(
                        labelText: "Colour",
                        border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Required" : null),
                const SizedBox(height: 30),
                SizedBox(
                    height: 50,
                    child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBlue),
                        child: const Text("Register",
                            style: TextStyle(color: Colors.white)))),
              ]))),
    );
  }
}

class ApplyStickerPage extends StatefulWidget {
  final List<Map<String, String>> vehicles;
  final String? initialSelection;
  const ApplyStickerPage(
      {super.key, required this.vehicles, this.initialSelection});
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

  // 检查是否已经是有效贴纸号
  bool _isAlreadyIssued(String s) {
    if (s == "0" || s == "PENDING" || s == "FAILED" || s == "NONE")
      return false;
    return double.tryParse(s) != null;
  }

  void _apply() async {
    if (selectedPlate == null) return;

    // 1. 🛑 核心逻辑：检查该学生当前已经申请/拥有的有效贴纸总数
    //（只要不是 NONE 且不是 0 失败状态，PENDING 和已有号码的都算占用名额）
    int activeStickerCount = widget.vehicles.where((v) {
      String s = v['sticker'] ?? "NONE";
      return s != "NONE" && s != "0";
    }).length;


    if (activeStickerCount >= 2) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Application Denied", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: const Text("Maximum limit reached. Each student is only allowed to apply for a maximum of 2 vehicle stickers."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryBlue)),
            ),
          ],
        ),
      );
      return;
    }


    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));

    try {

      await DatabaseHelper.instance.updateStickerToPending(selectedPlate!);

      if (!mounted) return;
      Navigator.pop(context);


      for (var vehicle in widget.vehicles) {
        if (vehicle['plate'] == selectedPlate) {
          vehicle['sticker'] = "PENDING";
        }
      }


      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 15),
              Text("Successfully Submitted",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Text("Your vehicle sticker application has been successfully submitted and is now pending review.",
                  textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)))
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      print("❌ 提交申请失败: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    final availableVehicles = widget.vehicles.where((v) {
      String s = v['sticker'] ?? "";
      return s != "0" &&
          s != "PENDING" &&
          s != "FAILED" &&
          !_isAlreadyIssued(s);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text("Apply Vehicle Sticker",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                border: Border.all(color: const Color(0xFFFFEEBA)),
                borderRadius: BorderRadius.circular(4)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("UTHM STICKER INFO", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("• Each student is eligible to apply for up to TWO (2) vehicle stickers only."),
              Text("• Applications are subject to faculty approval."),
            ]),
          ),
          const SizedBox(height: 30),
          const Text("Select Vehicle for Application:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              return DropdownMenu<String>(
                width: constraints.maxWidth,
                initialSelection: selectedPlate,
                hintText: availableVehicles.isEmpty
                    ? "No eligible vehicles found"
                    : "Choose your vehicle",
                label: const Text("Vehicle List"),
                onSelected: (String? value) {
                  setState(() => selectedPlate = value);
                },
                dropdownMenuEntries: availableVehicles.map((v) {
                  return DropdownMenuEntry<String>(
                    value: v['plate']!,
                    label: "${v['plate']} (${v['model']})",
                    leadingIcon: const Icon(
                        Icons.directions_car_filled_outlined,
                        size: 20),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 30),
          SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (selectedPlate == null) ? null : _apply,
                style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: const Text("Submit Application",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              )),
        ]),
      ),
    );
  }
}