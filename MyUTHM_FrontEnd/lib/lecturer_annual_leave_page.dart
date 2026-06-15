import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'database_helper.dart';
import 'theme/app_colors.dart';

class LecturerAnnualLeavePage extends StatefulWidget {
  const LecturerAnnualLeavePage({super.key});

  @override
  State<LecturerAnnualLeavePage> createState() =>
      _LecturerAnnualLeavePageState();
}

class _LecturerAnnualLeavePageState extends State<LecturerAnnualLeavePage> {
  String _selectedYear = DateTime.now().year.toString();
  List<LeaveHistoryRecord> _records = [];
  List<Map<String, dynamic>> _types = [];
  bool _loading = true;

  int get _taken => _records
      .where((record) => record.year == _selectedYear)
      .fold(0, (sum, record) => sum + (int.tryParse(record.day) ?? 0));

  int get _balance => 31 - _taken;

  List<String> get _years {
    final years = _records
        .map((record) => record.year)
        .where((year) => year.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    if (!years.contains(_selectedYear)) years.insert(0, _selectedYear);
    return years;
  }

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final rows = await DatabaseHelper.instance.getLecturerLeaves(
      DatabaseHelper.currentUserId,
    );
    final types = await DatabaseHelper.instance.getLeaveTypes();
    if (!mounted) return;
    setState(() {
      _records = rows.map(LeaveHistoryRecord.fromDb).toList();
      _types = types;
      _loading = false;
    });
  }

