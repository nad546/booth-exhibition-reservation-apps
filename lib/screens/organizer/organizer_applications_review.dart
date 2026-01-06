// Converted to use RootScaffold
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/db_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/root_scaffold.dart';

class OrganizerApplicationsReviewScreen extends ConsumerStatefulWidget {
  const OrganizerApplicationsReviewScreen({super.key});

  @override
  ConsumerState<OrganizerApplicationsReviewScreen> createState() => _OrganizerApplicationsReviewScreenState();
}

class _OrganizerApplicationsReviewScreenState extends ConsumerState<OrganizerApplicationsReviewScreen> {
  final DBService _db = DBService();
  List<Map<String, dynamic>> _applications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadApplications());
  }

  Future<void> _loadApplications() async {
    setState(() => _loading = true);
    final auth = ref.read(authProvider);
    final username = auth.username;
    if (username == null) {
      setState(() {
        _applications = [];
        _loading = false;
      });
      return;
    }
    final apps = await _db.getApplicationsForOrganizer(username);
    setState(() {
      _applications = apps;
      _loading = false;
    });
  }

  Future<void> _approve(int appId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Approve application?'),
        content: const Text('Approving will mark the booth as BOOKED. Confirm?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Approve')),
        ],
      ),
    );
    if (confirmed == true) {
      await _db.updateApplicationStatus(appId, 'approved', reason: null);
      await _loadApplications();
    }
  }

  Future<void> _reject(int appId) async {
    final reasonCtrl = TextEditingController();
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject application'),
        content: TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Reason for rejection')),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Reject')),
        ],
      ),
    );
    if (res == true) {
      await _db.updateApplicationStatus(appId, 'rejected', reason: reasonCtrl.text.trim());
      await _loadApplications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RootScaffold(
      title: 'Organizer — Application Review',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _applications.isEmpty
              ? const Center(child: Text('No applications'))
              : ListView.builder(
                  itemCount: _applications.length,
                  itemBuilder: (context, i) {
                    final a = _applications[i];
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _loadRelated(a),
                      builder: (context, snap) {
                        final rel = snap.data;
                        final exhibitorName = rel?['exhibitor_name'] ?? 'Exhibitor';
                        final boothCode = rel?['booth_code'] ?? 'Booth';
                        final exhibitionTitle = rel?['exhibition_title'] ?? 'Exhibition';
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: ListTile(
                            title: Text('$exhibitionTitle — $boothCode'),
                            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Company: ${a['company_name'] ?? ''}'),
                              Text('Applicant: $exhibitorName'),
                              Text('Status: ${a['status'] ?? ''}'),
                              if (a['organizer_reason'] != null) Text('Reason: ${a['organizer_reason']}', style: const TextStyle(color: Colors.red)),
                            ]),
                            trailing: Wrap(spacing: 8, children: [
                              if ((a['status'] ?? '') == 'pending')
                                ElevatedButton(onPressed: () => _approve(a['id'] as int), child: const Text('Approve')),
                              if ((a['status'] ?? '') == 'pending')
                                OutlinedButton(onPressed: () => _reject(a['id'] as int), child: const Text('Reject')),
                            ]),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }

  Future<Map<String, dynamic>?> _loadRelated(Map<String, dynamic> appRow) async {
    final exhibitorId = appRow['exhibitor_id'] as int?;
    final boothId = appRow['booth_id'] as int?;
    final exhibitionId = appRow['exhibition_id'] as int?;
    String exhibitorName = '';
    String boothCode = '';
    String exhibitionTitle = '';

    if (exhibitorId != null) {
      final u = await _db.query('users', where: 'id = ?', whereArgs: [exhibitorId]);
      if (u.isNotEmpty) exhibitorName = u.first['display_name'] ?? u.first['username'] ?? '';
    }
    if (boothId != null) {
      final b = await _db.query('booths', where: 'id = ?', whereArgs: [boothId]);
      if (b.isNotEmpty) boothCode = b.first['booth_code'] ?? '';
    }
    if (exhibitionId != null) {
      final e = await _db.query('exhibitions', where: 'id = ?', whereArgs: [exhibitionId]);
      if (e.isNotEmpty) exhibitionTitle = e.first['title'] ?? '';
    }
    return {'exhibitor_name': exhibitorName, 'booth_code': boothCode, 'exhibition_title': exhibitionTitle};
  }
}