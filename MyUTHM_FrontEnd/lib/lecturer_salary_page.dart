import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/app_colors.dart';

class LecturerSalaryPage extends StatefulWidget {
  const LecturerSalaryPage({super.key});

  @override
  State<LecturerSalaryPage> createState() => _LecturerSalaryPageState();
}

class _LecturerSalaryPageState extends State<LecturerSalaryPage> {
  String _selectedMonth = 'May 2026';

  static const _payslips = [
    SalarySlipRecord(month: 'May 2026', netPay: 'RM 6,840.00', status: 'Paid'),
    SalarySlipRecord(month: 'Apr 2026', netPay: 'RM 6,840.00', status: 'Paid'),
    SalarySlipRecord(month: 'Mar 2026', netPay: 'RM 6,725.00', status: 'Paid'),
    SalarySlipRecord(month: 'Feb 2026', netPay: 'RM 6,725.00', status: 'Paid'),
  ];

  static const _salaryByMonth = {
    'May 2026': SalaryMonthData(
      netPay: 'RM 6,840.00',
      grossPay: 'RM 7,420',
      deductions: 'RM 580',
      breakdown: [
        SalaryBreakdownItem(label: 'Basic Salary', value: 'RM 5,800.00'),
        SalaryBreakdownItem(label: 'Fixed Allowance', value: 'RM 1,120.00'),
        SalaryBreakdownItem(label: 'Overtime / Claims', value: 'RM 500.00'),
        SalaryBreakdownItem(label: 'EPF / Pension', value: '- RM 420.00'),
        SalaryBreakdownItem(
            label: 'Tax / Other Deductions', value: '- RM 160.00'),
      ],
    ),
    'Apr 2026': SalaryMonthData(
      netPay: 'RM 6,840.00',
      grossPay: 'RM 7,320',
      deductions: 'RM 480',
      breakdown: [
        SalaryBreakdownItem(label: 'Basic Salary', value: 'RM 5,800.00'),
        SalaryBreakdownItem(label: 'Fixed Allowance', value: 'RM 1,120.00'),
        SalaryBreakdownItem(label: 'Overtime / Claims', value: 'RM 400.00'),
        SalaryBreakdownItem(label: 'EPF / Pension', value: '- RM 420.00'),
        SalaryBreakdownItem(
            label: 'Tax / Other Deductions', value: '- RM 60.00'),
      ],
    ),
    'Mar 2026': SalaryMonthData(
      netPay: 'RM 6,725.00',
      grossPay: 'RM 7,250',
      deductions: 'RM 525',
      breakdown: [
        SalaryBreakdownItem(label: 'Basic Salary', value: 'RM 5,800.00'),
        SalaryBreakdownItem(label: 'Fixed Allowance', value: 'RM 1,120.00'),
        SalaryBreakdownItem(label: 'Overtime / Claims', value: 'RM 330.00'),
        SalaryBreakdownItem(label: 'EPF / Pension', value: '- RM 420.00'),
        SalaryBreakdownItem(
            label: 'Tax / Other Deductions', value: '- RM 105.00'),
      ],
    ),
    'Feb 2026': SalaryMonthData(
      netPay: 'RM 6,725.00',
      grossPay: 'RM 7,180',
      deductions: 'RM 455',
      breakdown: [
        SalaryBreakdownItem(label: 'Basic Salary', value: 'RM 5,800.00'),
        SalaryBreakdownItem(label: 'Fixed Allowance', value: 'RM 1,120.00'),
        SalaryBreakdownItem(label: 'Overtime / Claims', value: 'RM 260.00'),
        SalaryBreakdownItem(label: 'EPF / Pension', value: '- RM 420.00'),
        SalaryBreakdownItem(
            label: 'Tax / Other Deductions', value: '- RM 35.00'),
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selectedSalary = _salaryByMonth[_selectedMonth]!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: colors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Salary',
          style: GoogleFonts.inter(
            color: colors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        child: Column(
          children: [
            _SalaryHeaderCard(
              selectedMonth: _selectedMonth,
              netPay: selectedSalary.netPay,
            ),
            const SizedBox(height: 14),
            _SalarySelectorCard(
              value: _selectedMonth,
              onChanged: (value) => setState(() => _selectedMonth = value),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SalaryMetricCard(
                    label: 'Gross Pay',
                    value: selectedSalary.grossPay,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SalaryMetricCard(
                    label: 'Deductions',
                    value: selectedSalary.deductions,
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SalaryBreakdownCard(items: selectedSalary.breakdown),
            const SizedBox(height: 14),
            const _PayslipListCard(records: _payslips),
          ],
        ),
      ),
    );
  }
}

class _SalaryHeaderCard extends StatelessWidget {
  const _SalaryHeaderCard({
    required this.selectedMonth,
    required this.netPay,
  });

  final String selectedMonth;
  final String netPay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return _SalaryCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.brandPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.payments_outlined,
              color: colors.brandPrimary,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net Salary',
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  netPay,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  selectedMonth,
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E9E62).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Paid',
              style: GoogleFonts.inter(
                color: const Color(0xFF1E9E62),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalarySelectorCard extends StatelessWidget {
  const _SalarySelectorCard({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return _SalaryCard(
      child: Row(
        children: [
          const _SoftSalaryIcon(icon: Icons.calendar_month_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Select Payslip',
              style: GoogleFonts.inter(
                color: colors.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              borderRadius: BorderRadius.circular(14),
              items: const ['May 2026', 'Apr 2026', 'Mar 2026', 'Feb 2026']
                  .map(
                    (month) => DropdownMenuItem(
                      value: month,
                      child: Text(month),
                    ),
                  )
                  .toList(),
              onChanged: (month) {
                if (month != null) onChanged(month);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SalaryMetricCard extends StatelessWidget {
  const _SalaryMetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return _SalaryCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SoftSalaryIcon(icon: icon),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              color: colors.secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalaryBreakdownCard extends StatelessWidget {
  const _SalaryBreakdownCard({required this.items});

  final List<SalaryBreakdownItem> items;

  @override
  Widget build(BuildContext context) {
    final deductionStart =
        items.indexWhere((item) => item.value.startsWith('-'));

    return _SalaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SalarySectionTitle('Salary Breakdown'),
          const SizedBox(height: 12),
          for (int index = 0; index < items.length; index++) ...[
            if (index == deductionStart) const Divider(height: 22),
            _BreakdownRow(label: items[index].label, value: items[index].value),
          ],
        ],
      ),
    );
  }
}

class _PayslipListCard extends StatelessWidget {
  const _PayslipListCard({required this.records});

  final List<SalarySlipRecord> records;

  @override
  Widget build(BuildContext context) {
    return _SalaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SalarySectionTitle('Recent Payslips'),
          const SizedBox(height: 12),
          ...records.map((record) => _PayslipRow(record: record)),
        ],
      ),
    );
  }
}

class _PayslipRow extends StatelessWidget {
  const _PayslipRow({required this.record});

  final SalarySlipRecord record;

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
        children: [
          const _SoftSalaryIcon(icon: Icons.description_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.month,
                  style: GoogleFonts.inter(
                    color: colors.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.netPay,
                  style: GoogleFonts.inter(
                    color: colors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1E9E62).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              record.status,
              style: GoogleFonts.inter(
                color: const Color(0xFF1E9E62),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: colors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalarySectionTitle extends StatelessWidget {
  const _SalarySectionTitle(this.title);

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

class _SoftSalaryIcon extends StatelessWidget {
  const _SoftSalaryIcon({required this.icon});

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

class _SalaryCard extends StatelessWidget {
  const _SalaryCard({
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

class SalarySlipRecord {
  const SalarySlipRecord({
    required this.month,
    required this.netPay,
    required this.status,
  });

  final String month;
  final String netPay;
  final String status;
}

class SalaryMonthData {
  const SalaryMonthData({
    required this.netPay,
    required this.grossPay,
    required this.deductions,
    required this.breakdown,
  });

  final String netPay;
  final String grossPay;
  final String deductions;
  final List<SalaryBreakdownItem> breakdown;
}

class SalaryBreakdownItem {
  const SalaryBreakdownItem({required this.label, required this.value});

  final String label;
  final String value;
}
