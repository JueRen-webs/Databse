import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import '../database_helper.dart';

const Color _kBorderColor = Color(0xFFEEEEEE);
const Color _kPrimaryBlue = Color(0xFF0422A7);
const Color _kSelectionBg = Color(0xFFE3F2FD);

class PastYearQuestionsTab extends StatefulWidget {
  const PastYearQuestionsTab({
    super.key,
    this.isLecturer = true,
    required this.canManage,
    required this.courseId,
    required this.sectionId,
  });

  final bool isLecturer;
  final bool canManage;
  final String courseId;
  final String sectionId;

  @override
  State<PastYearQuestionsTab> createState() => _PastYearQuestionsTabState();
}

class _PastYearQuestionsTabState extends State<PastYearQuestionsTab> {
  final Set<int> _selectedIndices = {};
  List<Map<String, dynamic>> _pastYears = [];
  bool _isLoading = true;

  bool get _isSelectionMode => _selectedIndices.isNotEmpty;
  bool get _isAllSelected =>
      _selectedIndices.length == _pastYears.length && _pastYears.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final data =
          await DatabaseHelper.instance.getPastYearQuestions(widget.courseId);
      if (!mounted) return;
      setState(() {
        _pastYears = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pastYears = [];
        _isLoading = false;
      });
      _showMessage("Could not load past year questions: $error");
    }
  }

  void _handleSelectAllToggle() {
    setState(() {
      if (_isAllSelected) {
        _selectedIndices.clear();
      } else {
        _selectedIndices.clear();
        for (int i = 0; i < _pastYears.length; i++) {
          _selectedIndices.add(i);
        }
      }
    });
  }

  void _cancelSelectionMode() {
    setState(() {
      _selectedIndices.clear();
    });
  }

  Future<void> _downloadAndOpenFile(Map<String, dynamic> item) async {
    final path = await DatabaseHelper.instance.downloadStoredFileById(
      tableName: 'Past_Year_Questions',
      idColumn: 'Past_Year_ID',
      id: item['Past_Year_ID'] ?? '',
      fileName: item['Title']?.toString() ?? 'past_year_question',
      blobColumn: 'URL',
    );
    if (path == null || path.isEmpty) {
      _showMessage("File path is empty.");
      return;
    }

    _showMessage("Downloaded 1 file.");
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done) {
      _showMessage("Cannot open file: ${result.message}");
    }
  }

  Future<void> _downloadSelected() async {
    if (_selectedIndices.isEmpty) return;

    final selectedItems = _selectedIndices
        .where((index) => index >= 0 && index < _pastYears.length)
        .map((index) => _pastYears[index])
        .toList();

    if (selectedItems.length == 1) {
      await _downloadAndOpenFile(selectedItems.first);
    } else if (selectedItems.length > 1) {
      final zipPath =
          await DatabaseHelper.instance.downloadStoredFilesAsZipById(
        tableName: 'Past_Year_Questions',
        idColumn: 'Past_Year_ID',
        items: selectedItems,
        itemIdColumn: 'Past_Year_ID',
        itemFileNameColumn: 'Title',
        blobColumn: 'URL',
        zipBaseName: "past_year_questions",
      );
      if (zipPath == null) {
        _showMessage("No files could be downloaded.");
      } else {
        _showMessage("Downloaded ${selectedItems.length} files as zip.");
      }
    }

    _cancelSelectionMode();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _deletePyq(Map<String, dynamic> item) async {
    final id = item["Past_Year_ID"]?.toString() ?? "";
    if (id.isEmpty) return;
    await DatabaseHelper.instance.deletePastYearQuestion(id);
    await _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Past year question deleted."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showAddDialog() async {
    FilePickerResult? pickResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (pickResult == null || pickResult.files.isEmpty) return;

    PlatformFile file = pickResult.files.first;
    if (!mounted) return;

    final titleCtrl = TextEditingController(
        text:
            file.name.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), ''));
    final yearCtrl = TextEditingController(text: "2026");

    final dialogResult = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Upload Past Year Question"),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // 顯示選中的檔案名稱與圖示
            Row(
              children: [
                const Icon(Icons.picture_as_pdf,
                    color: Colors.redAccent, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file.name,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                    labelText: "Question title", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: yearCtrl,
                decoration: const InputDecoration(
                    labelText: "Year (e.g. 23/24)",
                    border: OutlineInputBorder())),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(
                ctx, {"title": titleCtrl.text, "year": yearCtrl.text}),
            style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimaryBlue, foregroundColor: Colors.white),
            child: const Text("Upload"),
          ),
        ],
      ),
    );

    if (dialogResult == null || dialogResult["title"]!.trim().isEmpty) return;

    final fileBytes = file.bytes ??
        (file.path == null ? null : await File(file.path!).readAsBytes());
    if (fileBytes == null || fileBytes.isEmpty) {
      _showMessage("File path is empty.");
      return;
    }
    await DatabaseHelper.instance.insertPastYearQuestion(
      widget.courseId,
      dialogResult["title"]!.trim(),
      dialogResult["year"]!.trim().isEmpty
          ? "2026"
          : dialogResult["year"]!.trim(),
      fileBytes,
    );
    await DatabaseHelper.instance.insertAutoStream(
      sectionId: widget.sectionId,
      title: "Past Year Questions",
      action: "uploaded past year question ${dialogResult["title"]!.trim()}",
    );

    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("File Uploaded Successfully!"),
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  // ── Build UI ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(children: [
          // Header
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(children: [
              const Icon(Icons.history_edu, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                "Past Year Questions List",
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ),
            ]),
          ),
          const Divider(height: 1, color: _kBorderColor),

          // Action bar
          _buildActionBar(),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pastYears.isEmpty
                    ? Center(
                        child: Text("No past year questions available.",
                            style: GoogleFonts.poppins(color: Colors.grey)))
                    : ListView.separated(
                        itemCount: _pastYears.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: _kBorderColor),
                        itemBuilder: (context, index) {
                          final item = _pastYears[index];
                          final isSelected = _selectedIndices.contains(index);

                          final displayTitle =
                              item["Title"] ?? item["title"] ?? "UNTITLED";
                          final displayYear =
                              item["Session"] ?? item["year"] ?? "N/A";

                          return InkWell(
                            onLongPress: () {
                              if (!isSelected) {
                                setState(() {
                                  _selectedIndices.add(index);
                                });
                              }
                            },
                            onTap: () {
                              if (_isSelectionMode) {
                                setState(() {
                                  isSelected
                                      ? _selectedIndices.remove(index)
                                      : _selectedIndices.add(index);
                                });
                              } else {
                                _downloadAndOpenFile(item);
                              }
                            },
                            child: Container(
                              color: isSelected ? _kSelectionBg : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 20.0),
                              child: Row(children: [
                                if (_isSelectionMode) ...[
                                  SizedBox(
                                    width: 30,
                                    child: Icon(
                                      isSelected
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: isSelected
                                          ? _kPrimaryBlue
                                          : Colors.grey.shade400,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 8.0,
                                    children: [
                                      Text(
                                        displayTitle.toString().toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF1565C0),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              const Color(0xFF1565C0),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: Text(
                                          displayYear.toString(),
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.canManage)
                                  IconButton(
                                    tooltip: "Delete",
                                    onPressed: () => _deletePyq(item),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 22,
                                    ),
                                  ),
                              ]),
                            ),
                          );
                        },
                      ),
          ),
        ]),

        // FAB
        if (widget.isLecturer)
          Positioned(
            bottom: 24,
            right: 24,
            child: Material(
              color: _kPrimaryBlue,
              borderRadius: BorderRadius.circular(16),
              elevation: 6,
              child: InkWell(
                onTap: _showAddDialog,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Action Bar ────────────────────────────────

  Widget _buildActionBar() {
    return Container(
      width: double.infinity,
      color: _isSelectionMode ? _kSelectionBg : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 12.0,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _actionBtn(
              _isAllSelected ? Icons.deselect : Icons.select_all,
              _isAllSelected ? "Deselect All" : "Select All",
              _handleSelectAllToggle),
          if (_selectedIndices.isNotEmpty)
            _actionBtn(Icons.download, "Download (${_selectedIndices.length})",
                _downloadSelected),
          if (_isSelectionMode)
            _actionBtn(Icons.close, "Cancel", _cancelSelectionMode),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18, color: _kPrimaryBlue),
          const SizedBox(width: 6),
          Text(text,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: _kPrimaryBlue,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
