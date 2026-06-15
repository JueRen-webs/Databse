import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uthm/database_helper.dart';

const Color _kHeaderColor = Color(0xFF001C55);
const Color _kBorderColor = Color(0xFFEEEEEE);
const Color _kPrimaryBlue = Color(0xFF0422A7);

class MarksTab extends StatefulWidget {
  const MarksTab({
    super.key,
    required this.sectionId,
    this.canManage = false,
  });

  final String sectionId;
  final bool canManage;

  @override
  State<MarksTab> createState() => _MarksTabState();
}

class _MarksTabState extends State<MarksTab> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _loadMarks();
  }

  @override
  void didUpdateWidget(covariant MarksTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sectionId != widget.sectionId) _loadMarks();
  }

  Future<void> _loadMarks() async {
    if (mounted) setState(() => _isLoading = true);
    if (widget.sectionId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _rows = [];
        _isLoading = false;
      });
      return;
    }
    final rows =
        await DatabaseHelper.instance.getMarksForSection(widget.sectionId);
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _isLoading = false;
    });
  }

  List<String> get _componentIds {
    final seen = <String>{};
    final ids = <String>[];
    for (final row in _rows) {
      final id = row['Assessment_ID']?.toString() ?? '';
      if (id.isNotEmpty && seen.add(id)) ids.add(id);
    }
    return ids;
  }

  List<Map<String, dynamic>> get _students {
    final seen = <String>{};
    final students = <Map<String, dynamic>>[];
    for (final row in _rows) {
      final id = row['Student_ID']?.toString() ?? '';
      if (id.isNotEmpty && seen.add(id)) {
        students.add({
          'Student_ID': id,
          'Student_Name': row['Student_Name']?.toString() ?? id,
        });
      }
    }
    return students;
  }

  Map<String, dynamic>? _markRow(String studentId, String assessmentId) {
    for (final row in _rows) {
      if (row['Student_ID']?.toString() == studentId &&
          row['Assessment_ID']?.toString() == assessmentId) {
        return row;
      }
    }
    return null;
  }

  Map<String, dynamic>? _componentRow(String assessmentId) {
    for (final row in _rows) {
      if (row['Assessment_ID']?.toString() == assessmentId) return row;
    }
    return null;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<Map<String, dynamic>> _studentRowsForCurrentUser() {
    final studentId = DatabaseHelper.currentUserId;
    final rows = _rows
        .where((row) => row['Student_ID']?.toString() == studentId)
        .toList();
    if (rows.isNotEmpty) return rows;

    final fallbackStudentId =
        _rows.isEmpty ? '' : _rows.first['Student_ID']?.toString() ?? '';
    if (fallbackStudentId.isEmpty) return const [];
    return _rows
        .where((row) => row['Student_ID']?.toString() == fallbackStudentId)
        .toList();
  }

  Future<void> _editStudentMarks(Map<String, dynamic> student) async {
    final controllers = <String, TextEditingController>{};
    for (final id in _componentIds) {
      final row = _markRow(student['Student_ID'].toString(), id);
      controllers[id] =
          TextEditingController(text: row?['Marks']?.toString() ?? '0');
    }

    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Edit Marks',
            style: GoogleFonts.poppins(
              color: _kHeaderColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['Student_Name'].toString(),
                    style: GoogleFonts.poppins(
                      color: _kPrimaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    student['Student_ID'].toString(),
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._componentIds.map((id) {
                    final component = _componentRow(id);
                    final title = component?['Assessment_Title']?.toString() ??
                        'Assessment';
                    final max = component?['max_marks']?.toString() ?? '-';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: controllers[id],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '$title /$max',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (saved == true) {
        for (final entry in controllers.entries) {
          final value = double.tryParse(entry.value.text.trim()) ?? 0;
          await DatabaseHelper.instance.upsertAssessmentMark(
            assessmentId: entry.key,
            studentId: student['Student_ID'].toString(),
            marks: value,
          );
        }
        await _loadMarks();
        _message('Marks updated.');
      }
    } finally {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_rows.isEmpty) {
      return Center(
        child: Text('No Marks', style: GoogleFonts.poppins(color: Colors.grey)),
      );
    }
    return widget.canManage ? _buildLecturerView() : _buildStudentView();
  }

  Widget _buildLecturerView() {
    final students = _students;
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(
            child: _summaryCard(
              Icons.groups_outlined,
              'Students: ${students.length}',
              _kPrimaryBlue,
              const Color(0xFFEAF0FF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _summaryCard(
              Icons.assignment_outlined,
              'Components: ${_componentIds.length}',
              const Color(0xFF26A69A),
              const Color(0xFFE0F2F1),
            ),
          ),
        ]),
      ),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final student = students[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kBorderColor),
              ),
              child: Column(children: [
                Row(children: [
                  CircleAvatar(
                    backgroundColor: _kPrimaryBlue,
                    child: Text('${index + 1}',
                        style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student['Student_Name'].toString(),
                            style: GoogleFonts.poppins(
                                color: _kHeaderColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                        Text(student['Student_ID'].toString(),
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade700, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit marks',
                    onPressed: () => _editStudentMarks(student),
                    icon: const Icon(Icons.edit_outlined, color: _kPrimaryBlue),
                  ),
                ]),
                const Divider(height: 22),
                ..._componentIds.map((id) {
                  final row = _markRow(student['Student_ID'].toString(), id);
                  final component = _componentRow(id);
                  final title = component?['Assessment_Title']?.toString() ??
                      'Assessment';
                  final max = component?['max_marks']?.toString() ?? '-';
                  final marks = row?['Marks']?.toString() ?? '0';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      Expanded(
                        child: Text(title,
                            style: GoogleFonts.poppins(fontSize: 12)),
                      ),
                      Text(
                        '$marks / $max',
                        style: GoogleFonts.poppins(
                          color: _kPrimaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ]),
                  );
                }),
              ]),
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildStudentView() {
    final visibleRows = _studentRowsForCurrentUser();
    final rawTotal = visibleRows.fold<double>(
      0,
      (sum, row) => sum + _toDouble(row['Marks']),
    );
    final maxTotal = visibleRows.fold<double>(
      0,
      (sum, row) => sum + _toDouble(row['max_marks']),
    );
    final weightedTotal = visibleRows.fold<double>(
      0,
      (sum, row) {
        final maxMarks = _toDouble(row['max_marks']);
        final weightage = _toDouble(row['weightage']);
        if (maxMarks <= 0) return sum;
        return sum + (_toDouble(row['Marks']) / maxMarks * weightage);
      },
    );
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(
            child: _summaryCard(
              Icons.star_border,
              'Total ${weightedTotal.toStringAsFixed(1)}%',
              const Color(0xFF26A69A),
              const Color(0xFFE0F2F1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _summaryCard(
              Icons.assignment_outlined,
              'Raw ${rawTotal.toStringAsFixed(1)}/${maxTotal.toStringAsFixed(1)}',
              _kPrimaryBlue,
              const Color(0xFFEAF0FF),
            ),
          ),
        ]),
      ),
      Container(
        color: _kHeaderColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          SizedBox(width: 34, child: _header('No.')),
          Expanded(flex: 4, child: _header('Assessment')),
          Expanded(flex: 2, child: _header('Marks')),
        ]),
      ),
      Expanded(
        child: visibleRows.isEmpty
            ? Center(
                child: Text('No Marks',
                    style: GoogleFonts.poppins(color: Colors.grey)),
              )
            : ListView.separated(
                itemCount: visibleRows.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: _kBorderColor),
                itemBuilder: (context, index) {
                  final row = visibleRows[index];
                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Row(children: [
                      SizedBox(
                        width: 34,
                        child: Text('${index + 1}.',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          row['Assessment_Title']?.toString() ?? 'Assessment',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${row['Marks']} / ${row['max_marks']}',
                          style: GoogleFonts.poppins(
                              color: _kPrimaryBlue,
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                      ),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }

  Widget _summaryCard(
      IconData icon, String label, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 26, color: iconColor),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _header(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }
}
