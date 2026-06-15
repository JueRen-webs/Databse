import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'database_helper.dart';
import 'theme/app_colors.dart';

class MyHealthPage extends StatefulWidget {
  const MyHealthPage({super.key});

  @override
  State<MyHealthPage> createState() => _MyHealthPageState();
}

class _MyHealthPageState extends State<MyHealthPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _selectedYear = DateTime.now().year.toString();
  List<HealthChargeRecord> _charges = [];
  List<ClinicRecord> _medicalClinics = [];
  List<ClinicRecord> _dentalClinics = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    final medicalRows =
        await DatabaseHelper.instance.getClinics(typeName: 'MEDICAL');
    final dentalRows =
        await DatabaseHelper.instance.getClinics(typeName: 'DENTAL');
    final chargeRows = await DatabaseHelper.instance.getMedicalRecords(
      DatabaseHelper.currentUserId,
    );
    if (!mounted) return;
    final charges = chargeRows.map(HealthChargeRecord.fromDb).toList();
    final years = charges.map((record) => record.year).toSet();
    setState(() {
      _medicalClinics = medicalRows.map(ClinicRecord.fromDb).toList();
      _dentalClinics = dentalRows.map(ClinicRecord.fromDb).toList();
      _charges = charges;
      if (years.isNotEmpty && !years.contains(_selectedYear)) {
        final sortedYears = years.toList()
          ..sort((a, b) => b.compareTo(a));
        _selectedYear = sortedYears.first;
      }
    });
  }

  List<String> get _chargeYears {
    final years = _charges
        .map((record) => record.year)
        .where((year) => year.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return years.isEmpty ? [_selectedYear] : years;
  }

  List<HealthChargeRecord> get _selectedYearCharges =>
      _charges.where((record) => record.year == _selectedYear).toList();

  String _formatAmount(double value) => value.toStringAsFixed(2);

  Future<void> _showAddMedicalRecordDialog() async {
    DateTime selectedDate = DateTime.now();
    final clinics = [..._medicalClinics, ..._dentalClinics]
        .where((clinic) => clinic.id != null && clinic.id!.isNotEmpty)
        .toList();
    String? selectedClinicId = clinics.isEmpty ? null : clinics.first.id;
    final chargesController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Medical Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                subtitle: const Text('Medical date'),
                trailing: const Icon(Icons.calendar_month_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedClinicId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Clinic'),
                items: clinics
                    .map(
                      (clinic) => DropdownMenuItem<String>(
                        value: clinic.id,
                        child: Text(
                          clinic.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => selectedClinicId = value),
              ),
              TextField(
                controller: chargesController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Charges'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    if (saved != true) return;
    final charges = double.tryParse(chargesController.text.trim());
    if (charges == null || selectedClinicId == null) return;
    await DatabaseHelper.instance.saveMedicalRecord(
      lecturerId: DatabaseHelper.currentUserId,
      clinicId: selectedClinicId!,
      date: DateFormat('yyyy-MM-dd').format(selectedDate),
      charges: charges,
    );
    await _loadHealthData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openPkuWebsite() async {
    final uri = Uri.parse('https://pku.uthm.edu.my/');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $uri');
      }
    } catch (error) {
      debugPrint('Error launching PKU website: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const MyHealthAppBar(),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showAddMedicalRecordDialog,
              backgroundColor: colors.brandPrimary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Column(
        children: [
          _HealthTabs(controller: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChargesTab(),
                _buildPkuTab(),
                _ClinicListTab(
                  clinics: _medicalClinics,
                  icon: Icons.local_hospital_outlined,
                ),
                _ClinicListTab(
                  clinics: _dentalClinics,
                  icon: Icons.medical_services_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargesTab() {
    final colors = context.colors;
    final selectedCharges = _selectedYearCharges;
    final cumulative = _charges.fold<double>(
      0,
      (sum, record) => sum + record.chargeValue,
    );
    final yearly = selectedCharges.fold<double>(
      0,
      (sum, record) => sum + record.chargeValue,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      child: Column(
        children: [
          _HealthSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HealthSectionTitle('Overview'),
                const SizedBox(height: 14),
                _ChargeSummaryTile(
                  title: 'Cumulative',
                  subtitle: 'Total charges to date',
                  amount: 'RM ${_formatAmount(cumulative)}',
                ),
                const SizedBox(height: 10),
                _ChargeSummaryTile(
                  title: '$_selectedYear Charges',
                  subtitle: 'Total charges for $_selectedYear',
                  amount: 'RM ${_formatAmount(yearly)}',
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.cardAlt,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _SoftIcon(
                        icon: Icons.calendar_month_outlined,
                        color: colors.brandPrimary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Select Year',
                          style: GoogleFonts.inter(
                            color: colors.primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedYear,
                          borderRadius: BorderRadius.circular(14),
                          items: _chargeYears
                              .map(
                                (year) => DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            ),
                          )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedYear = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _HealthSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HealthSectionTitle('Charges Records'),
                const SizedBox(height: 12),
                if (selectedCharges.isEmpty)
                  Text(
                    'No medical records',
                    style: GoogleFonts.inter(
                      color: colors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  ...selectedCharges
                      .map((record) => _ChargeRecordRow(record: record)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPkuTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      child: _HealthSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HealthSectionTitle('Clinic Hours'),
            const SizedBox(height: 14),
            const _ClinicHoursTile(
              title: 'Monday - Thursday',
              sessions: ['8.30AM - 1.00PM', '2.15PM - 5.00PM'],
              icon: Icons.schedule_outlined,
            ),
            const SizedBox(height: 10),
            const _ClinicHoursTile(
              title: 'Friday',
              sessions: ['8.30AM - 12.15PM', '2.45PM - 5.00PM'],
              icon: Icons.event_available_outlined,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _openPkuWebsite,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: context.colors.brandPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'PKU Website',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHealthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyHealthAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(92);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 14, 10),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colors.primaryText,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Health',
                      style: GoogleFonts.inter(
                        color: colors.primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Manage your health charges and clinic information',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: colors.secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthTabs extends StatelessWidget {
  const _HealthTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.cardAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: colors.brandPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: colors.secondaryText,
          labelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: 'Charges'),
            Tab(text: 'PKU'),
            Tab(text: 'Medical'),
            Tab(text: 'Dental'),
          ],
        ),
      ),
    );
  }
}

class _ClinicListTab extends StatelessWidget {
  const _ClinicListTab({
    required this.clinics,
    required this.icon,
  });

  final List<ClinicRecord> clinics;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      child: Column(
        children: clinics
            .map(
              (clinic) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ClinicCard(clinic: clinic, icon: icon),
          ),
        )
            .toList(),
      ),
    );
  }
}

class _ChargeSummaryTile extends StatelessWidget {
  const _ChargeSummaryTile({
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final String title;
  final String subtitle;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _SoftIcon(icon: Icons.payments_outlined, color: colors.brandPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              color: colors.brandPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChargeRecordRow extends StatelessWidget {
  const _ChargeRecordRow({required this.record});

  final HealthChargeRecord record;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SoftIcon(
              icon: Icons.receipt_long_outlined, color: colors.brandPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.clinic,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: colors.primaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      'RM ${record.amount}',
                      style: GoogleFonts.inter(
                        color: colors.brandPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  record.patient,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  record.date,
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicHoursTile extends StatelessWidget {
  const _ClinicHoursTile({
    required this.title,
    required this.sessions,
    required this.icon,
  });

  final String title;
  final List<String> sessions;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _SoftIcon(icon: icon, color: colors.brandPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                ...sessions.map(
                      (session) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      session,
                      style: GoogleFonts.inter(
                        color: colors.secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  const _ClinicCard({
    required this.clinic,
    required this.icon,
  });

  final ClinicRecord clinic;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return _HealthSectionCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SoftIcon(icon: icon, color: colors.brandPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clinic.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  clinic.address,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  clinic.phone,
                  style: GoogleFonts.inter(
                    color: colors.brandPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthSectionCard extends StatelessWidget {
  const _HealthSectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colors.primaryText.withValues(alpha: 0.055),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HealthSectionTitle extends StatelessWidget {
  const _HealthSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        color: context.colors.primaryText,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SoftIcon extends StatelessWidget {
  const _SoftIcon({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

class HealthChargeRecord {
  const HealthChargeRecord({
    this.id,
    required this.date,
    required this.clinic,
    required this.patient,
    required this.amount,
    required this.chargeValue,
    required this.year,
  });

  factory HealthChargeRecord.fromDb(Map<String, dynamic> row) {
    final parsedDate =
        DateTime.tryParse(row['Medical_Date']?.toString() ?? '');
    final charges =
        double.tryParse(row['Charges']?.toString() ?? '') ?? 0;
    String text(String key) {
      final value = row[key]?.toString().trim() ?? '';
      return value.isEmpty ? '-' : value;
    }

    return HealthChargeRecord(
      id: row['Record_ID']?.toString(),
      date: parsedDate == null
          ? text('Medical_Date')
          : DateFormat('dd-MMM-yy').format(parsedDate).toUpperCase(),
      clinic: text('Clinic_Name') == '-' ? 'Medical Record' : text('Clinic_Name'),
      patient: text('Lecturer_ID'),
      amount: charges.toStringAsFixed(2),
      chargeValue: charges,
      year: parsedDate?.year.toString() ?? '',
    );
  }

  final String? id;
  final String date;
  final String clinic;
  final String patient;
  final String amount;
  final double chargeValue;
  final String year;
}

class ClinicRecord {
  const ClinicRecord({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
  });

  factory ClinicRecord.fromDb(Map<String, dynamic> row) {
    String value(String key) {
      final text = row[key]?.toString().trim() ?? '';
      return text.isEmpty ? '-' : text;
    }

    return ClinicRecord(
      id: value('Clinic_ID') == '-' ? null : value('Clinic_ID'),
      name: value('Clinic_Name'),
      address: value('Clinic_Address'),
      phone: value('Clinic_Phone'),
    );
  }

  final String? id;
  final String name;
  final String address;
  final String phone;
}