  Future<void> _showLeaveDialog({LeaveHistoryRecord? existing}) async {
    int typeId = int.tryParse(existing?.typeId ?? '') ??
        int.tryParse(_types.firstOrNull?['Leave_Type_ID']?.toString() ?? '1') ??
        1;
    DateTime start = existing?.startDate ?? DateTime.now();
    DateTime end = existing?.endDate ?? start;
    final note = TextEditingController(text: existing?.note == '-' ? '' : existing?.note ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Create Leave' : 'Edit Leave'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<int>(
                initialValue: typeId,
                decoration: const InputDecoration(labelText: 'Leave type'),
                items: _types
                    .map(
                      (type) => DropdownMenuItem<int>(
                        value: int.tryParse(type['Leave_Type_ID'].toString()),
                        child: Text(type['Leave_Name']?.toString() ?? '-'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => typeId = value);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(DateFormat('dd MMM yyyy').format(start)),
                subtitle: const Text('Start date'),
                trailing: const Icon(Icons.calendar_month_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: start,
                    firstDate: DateTime(2020),
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
                controller: note,
                decoration: const InputDecoration(labelText: 'Note'),
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

    await DatabaseHelper.instance.saveLecturerLeave(
      recordId: existing?.id,
      lecturerId: DatabaseHelper.currentUserId,
      leaveTypeId: typeId,
      startDate: DateFormat('yyyy-MM-dd').format(start),
      endDate: DateFormat('yyyy-MM-dd').format(end),
      note: note.text.trim(),
    );
    await _loadRecords();
  }

  Future<void> _deleteLeave(LeaveHistoryRecord record) async {
    if (record.id == null) return;
    await DatabaseHelper.instance.deleteLecturerLeave(
      DatabaseHelper.currentUserId,
      record.id!,
    );
    await _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final history =
        _records.where((record) => record.year == _selectedYear).toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: colors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Annual Leave',
          style: GoogleFonts.inter(
            color: colors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLeaveDialog(),
        backgroundColor: colors.brandPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              child: Column(
                children: [
                  _YearSelectorCard(
                    years: _years,
                    selectedYear: _selectedYear,
                    onYearSelected: (year) =>
                        setState(() => _selectedYear = year),
                  ),
                  const SizedBox(height: 14),
                  const _LeaveSummaryCard(
                    icon: Icons.event_available_outlined,
                    label: 'Leave Entitlement',
                    value: '31',
                  ),
                  const SizedBox(height: 12),
                  _LeaveSummaryCard(
                    icon: Icons.logout_rounded,
                    label: 'Leave Taken',
                    value: '$_taken',
                  ),
                  const SizedBox(height: 12),
                  _LeaveSummaryCard(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Leave Balance',
                    value: '$_balance',
                  ),
                  const SizedBox(height: 16),
                  _LeaveHistoryCard(
                    records: history,
                    onEdit: (record) => _showLeaveDialog(existing: record),
                    onDelete: _deleteLeave,
                  ),
                ],
              ),
            ),
    );
  }
}

class _YearSelectorCard extends StatelessWidget {
  const _YearSelectorCard({
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

    return _LeaveCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Select Year',
              style: GoogleFonts.inter(
                color: colors.primaryText,
                fontSize: 15,
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
                    child: _AnnualLeaveYearOption(
                      year: year,
                      selected: year == selectedYear,
                    ),
                  ),
                )
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: colors.brandPrimary,
                borderRadius: BorderRadius.circular(999),
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
      ),
    );
  }
}

class _AnnualLeaveYearOption extends StatelessWidget {
  const _AnnualLeaveYearOption({required this.year, required this.selected});

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

class _LeaveSummaryCard extends StatelessWidget {
  const _LeaveSummaryCard({
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

    return _LeaveCard(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.brandPrimary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colors.brandPrimary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: colors.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(width: 1, height: 30, color: colors.borderColor),
          const SizedBox(width: 14),
          Text(
            value,
            style: GoogleFonts.inter(
              color: colors.brandPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaveHistoryCard extends StatelessWidget {
  const _LeaveHistoryCard({
    required this.records,
    required this.onEdit,
    required this.onDelete,
  });

  final List<LeaveHistoryRecord> records;
  final ValueChanged<LeaveHistoryRecord> onEdit;
  final ValueChanged<LeaveHistoryRecord> onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return _LeaveCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leave History',
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _LeaveHistoryHeader(),
          const SizedBox(height: 4),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.all(18),
              child: Center(
                child: Text(
                  'No leave records',
                  style: GoogleFonts.inter(color: colors.secondaryText),
                ),
              ),
            )
          else
            ...records.map(
              (record) => _LeaveHistoryRow(
                record: record,
                onEdit: () => onEdit(record),
                onDelete: () => onDelete(record),
              ),
            ),
        ],
      ),
    );
  }
}

class _LeaveHistoryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = GoogleFonts.inter(
      color: colors.secondaryText,
      fontSize: 10,
      fontWeight: FontWeight.w900,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 42, child: Text('FRM', style: style)),
          SizedBox(width: 42, child: Text('TO', style: style)),
          SizedBox(width: 34, child: Text('DAY', style: style)),
          Expanded(flex: 3, child: Text('TYPE', style: style)),
          Expanded(flex: 2, child: Text('NOTE', style: style)),
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}

class _LeaveHistoryRow extends StatelessWidget {
  const _LeaveHistoryRow({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  final LeaveHistoryRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateStyle = GoogleFonts.inter(
      color: colors.primaryText,
      fontSize: 11,
      fontWeight: FontWeight.w900,
    );
    final bodyStyle = GoogleFonts.inter(
      color: colors.primaryText,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      height: 1.25,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 11),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.borderColor, width: 0.8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 42, child: Text(record.from, style: dateStyle)),
          SizedBox(width: 42, child: Text(record.to, style: dateStyle)),
          SizedBox(width: 34, child: Text(record.day, style: dateStyle)),
          Expanded(
            flex: 3,
            child: Text(
              record.type,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: bodyStyle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              record.note,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: colors.secondaryText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            iconSize: 18,
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
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({
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

class LeaveHistoryRecord {
  const LeaveHistoryRecord({
    this.id,
    this.typeId,
    this.startDate,
    this.endDate,
    required this.from,
    required this.to,
    required this.day,
    required this.type,
    required this.note,
  });

  factory LeaveHistoryRecord.fromDb(Map<String, dynamic> row) {
    final start = DateTime.tryParse(row['Start_Date']?.toString() ?? '');
    final end = DateTime.tryParse(row['End_Date']?.toString() ?? '') ?? start;
    final fmt = DateFormat('dd/MM');
    return LeaveHistoryRecord(
      id: row['Record_ID']?.toString(),
      typeId: row['Leave_Type_ID']?.toString(),
      startDate: start,
      endDate: end,
      from: start == null ? '-' : fmt.format(start),
      to: end == null ? '-' : fmt.format(end),
      day: row['Leave_Taken']?.toString() ?? '0',
      type: row['Leave_Name']?.toString() ?? '-',
      note: row['Note']?.toString().trim().isEmpty ?? true
          ? '-'
          : row['Note'].toString(),
    );
  }

  final String? id;
  final String? typeId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String from;
  final String to;
  final String day;
  final String type;
  final String note;

  String get year => (startDate ?? endDate)?.year.toString() ?? '';
}
