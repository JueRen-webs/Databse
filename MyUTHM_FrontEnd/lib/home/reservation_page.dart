import 'package:flutter/material.dart';

import 'constants.dart';





class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});
  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  String? selectedPurpose;
  String? selectedVenue;

  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _selectedSlot;

  late final Set<String> _bookedSlots;

  @override
  void initState() {
    super.initState();
    DateTime today = DateTime.now();
    _bookedSlots = {
      _getDateKey(today, "09:00 AM - 10:00 AM"),
      _getDateKey(today.add(const Duration(days: 1)), "02:00 PM - 03:00 PM"),
    };
  }

  final List<String> timeSlots = [
    "08:00 AM - 09:00 AM",
    "09:00 AM - 10:00 AM",
    "10:00 AM - 11:00 AM",
    "11:00 AM - 12:00 PM",
    "12:00 PM - 01:00 PM",
    "01:00 PM - 02:00 PM",
    "02:00 PM - 03:00 PM",
    "03:00 PM - 04:00 PM",
    "04:00 PM - 05:00 PM",
    "05:00 PM - 06:00 PM",
    "06:00 PM - 07:00 PM",
    "07:00 PM - 08:00 PM",
    "08:00 PM - 09:00 PM",
    "09:00 PM - 10:00 PM"
  ];

  DateTime _normalize(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

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
      firstDate: DateTime.now(),
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
    if (selectedPurpose == null ||
        selectedVenue == null ||
        _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Please select Purpose, Venue, and a Time Slot")));
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context);

    DateTime d = _selectedSlot!['date'];
    String t = _selectedSlot!['time'];
    String dateStr = "${d.day}/${d.month}/${d.year}";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 10),
          Text("Booking Successful")
        ]),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _info("Purpose", selectedPurpose!),
              _info("Venue", selectedVenue!),
              _info("Date", dateStr),
              _info("Time", t),
            ]),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"))
        ],
      ),
    );
  }

  Widget _info(String l, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 60,
            child: Text(l, style: const TextStyle(color: Colors.grey))),
        Expanded(
            child: Text(v, style: const TextStyle(fontWeight: FontWeight.bold)))
      ]));

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDates = _getWeekDays(_selectedDate);
    List<String> weekHeaders = [
      "Time",
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun"
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text("Facility Reservation",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Facility Reservation",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryBlue)),
          const SizedBox(height: 20),


          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFE1F5FE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: _dropdown(
                            "Purpose / Game",
                            [
                              "Volleyball",
                              "Badminton",
                              "Futsal",
                              "Tennis",
                              "Basketball",
                              "Gym",
                              "Squash"
                            ],
                            selectedPurpose,
                            (v) => setState(() => selectedPurpose = v))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _dropdown(
                            "Court / Venue",
                            [
                              "Court A",
                              "Court B",
                              "Court C",
                              "Main Hall",
                              "Open Field",
                              "Gymnasium"
                            ],
                            selectedVenue,
                            (v) => setState(() => selectedVenue = v))),
                  ]),
                  const SizedBox(height: 15),
                  Text("Location: ${selectedVenue ?? '-'}",
                      style: const TextStyle(
                          color: kPrimaryBlue,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text("Status: ELIGIBLE",
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12))
                ]),
          ),
          const SizedBox(height: 24),


          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Select Date:",
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: kPrimaryBlue,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 12),


          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
              child: Table(
                defaultColumnWidth: const FixedColumnWidth(100.0),
                border: TableBorder.all(color: Colors.grey.shade300),
                children: [
                  TableRow(
                    decoration:
                        BoxDecoration(color: Colors.grey.shade200),
                    children: List.generate(weekHeaders.length, (index) {
                      String text = weekHeaders[index];
                      Color textColor = Colors.black;

                      if (index > 0) {
                        DateTime d = weekDates[index - 1];
                        text += "\n${d.day}/${d.month}";
                        if (_normalize(d) == _normalize(_selectedDate)) {
                          textColor = kPrimaryBlue;
                        }
                      }
                      return Container(
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          child: Text(text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: textColor)));
                    }),
                  ),
                  ...timeSlots.map((time) {
                    return TableRow(
                      children: List.generate(weekHeaders.length, (colIndex) {
                        if (colIndex == 0) {
                          return Container(
                              padding: const EdgeInsets.all(8),
                              alignment: Alignment.center,
                              child: Text(time,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)));
                        }

                        DateTime cellDate = weekDates[colIndex - 1];
                        String key = _getDateKey(cellDate, time);

                        DateTime now = DateTime.now();
                        bool isToday =
                            _normalize(cellDate) == _normalize(now);

                        int slotStartHour =
                            int.parse(time.substring(0, 2));
                        String amPm = time.substring(6, 8);

                        if (amPm == "PM" && slotStartHour != 12)
                          slotStartHour += 12;
                        if (amPm == "AM" && slotStartHour == 12)
                          slotStartHour = 0;

                        bool isTimePassed =
                            _normalize(cellDate).isBefore(_normalize(now)) ||
                                (isToday && now.hour >= slotStartHour);

                        bool isBooked = _bookedSlots.contains(key);
                        bool isSelected = _selectedSlot != null &&
                            _getDateKey(_selectedSlot!['date'],
                                    _selectedSlot!['time']) ==
                                key;

                        Color cellColor = Colors.white;
                        if (isBooked) {
                          cellColor = Colors.grey.shade400;
                        } else if (isTimePassed) {
                          cellColor = Colors.grey.shade100;
                        } else if (isSelected) {
                          cellColor = kPrimaryBlue;
                        }

                        return InkWell(
                          onTap: (isTimePassed || isBooked)
                              ? null
                              : () {
                                  setState(() {
                                    _selectedSlot = {
                                      "date": cellDate,
                                      "time": time
                                    };
                                  });
                                },
                          child: Container(
                            height: 45,
                            alignment: Alignment.center,
                            color: cellColor,
                            child: isBooked
                                ? const Text("Booked",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))
                                : (isSelected
                                    ? const Icon(Icons.check,
                                        color: Colors.white)
                                    : null),
                          ),
                        );
                      }),
                    );
                  }).toList()
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  onPressed: _submitReservation,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue),
                  child: const Text("Submit Reservation",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)))),
          const SizedBox(height: 50),
        ]),
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, String? value,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return DropdownMenu<String>(
              width: constraints.maxWidth,
              initialSelection: value,
              requestFocusOnTap: false,
              onSelected: (String? newValue) {
                onChanged(newValue);
              },
              dropdownMenuEntries: items.map((String item) {
                return DropdownMenuEntry<String>(
                  value: item,
                  label: item,
                );
              }).toList(),
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
