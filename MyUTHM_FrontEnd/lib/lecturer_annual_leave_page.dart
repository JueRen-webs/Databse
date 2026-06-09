import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/app_colors.dart';

class LecturerAnnualLeavePage extends StatefulWidget {
  const LecturerAnnualLeavePage({super.key});

  @override
  State<LecturerAnnualLeavePage> createState() =>
      _LecturerAnnualLeavePageState();
}

class _LecturerAnnualLeavePageState extends State<LecturerAnnualLeavePage> {
  String _selectedYear = '2026';

  static const _leaveByYear = {
    '2026': LeaveYearData(
      entitlement: '31 + 9 = 40',
      taken: '6',
      balance: '34',
      history: [
        LeaveHistoryRecord(
          from: '28/05',
          to: '28/05',
          day: '1',
          type: 'Cuti Tanpa Rekod Kelompok',
          note: 'Hari raya Haji kedua',
        ),
        LeaveHistoryRecord(
          from: '19/03',
          to: '27/03',
          day: '4',
          type: 'Cuti Rehat Gaji Penuh',
          note: 'hari raya',
        ),
        LeaveHistoryRecord(
          from: '06/03',
          to: '06/03',
          day: '1',
          type: 'Cuti Rehat Gaji Penuh',
          note: 'taklimat SDEA di SRAB Benut',
        ),
        LeaveHistoryRecord(
          from: '20/02',
          to: '20/02',
          day: '1',
          type: 'Cuti Rehat Gaji Penuh',
          note: 'awal ramadhan',
        ),
      ],
    ),
    '2025': LeaveYearData(
      entitlement: '30 + 8 = 38',
      taken: '9',
      balance: '29',
      history: [
        LeaveHistoryRecord(
          from: '18/12',
          to: '19/12',
          day: '2',
          type: 'Cuti Rehat Gaji Penuh',
          note: 'family matters',
        ),
        LeaveHistoryRecord(
          from: '14/07',
          to: '16/07',
          day: '3',
          type: 'Cuti Rehat Gaji Penuh',
          note: 'conference recovery',
        ),
        LeaveHistoryRecord(
          from: '03/02',
          to: '03/02',
          day: '1',
          type: 'Cuti Tanpa Rekod',
          note: 'official appointment',
        ),
      ],
    ),
    '2024': LeaveYearData(
      entitlement: '30 + 7 = 37',
      taken: '11',
      balance: '26',
      history: [
        LeaveHistoryRecord(
          from: '22/10',
          to: '24/10',
          day: '3',
          type: 'Cuti Rehat Gaji Penuh',
          note: 'personal leave',
        ),
        LeaveHistoryRecord(
          from: '12/06',
          to: '13/06',
          day: '2',
          type: 'Cuti Rehat Gaji Penuh',
          note: 'school holiday',
        ),
        LeaveHistoryRecord(
          from: '08/01',
          to: '08/01',
          day: '1',
          type: 'Cuti Tanpa Rekod',
          note: 'briefing programme',
        ),
      ],
    ),
    '2023': LeaveYearData(
      entitlement: '28 + 7 = 35',
      taken: '8',
      balance: '27',
      history: [
        LeaveHistoryRecord(
          from: '19/09',
          to: '20/09',
          day: '2',
          type: 'Cuti Rehat Gaji Penuh',
          note: 'family event',
        ),
        LeaveHistoryRecord(
          from: '04/04',
          to: '06/04',
          day: '3',
          type: 'Cuti Rehat Gaji Penuh',
          note: 'medical care',
        ),
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final data = _leaveByYear[_selectedYear]!;

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        child: Column(
          children: [
            _YearSelectorCard(
              selectedYear: _selectedYear,
              onYearSelected: (year) => setState(() => _selectedYear = year),
            ),
            const SizedBox(height: 14),
            _LeaveSummaryCard(
              icon: Icons.event_available_outlined,
              label: 'Leave Entitlement',
              value: data.entitlement,
            ),
            const SizedBox(height: 12),
            _LeaveSummaryCard(
              icon: Icons.logout_rounded,
              label: 'Leave Taken',
              value: data.taken,
            ),
            const SizedBox(height: 12),
            _LeaveSummaryCard(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Leave Balance',
              value: data.balance,
            ),
            const SizedBox(height: 16),
            _LeaveHistoryCard(records: data.history),
          ],
        ),
      ),
    );
  }
}

class _YearSelectorCard extends StatelessWidget {
  const _YearSelectorCard({
    required this.selectedYear,
    required this.onYearSelected,
  });

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
            itemBuilder: (context) => const ['2026', '2025', '2024', '2023']
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
  const _LeaveHistoryCard({required this.records});

  final List<LeaveHistoryRecord> records;

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
          ...records.map((record) => _LeaveHistoryRow(record: record)),
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
        ],
      ),
    );
  }
}

class _LeaveHistoryRow extends StatelessWidget {
  const _LeaveHistoryRow({required this.record});

  final LeaveHistoryRecord record;

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

class LeaveYearData {
  const LeaveYearData({
    required this.entitlement,
    required this.taken,
    required this.balance,
    required this.history,
  });

  final String entitlement;
  final String taken;
  final String balance;
  final List<LeaveHistoryRecord> history;
}

class LeaveHistoryRecord {
  const LeaveHistoryRecord({
    required this.from,
    required this.to,
    required this.day,
    required this.type,
    required this.note,
  });

  final String from;
  final String to;
  final String day;
  final String type;
  final String note;
}
