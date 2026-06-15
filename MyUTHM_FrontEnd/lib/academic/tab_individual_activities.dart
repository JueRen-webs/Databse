import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:uthm/database_helper.dart';

const Color _kHeaderColor = Color(0xFF001C55);
const Color _kBorderColor = Color(0xFFEEEEEE);
const Color _kLinkColor = Color(0xFFA93226);
const Color _kPrimaryBlue = Color(0xFF0422A7);
const Color _kTrashRed = Color(0xFFC62828);
const Color _kCoordOrange = Color(0xFFEF6C00);
const Color _kCoordBlue = Color(0xFF1565C0);

class IndividualActivitiesTab extends StatefulWidget {
  const IndividualActivitiesTab({
    super.key,
    required this.sectionId,
    required this.canManage,
  });

  final String sectionId;
  final bool canManage;

  @override
  State<IndividualActivitiesTab> createState() =>
      _IndividualActivitiesTabState();
}

class _IndividualActivitiesTabState extends State<IndividualActivitiesTab> {
  bool _isLoading = true;
  int _attachmentRefresh = 0;
  int _submissionRefresh = 0;
  Timer? _remainingTimer;
  Map<String, dynamic>? _openedActivity;
  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _remainingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _openedActivity != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _remainingTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant IndividualActivitiesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sectionId != widget.sectionId) {
      _openedActivity = null;
      _loadActivities();
    }
  }

  Future<void> _loadActivities() async {
    if (mounted) setState(() => _isLoading = true);

    if (widget.sectionId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _activities = [];
        _isLoading = false;
      });
      return;
    }

    final rows = await DatabaseHelper.instance.getAssignments(
      widget.sectionId,
      '1',
    );
    if (!mounted) return;

    setState(() {
      _activities = rows;
      _isLoading = false;
      if (_openedActivity != null) {
        final openedId = _openedActivity!['Assignment_ID']?.toString();
        _openedActivity = rows.cast<Map<String, dynamic>?>().firstWhere(
              (item) => item?['Assignment_ID']?.toString() == openedId,
              orElse: () => null,
            );
      }
    });
  }

  Future<void> _showEditor({Map<String, dynamic>? existing}) async {
    String title = existing?['Assignment_Title']?.toString() ?? '';
    DateTime? selectedDate = _parseDate(existing?['Due_Date']?.toString());
    TimeOfDay? selectedTime = _parseTime(existing?['Due_Time']?.toString());
    PlatformFile? pickedFile;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text(
              existing == null
                  ? 'Add Individual Activity'
                  : 'Edit Individual Activity',
              style: GoogleFonts.poppins(
                color: _kHeaderColor,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 360,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    initialValue: title,
                    onChanged: (value) => title = value,
                    decoration: const InputDecoration(
                      labelText: 'Activity title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _pickerTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Due date',
                    value: selectedDate == null
                        ? 'Select date'
                        : _formatDate(selectedDate),
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: _validInitialDate(selectedDate),
                        firstDate: _dateOnly(DateTime.now()),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _pickerTile(
                    icon: Icons.schedule_outlined,
                    label: 'Due time',
                    value: selectedTime == null
                        ? 'Select time'
                        : selectedTime!.format(dialogContext),
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      final picked = await showTimePicker(
                        context: dialogContext,
                        initialTime: selectedTime ??
                            const TimeOfDay(hour: 23, minute: 59),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedTime = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      final files = await FilePicker.platform.pickFiles();
                      if (files != null && files.files.isNotEmpty) {
                        setDialogState(() => pickedFile = files.files.first);
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      pickedFile == null
                          ? 'Choose Attachment'
                          : pickedFile!.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.pop(dialogContext, {
                    'title': title.trim(),
                    'dueDate': _formatDate(selectedDate),
                    'dueTime': _formatTime(selectedTime),
                    'file': pickedFile,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: Text(existing == null ? 'Create' : 'Save'),
              ),
            ],
          );
        });
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (result == null || result['title'].toString().isEmpty) return;
    if (widget.sectionId.isEmpty) {
      _showMessage('Create failed: section id is missing.');
      return;
    }
    if (!_isValidFutureDue(
      result['dueDate'].toString(),
      result['dueTime'].toString(),
    )) {
      _showMessage('Please select a future due date and time.');
      return;
    }

    final PlatformFile? file = result['file'] as PlatformFile?;
    try {
      if (existing == null) {
        final assignmentId = await DatabaseHelper.instance.insertAssignment(
          sectionId: widget.sectionId,
          assignmentTypeId: '1',
          title: result['title'].toString(),
          maxMembers: 1,
          dueDate: result['dueDate'].toString(),
          dueTime: result['dueTime'].toString(),
        );
        await _saveAttachment(assignmentId, file);
        await DatabaseHelper.instance.insertAutoStream(
          sectionId: widget.sectionId,
          title: 'Individual Activity',
          action: 'created individual activity ${result['title']}',
        );
        _showMessage('Individual activity created.');
      } else {
        await DatabaseHelper.instance.updateAssignment(
          assignmentId: existing['Assignment_ID'].toString(),
          title: result['title'].toString(),
          maxMembers: 1,
          dueDate: result['dueDate'].toString(),
          dueTime: result['dueTime'].toString(),
        );
        await _saveAttachment(existing['Assignment_ID'].toString(), file);
        _showMessage('Individual activity updated.');
      }
    } catch (error) {
      _showMessage('Create failed: $error');
      return;
    }
    await _loadActivities();
  }

  Future<void> _saveAttachment(String assignmentId, PlatformFile? file) async {
    if (file == null) return;
    final fileBytes = file.bytes ??
        (file.path == null ? null : await File(file.path!).readAsBytes());
    if (fileBytes == null || fileBytes.isEmpty) {
      _showMessage('File could not be read.');
      return;
    }
    await DatabaseHelper.instance.insertAssignmentAttachment(
      assignmentId: assignmentId,
      fileName: file.name,
      fileSize: _formatBytes(file.size),
      fileBytes: fileBytes,
    );
    if (mounted) setState(() => _attachmentRefresh++);
  }

  Future<void> _pickAndSaveAttachment(String assignmentId) async {
    final files = await FilePicker.platform.pickFiles(withData: true);
    if (files == null || files.files.isEmpty) return;
    try {
      await _saveAttachment(assignmentId, files.files.first);
      _showMessage('Attachment uploaded.');
    } catch (error) {
      _showMessage('Attachment upload failed: $error');
    }
  }

  Future<void> _deleteAttachment(Map<String, dynamic> file) async {
    final attachmentId = file['Attachment_ID']?.toString() ?? '';
    if (attachmentId.isEmpty) return;
    await DatabaseHelper.instance.deleteAssignmentAttachment(attachmentId);
    if (mounted) {
      setState(() => _attachmentRefresh++);
      _showMessage('Attachment deleted.');
    }
  }

  Future<void> _pickSubmissionFile() async {
    final files = await FilePicker.platform.pickFiles(withData: true);
    if (files == null || files.files.isEmpty || !mounted) return;
    if (_openedActivity == null) return;
    final file = files.files.first;
    final fileBytes = file.bytes ??
        (file.path == null ? null : await File(file.path!).readAsBytes());
    if (fileBytes == null || fileBytes.isEmpty) {
      _showMessage('File could not be read.');
      return;
    }
    await DatabaseHelper.instance.insertSubmission(
      assignmentId: _openedActivity!['Assignment_ID'].toString(),
      studentId: _currentStudentId,
      fileName: file.name,
      fileBytes: fileBytes,
      uploadedDate: _formatUploadedDate(DateTime.now()),
    );
    if (mounted) {
      setState(() => _submissionRefresh++);
      _showMessage('${file.name} submitted.');
    }
  }

  Future<void> _deleteSubmission(Map<String, dynamic> file) async {
    final submissionId = file['Submission_ID']?.toString() ?? '';
    if (submissionId.isEmpty) return;
    await DatabaseHelper.instance.deleteSubmission(submissionId);
    if (mounted) {
      setState(() => _submissionRefresh++);
      _showMessage('Submission deleted.');
    }
  }

  Future<void> _downloadFile(Map<String, dynamic> file) async {
    final attachmentId = file['Attachment_ID'];
    final submissionId = file['Submission_ID'];
    final path = attachmentId != null
        ? await DatabaseHelper.instance.downloadStoredFileById(
            tableName: 'Assignment_Attachments',
            idColumn: 'Attachment_ID',
            id: attachmentId,
            fileName: file['File_Name']?.toString() ?? 'attachment',
            blobColumn: 'File_URL',
          )
        : await DatabaseHelper.instance.downloadStoredFileById(
            tableName: 'Submissions',
            idColumn: 'Submission_ID',
            id: submissionId ?? '',
            fileName: file['File_Name']?.toString() ?? 'submission',
            blobColumn: 'File_URL',
          );
    if (path == null || path.isEmpty) {
      _showMessage('File path is empty.');
      return;
    }
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done) {
      _showMessage('Cannot open file: ${result.message}');
    }
  }

  Future<void> _deleteActivity(Map<String, dynamic> item) async {
    try {
      final deleted = await DatabaseHelper.instance
          .deleteAssignment(item['Assignment_ID'].toString());
      if (_openedActivity?['Assignment_ID'] == item['Assignment_ID']) {
        _openedActivity = null;
      }
      await _loadActivities();
      _showMessage(
        deleted > 0 ? 'Individual activity deleted.' : 'Activity not found.',
      );
    } catch (error) {
      _showMessage('Delete failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_openedActivity != null) return _buildDetail();
    return _buildList();
  }

  Widget _buildList() {
    return Stack(children: [
      Column(children: [
        _buildBreadcrumb(items: const ['Activity List', 'Folder']),
        const Divider(height: 1, color: _kBorderColor),
        Container(
          color: _kHeaderColor,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: const Row(children: [
            SizedBox(
                width: 48,
                child: Text('No.',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            Expanded(
                flex: 3,
                child: Text('Activities\n(Click)',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            Expanded(
                flex: 3,
                child: Text('Due Date',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            SizedBox(width: 44),
          ]),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _activities.isEmpty
                  ? Center(
                      child: Text('No Activities',
                          style: GoogleFonts.poppins(color: Colors.grey)),
                    )
                  : ListView.separated(
                      itemCount: _activities.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: _kBorderColor),
                      itemBuilder: (ctx, i) {
                        final item = _activities[i];
                        return InkWell(
                          onTap: () => setState(() => _openedActivity = item),
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      width: 48,
                                      child: Text('${i + 1}.',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Colors.black87))),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                          item['Assignment_Title']
                                                  ?.toString() ??
                                              'Untitled',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: _kLinkColor))),
                                  Expanded(
                                      flex: 3,
                                      child: Text(_displayDue(item),
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black87))),
                                  SizedBox(
                                    width: 44,
                                    child: widget.canManage
                                        ? _buildActivityMenu(item)
                                        : null,
                                  ),
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
              onTap: () => _showEditor(),
              borderRadius: BorderRadius.circular(16),
              child: const SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
    ]);
  }

  Widget _buildDetail() {
    final activity = _openedActivity!;

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _detailTitleBar(
            activity['Assignment_Title']?.toString() ?? 'Assignment'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: _summaryPanel(
                  icon: Icons.calendar_today_outlined,
                  title: 'Due Date',
                  value: _displayFullDue(activity),
                  accent: _kCoordOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryPanel(
                  icon: Icons.timer_outlined,
                  title: 'Remaining Time',
                  value: _remainingText(activity),
                  accent: _kPrimaryBlue,
                ),
              ),
            ]),
            const SizedBox(height: 20),
            _sectionHeader(
              'Attachment',
              action: widget.canManage
                  ? IconButton(
                      tooltip: 'Add attachment',
                      onPressed: () => _pickAndSaveAttachment(
                        activity['Assignment_ID'].toString(),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                    )
                  : null,
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              key: ValueKey(
                'individual-attachments-${activity['Assignment_ID']}-$_attachmentRefresh',
              ),
              future: DatabaseHelper.instance.getAssignmentAttachments(
                activity['Assignment_ID'].toString(),
              ),
              builder: (context, snapshot) {
                final files = snapshot.data ?? [];
                return Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: files.isEmpty
                      ? Text('No attached files.',
                          style: GoogleFonts.poppins(fontSize: 14))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: files.asMap().entries.map((entry) {
                            final file = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(children: [
                                Text('${entry.key + 1}.'),
                                const SizedBox(width: 8),
                                const Icon(Icons.description_outlined,
                                    size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${file['File_Name']} (${file['File_Size'] ?? '-'})',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Download',
                                  onPressed: () => _downloadFile(file),
                                  icon: const Icon(Icons.download_outlined,
                                      color: _kPrimaryBlue, size: 20),
                                ),
                                if (widget.canManage)
                                  IconButton(
                                    tooltip: 'Delete attachment',
                                    onPressed: () => _deleteAttachment(file),
                                    icon: const Icon(Icons.delete_outline,
                                        color: _kTrashRed, size: 20),
                                  ),
                              ]),
                            );
                          }).toList(),
                        ),
                );
              },
            ),
            const SizedBox(height: 20),
            _sectionHeader('Submitted Files'),
            _buildSubmittedFiles(activity),
            if (!widget.canManage) ...[
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: _kPrimaryBlue,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 5,
                  child: InkWell(
                    onTap: _pickSubmissionFile,
                    borderRadius: BorderRadius.circular(16),
                    child: const SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _buildActivityMenu(Map<String, dynamic> item) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey, size: 22),
      onSelected: (value) {
        if (value == 'edit') _showEditor(existing: item);
        if (value == 'delete') _deleteActivity(item);
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, color: _kPrimaryBlue, size: 20),
            SizedBox(width: 8),
            Text('Edit'),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, color: _kTrashRed, size: 20),
            SizedBox(width: 8),
            Text('Delete'),
          ]),
        ),
      ],
    );
  }

  Widget _detailTitleBar(String title) {
    return Container(
      height: 64,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Stack(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: 'Back',
            onPressed: () => setState(() => _openedActivity = null),
            icon: const Icon(Icons.arrow_back, color: _kHeaderColor),
          ),
        ),
        Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: _kHeaderColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _summaryPanel({
    required IconData icon,
    required String title,
    required String value,
    required Color accent,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: _kHeaderColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ]),
    );
  }

  Widget _buildSubmittedFiles(Map<String, dynamic> activity) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      key: ValueKey(
        'individual-submissions-${activity['Assignment_ID']}-$_submissionRefresh',
      ),
      future: DatabaseHelper.instance.getSubmissions(
        assignmentId: activity['Assignment_ID'].toString(),
        studentId: widget.canManage ? null : _currentStudentId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Text(
              'Could not load submitted files: ${snapshot.error}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          );
        }
        final files = snapshot.data ?? [];
        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: files.isEmpty
              ? Text(
                  'No submitted files.',
                  style: GoogleFonts.poppins(fontSize: 14),
                )
              : Column(
                  children: files.asMap().entries.map((entry) {
                    final file = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        Text('${entry.key + 1}.'),
                        const SizedBox(width: 8),
                        const Icon(Icons.upload_file_outlined, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${file['File_Name']} (${file['Uploaded_Date'] ?? '-'})',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Download',
                          onPressed: () => _downloadFile(file),
                          icon: const Icon(Icons.download_outlined,
                              color: _kPrimaryBlue, size: 20),
                        ),
                        if (!widget.canManage)
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: () => _deleteSubmission(file),
                            icon: const Icon(Icons.delete_outline,
                                color: _kTrashRed, size: 20),
                          ),
                      ]),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, {Widget? action}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: _kCoordBlue,
      child: Row(children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        if (action != null) action,
      ]),
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: _kPrimaryBlue),
          const SizedBox(width: 10),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }

  Widget _buildBreadcrumb(
      {required List<String> items, VoidCallback? onTapRoot}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(children: [
        const Icon(Icons.description_outlined, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        ...items.asMap().entries.map((entry) {
          final idx = entry.key;
          final text = entry.value;
          final isFirst = idx == 0;
          return Row(children: [
            isFirst && onTapRoot != null
                ? InkWell(
                    onTap: onTapRoot,
                    child: Text(text,
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            decoration: TextDecoration.underline)))
                : Text(text,
                    style: GoogleFonts.poppins(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 14)),
            if (idx < items.length - 1) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              const SizedBox(width: 8)
            ],
          ]);
        }).toList(),
        const SizedBox(width: 8),
        const Icon(Icons.folder_open, color: Colors.grey, size: 20),
      ]),
    );
  }

  String _displayDue(Map<String, dynamic> item) {
    final date = item['Due_Date']?.toString() ?? '';
    final time = item['Due_Time']?.toString() ?? '';
    if (date.isEmpty && time.isEmpty) return 'No Due Date';
    if (time.isEmpty) return date;
    if (date.isEmpty) return time;
    return '$date @ $time';
  }

  String _displayFullDue(Map<String, dynamic> item) {
    final due = _dueDateTimeFromItem(item);
    if (due == null) return 'No Due Date';
    return '${_weekdayName(due.weekday)}, ${_formatDate(due)}\n@ ${_formatTime(TimeOfDay.fromDateTime(due))}';
  }

  String _remainingText(Map<String, dynamic> item) {
    final due = _dueDateTimeFromItem(item);
    if (due == null) return 'No Due Date';
    final remaining = due.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    if (days > 0) return '${days}d ${hours}h ${minutes}m ${seconds}s';
    if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
    return '${minutes}m ${seconds}s';
  }

  bool _isValidFutureDue(String dueDate, String dueTime) {
    if (dueDate.isEmpty || dueTime.isEmpty) return false;
    final due = _dueDateTimeFromStrings(dueDate, dueTime);
    return due != null && due.isAfter(DateTime.now());
  }

  DateTime? _dueDateTimeFromItem(Map<String, dynamic> item) {
    return _dueDateTimeFromStrings(
      item['Due_Date']?.toString() ?? '',
      item['Due_Time']?.toString() ?? '',
    );
  }

  DateTime? _dueDateTimeFromStrings(String dueDate, String dueTime) {
    final date = _parseDate(dueDate);
    final time = _parseTime(dueTime);
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _validInitialDate(DateTime? selectedDate) {
    final today = _dateOnly(DateTime.now());
    if (selectedDate == null || selectedDate.isBefore(today)) return today;
    return selectedDate;
  }

  String _weekdayName(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }

  void _showMessage(String message) {
    if (!mounted) return;
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 24,
        right: 24,
        bottom: 96,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2F2D35),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      try {
        entry.remove();
      } catch (_) {}
    });
  }

  String get _currentStudentId {
    return DatabaseHelper.currentUserId.isNotEmpty
        ? DatabaseHelper.currentUserId
        : 'AI248888';
  }

  String _formatUploadedDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty || value == '---') return null;
    final parts = value.split(' ');
    if (parts.length < 3) return null;
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    final day = int.tryParse(parts[0]);
    final month = months[parts[1]];
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
        .firstMatch(value.trim());
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final isPm = match.group(3)!.toUpperCase() == 'PM';
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)}KB';
    return '${(kb / 1024).toStringAsFixed(1)}MB';
  }
}
