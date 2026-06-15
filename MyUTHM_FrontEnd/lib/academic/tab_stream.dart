import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uthm/database_helper.dart';

const Color _kHeaderColor = Color(0xFF001C55);
const Color _kBorderColor = Color(0xFFEEEEEE);
const Color _kPrimaryBlue = Color(0xFF0422A7);
const Color _kTrashRed = Color(0xFFC62828);

class StreamTab extends StatefulWidget {
  const StreamTab({
    super.key,
    required this.sectionId,
    required this.lecturerName,
    this.isLecturer = true,
  });

  final String sectionId;
  final String lecturerName;
  final bool isLecturer;

  @override
  State<StreamTab> createState() => _StreamTabState();
}

class _StreamTabState extends State<StreamTab> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void didUpdateWidget(covariant StreamTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sectionId != widget.sectionId) _loadPosts();
  }

  Future<void> _loadPosts() async {
    if (mounted) setState(() => _isLoading = true);
    if (widget.sectionId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _posts = [];
        _isLoading = false;
      });
      return;
    }
    final rows = await DatabaseHelper.instance.getStreams(widget.sectionId);
    if (!mounted) return;
    setState(() {
      _posts = rows;
      _isLoading = false;
    });
  }

  Future<void> _showStreamEditor({Map<String, dynamic>? existing}) async {
    String title = existing?['Title']?.toString() ?? '';
    String content = existing?['Content']?.toString() ?? '';

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add Stream Post' : 'Edit Stream Post'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 360,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                initialValue: title,
                onChanged: (value) => title = value,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Announcement',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: content,
                onChanged: (value) => content = value,
                minLines: 4,
                maxLines: 7,
                decoration: const InputDecoration(
                  labelText: 'Post content',
                  border: OutlineInputBorder(),
                ),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (content.trim().isEmpty) {
                _message('Post content is required.');
                return;
              }
              Navigator.pop(context, {
                'title': title.trim().isEmpty ? 'Announcement' : title.trim(),
                'content': content.trim(),
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimaryBlue,
              foregroundColor: Colors.white,
            ),
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );

    if (result == null) return;
    if (existing == null) {
      await DatabaseHelper.instance.insertStream(
        sectionId: widget.sectionId,
        title: result['title']!,
        content: result['content']!,
      );
      _message('Stream post created.');
    } else {
      await DatabaseHelper.instance.updateStream(
        streamId: existing['Stream_ID'].toString(),
        title: result['title']!,
        content: result['content']!,
      );
      _message('Stream post updated.');
    }
    await _loadPosts();
  }

  Future<void> _deleteStreamPost(Map<String, dynamic> post) async {
    await DatabaseHelper.instance.deleteStream(post['Stream_ID'].toString());
    await _loadPosts();
    _message('Stream post deleted.');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? Center(
                  child: Text('No Stream',
                      style: GoogleFonts.poppins(color: Colors.grey)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                  itemCount: _posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return _buildStreamPost(post);
                  },
                ),
      if (widget.isLecturer)
        Positioned(
          bottom: 24,
          right: 24,
          child: Material(
            color: _kPrimaryBlue,
            borderRadius: BorderRadius.circular(16),
            elevation: 6,
            child: InkWell(
              onTap: () => _showStreamEditor(),
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

  Widget _buildStreamPost(Map<String, dynamic> post) {
    final lecturerName =
        post['Lecturer_Name']?.toString().trim().isNotEmpty == true
            ? post['Lecturer_Name'].toString()
            : widget.lecturerName;
    final createdAt = _formatTimestamp(post['Created_At']?.toString());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _kBorderColor),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE91E63),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                lecturerName,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2196F3),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                createdAt,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ]),
          ),
          if (widget.isLecturer)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) {
                if (value == 'edit') _showStreamEditor(existing: post);
                if (value == 'delete') _deleteStreamPost(post);
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
            ),
        ]),
        const SizedBox(height: 14),
        Text(
          post['Title']?.toString() ?? 'Announcement',
          style: GoogleFonts.poppins(
            color: _kHeaderColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          post['Content']?.toString() ?? '',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ]),
    );
  }

  String _formatTimestamp(String? value) {
    final parsed = value == null ? null : DateTime.tryParse(value);
    if (parsed == null) return value ?? '';
    return DateFormat('dd MMM yyyy, h:mm a').format(parsed);
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }
}
