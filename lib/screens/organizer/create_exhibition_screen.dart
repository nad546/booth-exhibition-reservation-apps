import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/db_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/root_scaffold.dart';
import 'package:go_router/go_router.dart';

class CreateExhibitionScreen extends ConsumerStatefulWidget {
  const CreateExhibitionScreen({super.key});

  @override
  ConsumerState<CreateExhibitionScreen> createState() =>
      _CreateExhibitionScreenState();
}

class _CreateExhibitionScreenState
    extends ConsumerState<CreateExhibitionScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final DBService _db = DBService();

  String _svgAsset = 'assets/svg/expo1.svg';
  bool _isPublished = true;

  String? _error;

  DateTimeRange? _dateRange;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  final List<String> _svgOptions = [
    'assets/svg/expo1.svg',
    'assets/svg/expo2.svg',
  ];

  final DateFormat _fmtDateTime = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
      initialDateRange:
      _dateRange ?? DateTimeRange(start: now, end: now.add(const Duration(days: 1))),
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  String? _validate() {
    if (_titleCtrl.text.trim().isEmpty) {
      return 'Title is required';
    }

    if (_dateRange == null) {
      return 'Date range is required';
    }

    final start = DateTime(
      _dateRange!.start.year,
      _dateRange!.start.month,
      _dateRange!.start.day,
      _startTime.hour,
      _startTime.minute,
    );

    final end = DateTime(
      _dateRange!.end.year,
      _dateRange!.end.month,
      _dateRange!.end.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (end.isBefore(start)) {
      return 'End time must be after start time';
    }

    return null;
  }

  Future<void> _submit() async {
    final auth = ref.read(authProvider);

    final validationError = _validate();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    if (auth.username == null || auth.role != 'organizer') {
      setState(() =>
      _error = 'You must be logged in as an organizer to create exhibitions.');
      return;
    }

    final user = await _db.query(
      'users',
      where: 'username = ?',
      whereArgs: [auth.username],
    );

    if (user.isEmpty) {
      setState(() => _error = 'Organizer account not found');
      return;
    }

    final organizerId = user.first['id'] as int;

    final start = DateTime(
      _dateRange!.start.year,
      _dateRange!.start.month,
      _dateRange!.start.day,
      _startTime.hour,
      _startTime.minute,
    );

    final end = DateTime(
      _dateRange!.end.year,
      _dateRange!.end.month,
      _dateRange!.end.day,
      _endTime.hour,
      _endTime.minute,
    );

    await _db.saveExhibition({
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'start_date': _fmtDateTime.format(start),
      'end_date': _fmtDateTime.format(end),
      'is_published': _isPublished ? 1 : 0,
      'svg_asset': _svgAsset,
      'organizer_id': organizerId,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Exhibition created')));

    context.goNamed('guest_home');
  }

  @override
  Widget build(BuildContext context) {
    return RootScaffold(
      title: 'Create Exhibition',
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: _pickDateRange,
                child: Text(
                  _dateRange == null
                      ? 'Pick Exhibition Dates'
                      : '${_fmtDateTime.format(_dateRange!.start)} → ${_fmtDateTime.format(_dateRange!.end)}',
                ),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _svgAsset,
                items: _svgOptions
                    .map((s) =>
                    DropdownMenuItem(value: s, child: Text(s.split('/').last)))
                    .toList(),
                onChanged: (v) => setState(() => _svgAsset = v ?? _svgAsset),
                decoration: const InputDecoration(labelText: 'Floorplan SVG'),
              ),

              SwitchListTile(
                title: const Text('Publish now'),
                value: _isPublished,
                onChanged: (v) => setState(() => _isPublished = v),
              ),

              const SizedBox(height: 8),

              if (_error != null)
                Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _submit,
                child: const Text('Create Exhibition'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
