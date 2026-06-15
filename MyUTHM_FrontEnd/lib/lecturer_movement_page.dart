import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'database_helper.dart';
import 'theme/app_colors.dart';

class LecturerMovementPage extends StatefulWidget {
  const LecturerMovementPage({super.key});

  @override
  State<LecturerMovementPage> createState() => _LecturerMovementPageState();
}

class _LecturerMovementPageState extends State<LecturerMovementPage> {
  String _selectedYear = 'All';
  List<MovementRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final rows = await DatabaseHelper.instance.getLecturerMovements(
      DatabaseHelper.currentUserId,
    );
    if (!mounted) return;
    setState(() {
      _records = rows.map(MovementRecord.fromDb).toList();
      _loading = false;
    });
  }

  List<String> get _years {
    final years = _records
        .map((record) => record.year)
        .where((year) => year.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return ['All', ...years];
  }

  Future<void> _showMovementDialog({MovementRecord? existing}) async {
    DateTime start = existing?.startDate ?? DateTime.now();
    DateTime end = existing?.endDate ?? start;
    final location = TextEditingController(text: existing?.location ?? '');
    final purpose = TextEditingController(text: existing?.purpose ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Create Movement' : 'Edit Movement'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(DateFormat('dd MMM yyyy').format(start)),
                subtitle: const Text('Start date'),
                trailing: const Icon(Icons.calendar_month_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: start,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    setDialogState(() {
                      start = picked;
                      if (end.isBefore(start)) end = start;
                    });
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(DateFormat('dd MMM yyyy').format(end)),
                subtitle: const Text('End date'),
                trailing: const Icon(Icons.calendar_month_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: end,
                    firstDate: start,
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) setDialogState(() => end = picked);
                },
              ),
              TextField(
                controller: location,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: purpose,
                decoration: const InputDecoration(labelText: 'Purpose'),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved != true) return;

    await DatabaseHelper.instance.saveLecturerMovement(
      movementId: existing?.id,
      lecturerId: DatabaseHelper.currentUserId,
      startDate: DateFormat('yyyy-MM-dd').format(start),
      endDate: DateFormat('yyyy-MM-dd').format(end),
      location: location.text.trim(),
      purpose: purpose.text.trim(),
    );
    await _loadRecords();
  }

  Future<void> _deleteMovement(MovementRecord record) async {
    if (record.id == null) return;
    await DatabaseHelper.instance.deleteLecturerMovement(
      DatabaseHelper.currentUserId,
      record.id!,
    );
    await _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background =
        Color.lerp(colors.background, colors.brandPrimary, 0.025)!;
    final records = _selectedYear == 'All'
        ? _records
        : _records.where((record) => record.year == _selectedYear).toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: colors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Movement',
          style: GoogleFonts.inter(
            color: colors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMovementDialog(),
        backgroundColor: colors.brandPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 118),
              child: Column(
                children: [
                  _MovementYearFilter(
                    years: _years,
                    selectedYear: _selectedYear,
                    onYearSelected: (year) =>
                        setState(() => _selectedYear = year),
                  ),
                  const SizedBox(height: 16),
                  if (records.isEmpty)
                    Text(
                      'No movement records',
                      style: GoogleFonts.inter(color: colors.secondaryText),
                    )
                  else
                    ...records.map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: MovementCard(
                          record: record,
                          onEdit: () => _showMovementDialog(existing: record),
                          onDelete: () => _deleteMovement(record),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _MovementYearFilter extends StatelessWidget {
  const _MovementYearFilter({
    required this.years,
    required this.selectedYear,
    required this.onYearSelected,
  });

  final List<String> years;
  final String selectedYear;
  final ValueChanged<String> onYearSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Select Year',
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        PopupMenuButton<String>(
          initialValue: selectedYear,
          color: colors.surface,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: onYearSelected,
          itemBuilder: (context) => years
              .map(
                (year) => PopupMenuItem<String>(
                  value: year,
                  child: _YearOption(
                    year: year,
                    selected: year == selectedYear,
                  ),
                ),
              )
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: colors.brandPrimary,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: colors.brandPrimary.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 7),
                Text(
                  selectedYear,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _YearOption extends StatelessWidget {
  const _YearOption({required this.year, required this.selected});

  final String year;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Icon(
          selected ? Icons.check_rounded : Icons.calendar_today_outlined,
          color: selected ? colors.brandPrimary : colors.secondaryText,
          size: 18,
        ),
        const SizedBox(width: 10),
        Text(
          year,
          style: GoogleFonts.inter(
            color: selected ? colors.brandPrimary : colors.primaryText,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class MovementCard extends StatelessWidget {
  const MovementCard({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  final MovementRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.primaryText.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _MovementDateRow(date: record.date)),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          Divider(height: 26, color: colors.borderColor),
          _MovementInfoRow(
            icon: Icons.place_outlined,
            label: 'LOCATION',
            value: record.location,
          ),
          Divider(height: 26, color: colors.borderColor),
          _MovementInfoRow(
            icon: Icons.description_outlined,
            label: 'PURPOSE',
            value: record.purpose,
          ),
        ],
      ),
    );
  }
}

class _MovementDateRow extends StatelessWidget {
  const _MovementDateRow({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        const _MovementIcon(icon: Icons.calendar_month_outlined),
        const SizedBox(width: 12),
        Text(
          date,
          style: GoogleFonts.inter(
            color: colors.primaryText,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _MovementInfoRow extends StatelessWidget {
  const _MovementInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MovementIcon(icon: icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: colors.secondaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: colors.primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MovementIcon extends StatelessWidget {
  const _MovementIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: colors.brandPrimary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: colors.brandPrimary, size: 20),
    );
  }
}

class MovementRecord {
  const MovementRecord({
    this.id,
    this.startDate,
    this.endDate,
    required this.date,
    required this.location,
    required this.purpose,
  });

  factory MovementRecord.fromDb(Map<String, dynamic> row) {
    final start = DateTime.tryParse(row['Start_Date']?.toString() ?? '');
    final end = DateTime.tryParse(row['End_Date']?.toString() ?? '') ?? start;
    final fmt = DateFormat('dd/MM');
    return MovementRecord(
      id: row['Movement_ID']?.toString(),
      startDate: start,
      endDate: end,
      date: start == null
          ? '-'
          : '${fmt.format(start)} - ${fmt.format(end ?? start)} ${start.year}',
      location: row['Location']?.toString().trim().isEmpty ?? true
          ? '-'
          : row['Location'].toString(),
      purpose: row['Purpose']?.toString().trim().isEmpty ?? true
          ? '-'
          : row['Purpose'].toString(),
    );
  }

  final String? id;
  final DateTime? startDate;
  final DateTime? endDate;
  final String date;
  final String location;
  final String purpose;

  String get year => (startDate ?? endDate)?.year.toString() ?? '';
}
