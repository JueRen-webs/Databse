import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';





class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  final List<Map<String, String>> contacts = const [
    {"name": "MERS 999 (Ambulance/Fire Rescue/Police)", "number": "999"},
    {
      "name": "UTHM Auxiliary Police & Security Office - APSeM (24 Hours)",
      "number": "074533435"
    },
    {"name": "University Medical Centre (Parit Raja)", "number": "0198687854"},
    {"name": "University Medical Centre (Pagoh)", "number": "0199917137"},
    {"name": "UTHM OSHE", "number": "074537228"},
    {"name": "UTHM Development & Maintenance Office", "number": "074533333"},
    {"name": "Batu Pahat Police HQ", "number": "07436330"},
    {"name": "Batu Pahat Police Station", "number": "074341222"},
    {"name": "Parit Raja Police Station", "number": "074541222"},
    {"name": "Sri Gading Police Station", "number": "074558222"},
    {"name": "Ayer Hitam Police Station", "number": "077581222"},
  ];

  void _showConfirmation(BuildContext context, String name, String number) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: Text("Call $name ($number)?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MockCallingPage(name: name, number: number),
                  ),
                );
              },
              child: const Text("Yes", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Emergency Contacts",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0025CC), Color(0xFF42A5F5)],
          ),
        ),
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.white30),
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                title: Text(contact['name']!,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13)),
                subtitle: Text(contact['number']!,
                    style:
                        GoogleFonts.inter(color: Colors.white70, fontSize: 14)),
                trailing: const Icon(Icons.phone, color: Colors.white),
                onTap: () {
                  _showConfirmation(
                      context, contact['name']!, contact['number']!);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}


class MockCallingPage extends StatelessWidget {
  final String name;
  final String number;

  const MockCallingPage({super.key, required this.name, required this.number});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Calling...",
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 18),
                ),
              ],
            ),
            FloatingActionButton.large(
              onPressed: () => Navigator.pop(context),
              backgroundColor: Colors.red,
              shape: const CircleBorder(),
              child: const Icon(Icons.call_end, color: Colors.white, size: 40),
            ),
          ],
        ),
      ),
    );
  }
}
