import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/app_colors.dart';

class LecturerMovementPage extends StatefulWidget {
  const LecturerMovementPage({super.key});

  @override
  State<LecturerMovementPage> createState() => _LecturerMovementPageState();
}

class _LecturerMovementPageState extends State<LecturerMovementPage> {
  String _selectedYear = '2026';

  static const _recordsByYear = {
    '2026': [
      MovementRecord(
        date: '22/04 - 22/04',
        location: 'MIMOS BERHAD, MRANTI PARK, KUALA LUMPUR',
        purpose: 'JELAJAH INDUSTRI DIGITAL (JID) 2026 SIRI 1',
      ),
      MovementRecord(
        date: '30/01 - 01/02',
        location: 'THE STRAITS HOTEL & SUITE',
        purpose: 'MESYUARAT SASARAN KERJA TAHUNAN 2026',
      ),
    ],
    '2025': [
      MovementRecord(
        date: '18/09 - 19/09',
        location: 'PERSADA JOHOR INTERNATIONAL CONVENTION CENTRE',
        purpose: 'SEMINAR INOVASI PENGAJARAN DIGITAL 2025',
      ),
      MovementRecord(
        date: '07/05 - 07/05',
        location: 'UNIVERSITI MALAYA, KUALA LUMPUR',
        purpose: 'BENGKEL KERJASAMA AKADEMIK ANTARA UNIVERSITI',
      ),
    ],
    '2024': [
      MovementRecord(
        date: '11/11 - 12/11',
        location: 'PUTRAJAYA INTERNATIONAL CONVENTION CENTRE',
        purpose: 'PERSIDANGAN TRANSFORMASI DIGITAL SEKTOR AWAM',
      ),
      MovementRecord(
        date: '21/02 - 22/02',
        location: 'HOTEL GRAND PARAGON, JOHOR BAHRU',
        purpose: 'MESYUARAT PENYELARASAN PROGRAM AKADEMIK',
      ),
    ],
    '2023': [
      MovementRecord(
        date: '16/08 - 16/08',
        location: 'UTM SKUDAI, JOHOR',
        purpose: 'LAWATAN PENANDA ARAS FAKULTI',
      ),
      MovementRecord(
        date: '10/01 - 11/01',
        location: 'MELAKA INTERNATIONAL TRADE CENTRE',
        purpose: 'KURSUS PEMANTAPAN STAF AKADEMIK',
      ),
    ],
  };

  void _handleBottomTap(String tab) {
    if (tab == 'Home') {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background =
        Color.lerp(colors.background, colors.brandPrimary, 0.025)!;
    final records = _recordsByYear[_selectedYear] ?? const [];

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 118),
        child: Column(
          children: [
            _MovementYearFilter(
              selectedYear: _selectedYear,
              onYearSelected: (year) => setState(() => _selectedYear = year),
            ),
            const SizedBox(height: 16),
            ...records.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: MovementCard(record: record),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _MovementBottomNav(onTabTap: _handleBottomTap),
    );
  }
}

class _MovementYearFilter extends StatelessWidget {
  const _MovementYearFilter({
    required this.selectedYear,
    required this.onYearSelected,
  });

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
          itemBuilder: (context) => const ['2026', '2025', '2024', '2023']
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
  const MovementCard({super.key, required this.record});

  final MovementRecord record;

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
          _MovementDateRow(date: record.date),
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

class _MovementBottomNav extends StatelessWidget {
  const _MovementBottomNav({required this.onTabTap});

  final ValueChanged<String> onTabTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(18, 0, 18, 12 + bottomPadding),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 22),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: colors.primaryText.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MovementNavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  onTap: () => onTabTap('Home'),
                ),
                _MovementNavItem(
                  icon: Icons.school_outlined,
                  label: 'Academic',
                  active: true,
                  onTap: () => onTabTap('Academic'),
                ),
                const SizedBox(width: 58),
                _MovementNavItem(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notification',
                  onTap: () => onTabTap('Notification'),
                ),
                _MovementNavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  onTap: () => onTabTap('Profile'),
                ),
              ],
            ),
          ),
          Positioned(
            top: -2,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: colors.brandPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.brandPrimary.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementNavItem extends StatelessWidget {
  const _MovementNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = active ? colors.brandPrimary : colors.secondaryText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 9.5,
                fontWeight: active ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovementRecord {
  const MovementRecord({
    required this.date,
    required this.location,
    required this.purpose,
  });

  final String date;
  final String location;
  final String purpose;
}
