import 'package:flutter/material.dart';
import '../../widgets/root_scaffold.dart';
import '../../services/db_service.dart';
import 'package:go_router/go_router.dart';

class ManageBoothsScreen extends StatefulWidget {
  const ManageBoothsScreen({super.key});

  @override
  State<ManageBoothsScreen> createState() => _ManageBoothsScreenState();
}

class _ManageBoothsScreenState extends State<ManageBoothsScreen> {
  final DBService _db = DBService();
  List<Map<String, dynamic>> _exhibitions = [];
  List<Map<String, dynamic>> _booths = [];
  int? _selectedExhId;

  @override
  void initState() {
    super.initState();
    _loadExhibitions();
  }

  Future<void> _loadExhibitions() async {
    final exhs = await _db.getExhibitions();
    setState(() {
      _exhibitions = exhs;
    });
    if (_exhibitions.isNotEmpty) {
      _selectExhibition(_exhibitions.first['id'] as int);
    }
  }

  Future<void> _selectExhibition(int id) async {
    setState(() {
      _selectedExhId = id;
    });
    final booths = await _db.getBoothsByExhibition(id);
    setState(() {
      _booths = booths;
    });
  }

  Future<void> _deleteBooth(int id) async {
    await _db.deleteBooth(id);
    if (_selectedExhId != null) await _selectExhibition(_selectedExhId!);
  }

  @override
  Widget build(BuildContext context) {
    return RootScaffold(
      title: 'Manage Booths',
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            const Text('Exhibition: '),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedExhId,
                hint: const Text('Select exhibition'),
                items: _exhibitions.map((e) => DropdownMenuItem(value: e['id'] as int, child: Text(e['title'] ?? ''))).toList(),
                onChanged: (v) {
                  if (v != null) _selectExhibition(v);
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _selectedExhId == null ? null : () => context.goNamed('admin_floorplan'),
              child: const Text('Open Floorplan Mapping'),
            )
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: _booths.isEmpty
                ? const Center(child: Text('No booths found'))
                : ListView.builder(
                    itemCount: _booths.length,
                    itemBuilder: (context, i) {
                      final b = _booths[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text('${b['booth_code'] ?? ''}  — \$${(b['price'] ?? 0).toString()}'),
                          subtitle: Text('Status: ${b['status'] ?? ''}'),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                // open admin floorplan mapping for editing (user can tap box)
                                context.goNamed('admin_floorplan');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteBooth(b['id'] as int),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
          )
        ]),
      ),
    );
  }
}