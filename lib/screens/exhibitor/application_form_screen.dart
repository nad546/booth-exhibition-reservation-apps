import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/db_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';

class ApplicationFormScreen extends ConsumerStatefulWidget {
  final int exhibitionId;
  final String selectedBoothIdsCsv;

  const ApplicationFormScreen({
    super.key,
    required this.exhibitionId,
    required this.selectedBoothIdsCsv,
  });

  @override
  ConsumerState<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState
    extends ConsumerState<ApplicationFormScreen> {

  final _companyCtrl = TextEditingController();
  final _companyDescCtrl = TextEditingController();
  final _profileCtrl = TextEditingController();

  String? _eventStart;
  String? _eventEnd;

  String? _selectedAddons;
  String? _error;

  final List<String> _addonOptions = [
    "Extra Furniture",
    "Promotional Banner",
    "Extended Wi-Fi",
    "Electrical Outlet",
    "Storage Space"
  ];

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    final boothIds = widget.selectedBoothIdsCsv
        .split(',')
        .where((s) => s.isNotEmpty)
        .map(int.tryParse)
        .whereType<int>()
        .toList();

    return Scaffold(
      drawer: const AppDrawer(),

      appBar: AppBar(
        title: const Text('Application Form'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [

            Center(
              child: Text("Applying for booths: ${boothIds.join(', ')}"),
            ),

            const SizedBox(height: 12),

            // -------------------------
            // Company name
            // -------------------------
            TextField(
              controller: _companyCtrl,
              decoration: const InputDecoration(
                labelText: "Company Name",
              ),
            ),

            // Company description
            TextField(
              controller: _companyDescCtrl,
              decoration: const InputDecoration(
                labelText: "Company Description",
              ),
            ),

            // Exhibit profile
            TextField(
              controller: _profileCtrl,
              decoration: const InputDecoration(
                labelText: "Exhibit Profile (What will be showcased)",
              ),
            ),

            const SizedBox(height: 12),

            // -------------------------
            // EVENT DATES
            // -------------------------
            const Text("Exhibition Event Duration"),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                        initialDate: DateTime.now(),
                      );

                      if (date != null) {
                        setState(() => _eventStart = date.toString());
                      }
                    },
                    child: Text(
                      _eventStart == null
                          ? "Select Start Date"
                          : _eventStart!,
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                        initialDate: DateTime.now(),
                      );

                      if (date != null) {
                        setState(() => _eventEnd = date.toString());
                      }
                    },
                    child: Text(
                      _eventEnd == null
                          ? "Select End Date"
                          : _eventEnd!,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // -------------------------
            // ADD-ON SERVICES
            // -------------------------
            const Text("Optional Add-On Items"),

            DropdownButtonFormField<String>(
              value: _selectedAddons,
              hint: const Text("Select Add-On"),
              items: _addonOptions.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedAddons = val);
              },
            ),

            const SizedBox(height: 12),

            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),

            // -------------------------
            // SUBMIT BUTTON
            // -------------------------
            ElevatedButton(
              onPressed: () async {
                if (auth.username == null) {
                  context.goNamed('login');
                  return;
                }

                if (_companyCtrl.text.trim().isEmpty) {
                  setState(() => _error = "Company name required");
                  return;
                }

                final db = DBService();

                final userRow = await db.query(
                  "users",
                  where: "username = ?",
                  whereArgs: [auth.username],
                );

                if (userRow.isEmpty) {
                  setState(() => _error = "User not found");
                  return;
                }

                final exhibitorId = userRow.first["id"] as int;

                for (final boothId in boothIds) {
                  await db.insert("applications", {
                    "exhibitor_id": exhibitorId,
                    "exhibition_id": widget.exhibitionId,
                    "booth_id": boothId,
                    "company_name": _companyCtrl.text.trim(),
                    "company_description": _companyDescCtrl.text.trim(),
                    "exhibit_profile": _profileCtrl.text.trim(),
                    "event_startdate": _eventStart ?? "",
                    "event_enddate": _eventEnd ?? "",
                    "status": "pending",
                    "organizer_reason": "",
                  });
                }

                if (!context.mounted) return;

                context.goNamed("my_applications");
              },
              child: const Text("Submit Application"),
            ),
          ],
        ),
      ),
    );
  }
}
