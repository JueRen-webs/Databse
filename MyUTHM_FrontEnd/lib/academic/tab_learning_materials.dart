import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:uthm/database_helper.dart';

const Color _kBorderColor = Color(0xFFEEEEEE);
const Color _kPrimaryBlue = Color(0xFF0422A7);
const Color _kSelectionBg = Color(0xFFE3F2FD);

class LearningMaterialsTab extends StatefulWidget {
  const LearningMaterialsTab({
    super.key,
    required this.sectionId,
    required this.canManage,
  });

  final String sectionId;
  final bool canManage;

  @override
  State<LearningMaterialsTab> createState() => _LearningMaterialsTabState();
}

class _LearningMaterialsTabState extends State<LearningMaterialsTab> {
  bool _isLoading = true;
  final Set<int> _selectedIndices = {};
  List<Map<String, dynamic>> _materials = [];

  bool get _isSelectionMode => _selectedIndices.isNotEmpty;
  bool get _isAllSelected =>
      _selectedIndices.length == _materials.length && _materials.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  @override
  void didUpdateWidget(covariant LearningMaterialsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sectionId != widget.sectionId) {
      _loadMaterials();
    }
  }

  Future<void> _loadMaterials() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _selectedIndices.clear();
      });
    }

    if (widget.sectionId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _materials = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final rows =
          await DatabaseHelper.instance.getLearningMaterials(widget.sectionId);
      if (!mounted) return;

      setState(() {
        _materials = rows.asMap().entries.map((entry) {
          final row = entry.value;
          return {
            "no": "${entry.key + 1}",
            "id": row['Materials_ID']?.toString() ?? "",
            "title": row['Title']?.toString() ?? "Untitled Material",
            "size": row['Size']?.toString() ?? "-",
            "date": row['Uploaded_Date']?.toString() ?? "-",
          };
        }).toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _materials = [];
        _isLoading = false;
      });
      _showMessage("Could not load materials: $error");
    }
  }

  void _handleSelectAllToggle() {
    setState(() {
      if (_isAllSelected) {
        _selectedIndices.clear();
      } else {
        _selectedIndices
          ..clear()
          ..addAll(List.generate(_materials.length, (i) => i));
      }
    });
  }

  void _cancelSelectionMode() {
    setState(() => _selectedIndices.clear());
  }

  Future<void> _downloadAndOpenFile(Map<String, dynamic> item) async {
    final path = await DatabaseHelper.instance.downloadStoredFileById(
      tableName: 'Learning_Materials',
      idColumn: 'Materials_ID',
      id: item['id'] ?? '',
      fileName: item['title']?.toString() ?? 'learning_material',
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
        .where((index) => index >= 0 && index < _materials.length)
        .map((index) => _materials[index])
        .toList();

    if (selectedItems.length == 1) {
      await _downloadAndOpenFile(selectedItems.first);
    } else if (selectedItems.length > 1) {
      final zipPath =
          await DatabaseHelper.instance.downloadStoredFilesAsZipById(
        tableName: 'Learning_Materials',
        idColumn: 'Materials_ID',
        items: selectedItems,
        itemIdColumn: 'id',
        itemFileNameColumn: 'title',
        blobColumn: 'URL',
        zipBaseName: "learning_materials",
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

  Future<void> _deleteMaterial(Map<String, dynamic> item) async {
    final materialId = item["id"] ?? "";
    if (materialId.isEmpty) return;

    await DatabaseHelper.instance.deleteLearningMaterial(materialId);
    await _loadMaterials();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Learning material deleted."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showAddDialog() async {
    final pickResult = await FilePicker.platform.pickFiles(withData: true);
    if (pickResult == null || pickResult.files.isEmpty) return;

    final file = pickResult.files.first;
    String materialTitle = _nameWithoutExtension(file.name);
    if (!mounted) return;

    final dialogResult = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Upload Learning Material"),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              children: [
                const Icon(Icons.description, color: _kPrimaryBlue, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: materialTitle,
              onChanged: (value) => materialTitle = value,
              decoration: const InputDecoration(
                labelText: "Material title",
                border: OutlineInputBorder(),
              ),
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, {"title": materialTitle}),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text("Upload"),
          ),
        ],
      ),
    );

    if (dialogResult == null ||
        dialogResult["title"]!.trim().isEmpty ||
        widget.sectionId.isEmpty) {
      return;
    }

    final fileBytes = file.bytes ??
        (file.path == null ? null : await File(file.path!).readAsBytes());
    if (fileBytes == null || fileBytes.isEmpty) {
      _showMessage("File path is empty.");
      return;
    }
    await DatabaseHelper.instance.insertLearningMaterial(
      widget.sectionId,
      dialogResult["title"]!.trim(),
      _formatBytes(file.size),
      _formatDate(DateTime.now()),
      fileBytes,
    );
    await DatabaseHelper.instance.insertAutoStream(
      sectionId: widget.sectionId,
      title: "Learning Materials",
      action: "uploaded learning material ${dialogResult["title"]!.trim()}",
    );

    await _loadMaterials();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("File Uploaded Successfully!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(children: [
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(children: [
              const Icon(Icons.folder_copy_outlined,
                  color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                "Learning Materials List",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ]),
          ),
          const Divider(height: 1, color: _kBorderColor),
          _buildActionBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _materials.isEmpty
                    ? Center(
                        child: Text(
                          "No Materials",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _materials.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: _kBorderColor),
                        itemBuilder: (context, index) {
                          final item = _materials[index];
                          final isSelected = _selectedIndices.contains(index);

                          return InkWell(
                            onLongPress: () {
                              if (!isSelected) {
                                setState(() => _selectedIndices.add(index));
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
                                vertical: 16.0,
                                horizontal: 20.0,
                              ),
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["title"]!.toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF1565C0),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              const Color(0xFF1565C0),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: [
                                          _infoBadge(item["size"] ?? "-"),
                                          _infoBadge(item["date"] ?? "-"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.canManage) ...[
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _deleteMaterial(item),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red.shade700,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ]),
                            ),
                          );
                        },
                      ),
          ),
        ]),
        if (widget.canManage)
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
            _handleSelectAllToggle,
          ),
          if (_selectedIndices.isNotEmpty)
            _actionBtn(
              Icons.download,
              "Download (${_selectedIndices.length})",
              _downloadSelected,
            ),
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
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: _kPrimaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return "$bytes B";
    final kb = bytes / 1024;
    if (kb < 1024) return "${kb.toStringAsFixed(1)}KB";
    return "${(kb / 1024).toStringAsFixed(1)}MB";
  }

  String _nameWithoutExtension(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex <= 0) return name;
    return name.substring(0, dotIndex);
  }
}
