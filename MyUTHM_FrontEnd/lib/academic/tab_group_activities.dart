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
const Color _kStatusFull = Color(0xFFE53935);
const Color _kStatusAvailable = Color(0xFF43A047);
const Color _kNameBlue = Color(0xFF1976D2);

class GroupActivitiesTab extends StatefulWidget {
  const GroupActivitiesTab({
    super.key,
    required this.sectionId,
    this.canManage = false,
  });

  final String sectionId;
  final bool canManage;

  @override
  State<GroupActivitiesTab> createState() => _GroupActivitiesTabState();
}

class _GroupActivitiesTabState extends State<GroupActivitiesTab> {
  bool _isLoading = true;
  int _attachmentRefresh = 0;
  int _submissionRefresh = 0;
  Map<String, dynamic>? _selectedActivity;

  List<Map<String, dynamic>> _groupActivities = [];
  List<Map<String, dynamic>> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  @override
  void didUpdateWidget(covariant GroupActivitiesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sectionId != widget.sectionId) {
      _selectedActivity = null;
      _loadActivities();
    }
  }

  Future<void> _loadActivities() async {
    if (mounted) setState(() => _isLoading = true);

    if (widget.sectionId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _groupActivities = [];
        _isLoading = false;
      });
      return;
    }

    final rows = await DatabaseHelper.instance.getAssignments(
      widget.sectionId,
      '2',
    );
    if (!mounted) return;

    setState(() {
      _groupActivities = rows;
      _isLoading = false;
    });
  }

  Future<void> _loadGroups() async {
    if (_selectedActivity == null) return;
    final rows = await DatabaseHelper.instance.getAssignmentGroups(
      _selectedActivity!["Assignment_ID"].toString(),
      _currentStudentId,
    );
    if (!mounted) return;
    setState(() => _groups = rows);
  }

  Future<void> _showGroupActivityEditor(
      {Map<String, dynamic>? existing}) async {
    String title = existing?["Assignment_Title"]?.toString() ?? "";
    String maxMembers = existing?["Max_Members"]?.toString() ?? "5";
    String groupCount = existing == null ? "4" : _groups.length.toString();
    DateTime? selectedDate = _parseDate(existing?["Due_Date"]?.toString());
    TimeOfDay? selectedTime = _parseTime(existing?["Due_Time"]?.toString());
    PlatformFile? pickedFile;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text(
              existing == null ? "Add Group Activity" : "Edit Group Activity",
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
                      labelText: "Activity title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    initialValue: maxMembers,
                    onChanged: (value) => maxMembers = value,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Max members",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    initialValue: groupCount,
                    onChanged: (value) => groupCount = value,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Number of groups",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _pickerTile(
                    icon: Icons.calendar_today_outlined,
                    label: "Due date",
                    value: selectedDate == null
                        ? "Select date"
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
                    label: "Due time",
                    value: selectedTime == null
                        ? "Select time"
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
                          ? "Choose Attachment"
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
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.pop(dialogContext, {
                    "title": title.trim(),
                    "maxMembers": int.tryParse(maxMembers) ?? 5,
                    "groupCount": int.tryParse(groupCount) ?? 1,
                    "dueDate": _formatDate(selectedDate),
                    "dueTime": _formatTime(selectedTime),
                    "file": pickedFile,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: Text(existing == null ? "Create" : "Save"),
              ),
            ],
          );
        });
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (result == null || result["title"].toString().isEmpty) return;
    if (widget.sectionId.isEmpty) {
      _showMessage("Create failed: section id is missing.");
      return;
    }
    if (!_isValidFutureDue(
      result["dueDate"].toString(),
      result["dueTime"].toString(),
    )) {
      _showMessage("Please select a future due date and time.");
      return;
    }

    final PlatformFile? file = result["file"] as PlatformFile?;
    try {
      if (existing == null) {
        final assignmentId = await DatabaseHelper.instance.insertAssignment(
          sectionId: widget.sectionId,
          assignmentTypeId: '2',
          title: result["title"].toString(),
          maxMembers: result["maxMembers"] as int,
          dueDate: result["dueDate"].toString(),
          dueTime: result["dueTime"].toString(),
        );
        await _saveAttachment(assignmentId, file);
        await DatabaseHelper.instance.createAssignmentGroups(
          assignmentId,
          result["groupCount"] as int,
        );
        await DatabaseHelper.instance.insertAutoStream(
          sectionId: widget.sectionId,
          title: "Group Activity",
          action: "created group activity ${result["title"]}",
        );
        _showMessage("Group activity created.");
      } else {
        await DatabaseHelper.instance.updateAssignment(
          assignmentId: existing["Assignment_ID"].toString(),
          title: result["title"].toString(),
          maxMembers: result["maxMembers"] as int,
          dueDate: result["dueDate"].toString(),
          dueTime: result["dueTime"].toString(),
        );
        await _saveAttachment(existing["Assignment_ID"].toString(), file);
        await DatabaseHelper.instance.syncAssignmentGroups(
          existing["Assignment_ID"].toString(),
          result["groupCount"] as int,
        );
        if (_selectedActivity?["Assignment_ID"] == existing["Assignment_ID"]) {
          _selectedActivity = {
            ...existing,
            "Assignment_Title": result["title"].toString(),
            "Max_Members": result["maxMembers"] as int,
            "Due_Date": result["dueDate"].toString(),
            "Due_Time": result["dueTime"].toString(),
          };
        }
        _showMessage("Group activity updated.");
      }
    } catch (error) {
      _showMessage("Create failed: $error");
      return;
    }

    await _loadActivities();
  }

  Future<void> _saveAttachment(String assignmentId, PlatformFile? file) async {
    if (file == null) return;
    final fileBytes = file.bytes ??
        (file.path == null ? null : await File(file.path!).readAsBytes());
    if (fileBytes == null || fileBytes.isEmpty) {
      _showMessage("File could not be read.");
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
      _showMessage("Attachment uploaded.");
    } catch (error) {
      _showMessage("Attachment upload failed: $error");
    }
  }

  Future<void> _deleteAttachment(Map<String, dynamic> file) async {
    final attachmentId = file["Attachment_ID"]?.toString() ?? "";
    if (attachmentId.isEmpty) return;
    await DatabaseHelper.instance.deleteAssignmentAttachment(attachmentId);
    if (mounted) {
      setState(() => _attachmentRefresh++);
      _showMessage("Attachment deleted.");
    }
  }

  Future<void> _downloadFile(Map<String, dynamic> file) async {
    final attachmentId = file["Attachment_ID"];
    final submissionId = file["Submission_ID"];
    final path = attachmentId != null
        ? await DatabaseHelper.instance.downloadStoredFileById(
            tableName: "Assignment_Attachments",
            idColumn: "Attachment_ID",
            id: attachmentId,
            fileName: file["File_Name"]?.toString() ?? "attachment",
            blobColumn: "File_URL",
          )
        : await DatabaseHelper.instance.downloadStoredFileById(
            tableName: "Submissions",
            idColumn: "Submission_ID",
            id: submissionId ?? "",
            fileName: file["File_Name"]?.toString() ?? "submission",
            blobColumn: "File_URL",
          );
    if (path == null || path.isEmpty) {
      _showMessage("File path is empty.");
      return;
    }
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done) {
      _showMessage("Cannot open file: ${result.message}");
    }
  }

  Future<void> _submitGroupFile(String groupId) async {
    if (_selectedActivity == null) return;
    final files = await FilePicker.platform.pickFiles(withData: true);
    if (files == null || files.files.isEmpty) return;
    final file = files.files.first;
    final fileBytes = file.bytes ??
        (file.path == null ? null : await File(file.path!).readAsBytes());
    if (fileBytes == null || fileBytes.isEmpty) {
      _showMessage("File could not be read.");
      return;
    }
    await DatabaseHelper.instance.insertSubmission(
      assignmentId: _selectedActivity!["Assignment_ID"].toString(),
      studentId: _currentStudentId,
      groupId: groupId,
      fileName: file.name,
      fileBytes: fileBytes,
      uploadedDate: _formatUploadedDate(DateTime.now()),
    );
    if (mounted) setState(() => _submissionRefresh++);
    _showMessage("${file.name} submitted.");
  }

  Future<void> _deleteSubmission(Map<String, dynamic> file) async {
    final submissionId = file["Submission_ID"]?.toString() ?? "";
    if (submissionId.isEmpty) return;
    await DatabaseHelper.instance.deleteSubmission(submissionId);
    if (mounted) {
      setState(() => _submissionRefresh++);
      _showMessage("Submission deleted.");
    }
  }

  Future<void> _deleteGroupActivity(Map<String, dynamic> item) async {
    try {
      final deleted = await DatabaseHelper.instance
          .deleteAssignment(item["Assignment_ID"].toString());
      if (_selectedActivity?["Assignment_ID"] == item["Assignment_ID"]) {
        _selectedActivity = null;
      }
      await _loadActivities();
      _showMessage(
        deleted > 0 ? "Group activity deleted." : "Activity not found.",
      );
    } catch (error) {
      _showMessage("Delete failed: $error");
    }
  }

  @override
  Widget build(BuildContext context) => _selectedActivity == null
      ? _buildActivityList()
      : _buildGroupSelectionList();

  Widget _buildActivityList() {
    return Stack(children: [
      Column(children: [
        _buildBreadcrumb(items: ["Activity List", "Folder"]),
        const Divider(height: 1, color: _kBorderColor),
        Container(
          color: _kHeaderColor,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: const Row(children: [
            SizedBox(
                width: 48,
                child: Text("No.",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            Expanded(
                flex: 3,
                child: Text("Activities\n(Click)",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            Expanded(
                flex: 3,
                child: Text("Due Date",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            SizedBox(width: 44),
          ]),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _groupActivities.isEmpty
                  ? Center(
                      child: Text("No Activities",
                          style: GoogleFonts.poppins(color: Colors.grey)),
                    )
                  : ListView.separated(
                      itemCount: _groupActivities.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: _kBorderColor),
                      itemBuilder: (ctx, i) {
                        final item = _groupActivities[i];
                        return InkWell(
                          onTap: () async {
                            setState(() => _selectedActivity = item);
                            await _loadGroups();
                          },
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      width: 48,
                                      child: Text("${i + 1}.",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Colors.black87))),
                                  Expanded(
                                      flex: 3,
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.people,
                                                size: 16, color: Colors.green),
                                            const SizedBox(width: 8),
                                            Expanded(
                                                child: Text(
                                                    item["Assignment_Title"]
                                                            ?.toString() ??
                                                        "Untitled",
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13,
                                                        color: _kLinkColor))),
                                          ])),
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
              onTap: () => _showGroupActivityEditor(),
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

  Widget _buildGroupSelectionList() {
    final maxMembers =
        int.tryParse(_selectedActivity?["Max_Members"]?.toString() ?? "5") ?? 5;

    return Column(children: [
      _buildBreadcrumb(
        items: [
          "Activity List",
          _selectedActivity!["Assignment_Title"].toString()
        ],
        onTapRoot: () => setState(() => _selectedActivity = null),
      ),
      const Divider(height: 1, color: _kBorderColor),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: const Color(0xFFE3F2FD),
        child: Row(children: [
          const Icon(Icons.info_outline, color: _kPrimaryBlue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.canManage
                  ? "View submitted groups and member details for this activity."
                  : "Please select a group to join. Maximum $maxMembers members per group.",
              style: GoogleFonts.poppins(color: _kPrimaryBlue, fontSize: 13),
            ),
          ),
        ]),
      ),
      _buildAssignmentFiles(_selectedActivity!),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _groups.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (ctx, i) {
            final group = _groups[i];
            final memberCount =
                int.tryParse(group['Member_Count']?.toString() ?? '0') ?? 0;
            final isMember = group['Is_Joined']?.toString() == '1';
            final groupId = group['Group_ID'].toString();
            final groupName = "GROUP ${group['Group_Number']}";
            return _buildGroupCard(
              groupId: groupId,
              groupName: groupName,
              memberCount: memberCount,
              maxMembers: maxMembers,
              isFull: memberCount >= maxMembers,
              isMember: !widget.canManage && isMember,
              isLecturerView: widget.canManage,
              onJoin: () async {
                if (memberCount >= maxMembers) return;
                final joined =
                    await DatabaseHelper.instance.joinAssignmentGroup(
                  assignmentId: _selectedActivity!["Assignment_ID"].toString(),
                  groupId: groupId,
                  studentId: _currentStudentId,
                );
                if (!joined) {
                  _showMessage("You have already joined a group.");
                  return;
                }
                await _loadGroups();
              },
              onQuit: () async {
                await DatabaseHelper.instance.quitAssignmentGroup(
                  groupId: groupId,
                  studentId: _currentStudentId,
                );
                await _loadGroups();
              },
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildActivityMenu(Map<String, dynamic> item) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey, size: 22),
      onSelected: (value) {
        if (value == "edit") _showGroupActivityEditor(existing: item);
        if (value == "delete") _deleteGroupActivity(item);
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: "edit",
          child: Row(children: [
            Icon(Icons.edit_outlined, color: _kPrimaryBlue, size: 20),
            SizedBox(width: 8),
            Text("Edit"),
          ]),
        ),
        PopupMenuItem(
          value: "delete",
          child: Row(children: [
            Icon(Icons.delete_outline, color: _kTrashRed, size: 20),
            SizedBox(width: 8),
            Text("Delete"),
          ]),
        ),
      ],
    );
  }

  Widget _buildGroupCard({
    required String groupId,
    required String groupName,
    required int memberCount,
    required int maxMembers,
    required bool isFull,
    required bool isMember,
    required bool isLecturerView,
    required VoidCallback onJoin,
    required VoidCallback onQuit,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.groups, size: 40, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLecturerView)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                            color: _kPrimaryBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text("GROUP MEMBERS",
                            style: TextStyle(
                                color: _kPrimaryBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      )
                    else if (isMember)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green)),
                        child: const Text("JOINED",
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      )
                    else if (isFull)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 6),
                        decoration: BoxDecoration(
                            color: _kStatusFull,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text("FULL",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: onJoin,
                        icon: const Icon(Icons.add,
                            size: 16, color: Colors.white),
                        label: const Text("JOIN THIS GROUP",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kStatusAvailable,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 0),
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(groupName,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _kNameBlue)),
                    const SizedBox(height: 4),
                    Text(
                        "$memberCount of $maxMembers (MAX) joined. ${maxMembers - memberCount} available",
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.black87)),
                  ]),
            ),
            if (isMember)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (v) {
                  if (v == 'upload') _submitGroupFile(groupId);
                  if (v == 'quit') onQuit();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'upload',
                      child: Row(children: [
                        Icon(Icons.upload_file, size: 20, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Upload File')
                      ])),
                  const PopupMenuItem(
                      value: 'quit',
                      child: Row(children: [
                        Icon(Icons.logout, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Quit Group', style: TextStyle(color: Colors.red))
                      ])),
                ],
              ),
          ]),
        ),
        const Divider(height: 1, color: _kBorderColor),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper.instance.getGroupMembers(groupId),
          builder: (context, snapshot) {
            final members = snapshot.data ?? [];
            if (members.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: members.map((member) {
                  final studentId = member['Student_ID']?.toString() ?? '';
                  final studentName =
                      member['Student_Name']?.toString() ?? studentId;
                  final isMe = studentId == _currentStudentId;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  isMe ? _kPrimaryBlue : Colors.grey,
                              child: const Icon(Icons.person,
                                  color: Colors.white, size: 24)),
                          const SizedBox(width: 12),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isMe ? "$studentName (ME)" : studentName,
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isMe ? _kPrimaryBlue : _kNameBlue)),
                                Text(studentId,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: Colors.black87)),
                              ]),
                        ]),
                  );
                }).toList(),
              ),
            );
          },
        ),
        _buildGroupSubmissions(groupId),
      ]),
    );
  }

  Widget _buildGroupSubmissions(String groupId) {
    if (_selectedActivity == null) return const SizedBox.shrink();
    return FutureBuilder<List<Map<String, dynamic>>>(
      key: ValueKey("group-submissions-$_submissionRefresh-$groupId"),
      future: DatabaseHelper.instance.getSubmissions(
        assignmentId: _selectedActivity!["Assignment_ID"].toString(),
        groupId: groupId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              "Could not load submitted files: ${snapshot.error}",
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          );
        }
        final files = snapshot.data ?? [];
        if (files.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Files Submitted",
                style: GoogleFonts.poppins(
                    color: _kPrimaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ...files.map((file) {
              return Row(children: [
                const Icon(Icons.upload_file_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file["File_Name"]?.toString() ?? "Submitted file",
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                IconButton(
                  tooltip: "Download",
                  onPressed: () => _downloadFile(file),
                  icon: const Icon(Icons.download_outlined,
                      color: _kPrimaryBlue, size: 20),
                ),
                if (!widget.canManage &&
                    file["Student_ID"]?.toString() == _currentStudentId)
                  IconButton(
                    tooltip: "Delete",
                    onPressed: () => _deleteSubmission(file),
                    icon: const Icon(Icons.delete_outline,
                        color: _kTrashRed, size: 20),
                  ),
              ]);
            }),
          ]),
        );
      },
    );
  }

  Widget _buildAssignmentFiles(Map<String, dynamic> activity) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      key: ValueKey(_attachmentRefresh),
      future: DatabaseHelper.instance.getAssignmentAttachments(
        activity["Assignment_ID"].toString(),
      ),
      builder: (context, snapshot) {
        final files = snapshot.data ?? [];
        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text("Files",
                    style: GoogleFonts.poppins(
                        color: _kHeaderColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
              if (widget.canManage)
                IconButton(
                  tooltip: "Add attachment",
                  onPressed: () => _pickAndSaveAttachment(
                    activity["Assignment_ID"].toString(),
                  ),
                  icon: const Icon(Icons.add, color: _kPrimaryBlue),
                ),
            ]),
            const SizedBox(height: 6),
            if (files.isEmpty)
              Text("No attached files.",
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade700, fontSize: 12))
            else
              ...files.asMap().entries.map((entry) {
                final file = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Text("${entry.key + 1}."),
                    const SizedBox(width: 8),
                    const Icon(Icons.description_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${file['File_Name']} (${file['File_Size'] ?? '-'})",
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      tooltip: "Download",
                      onPressed: () => _downloadFile(file),
                      icon: const Icon(Icons.download_outlined,
                          color: _kPrimaryBlue, size: 20),
                    ),
                    if (widget.canManage)
                      IconButton(
                        tooltip: "Delete",
                        onPressed: () => _deleteAttachment(file),
                        icon: const Icon(Icons.delete_outline,
                            color: _kTrashRed, size: 20),
                      ),
                  ]),
                );
              }),
          ]),
        );
      },
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
        decoration: const InputDecoration(border: OutlineInputBorder())
            .copyWith(labelText: label),
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
        ...items.asMap().entries.map((e) {
          final idx = e.key;
          final text = e.value;
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
    final date = item["Due_Date"]?.toString() ?? "";
    final time = item["Due_Time"]?.toString() ?? "";
    if (date.isEmpty && time.isEmpty) return "No Due Date";
    if (time.isEmpty) return date;
    if (date.isEmpty) return time;
    return "$date @ $time";
  }

  bool _isValidFutureDue(String dueDate, String dueTime) {
    if (dueDate.isEmpty || dueTime.isEmpty) return false;
    final due = _dueDateTimeFromStrings(dueDate, dueTime);
    return due != null && due.isAfter(DateTime.now());
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
        : "AI248888";
  }

  String _formatUploadedDate(DateTime date) {
    final day = date.day.toString().padLeft(2, "0");
    final month = date.month.toString().padLeft(2, "0");
    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");
    return "${date.year}-$month-$day $hour:$minute";
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "";
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "";
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, "0");
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty || value == "---") return null;
    final parts = value.split(" ");
    if (parts.length < 3) return null;
    const months = {
      "Jan": 1,
      "Feb": 2,
      "Mar": 3,
      "Apr": 4,
      "May": 5,
      "Jun": 6,
      "Jul": 7,
      "Aug": 8,
      "Sep": 9,
      "Oct": 10,
      "Nov": 11,
      "Dec": 12,
    };
    final day = int.tryParse(parts[0]);
    final month = months[parts[1]];
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final match = RegExp(r"^(\d{1,2}):(\d{2})\s*(AM|PM)$", caseSensitive: false)
        .firstMatch(value.trim());
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final isPm = match.group(3)!.toUpperCase() == "PM";
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return "$bytes B";
    final kb = bytes / 1024;
    if (kb < 1024) return "${kb.toStringAsFixed(1)}KB";
    return "${(kb / 1024).toStringAsFixed(1)}MB";
  }
}
