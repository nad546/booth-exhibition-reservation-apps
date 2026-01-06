import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/db_service.dart';
import '../../widgets/booth_edit_dialog.dart';
import '../../widgets/root_scaffold.dart';

class AdminFloorplanManageScreen extends StatefulWidget {
  const AdminFloorplanManageScreen({super.key});

  @override
  State<AdminFloorplanManageScreen> createState() =>
      _AdminFloorplanManageScreenState();
}

class _AdminFloorplanManageScreenState
    extends State<AdminFloorplanManageScreen> {
  final DBService _db = DBService();
  List<Map<String, dynamic>> _exhibitions = [];
  int? _selectedExhId;
  String? _selectedSvgAsset;
  List<Map<String, dynamic>> _booths = [];

  Offset? _dragStart;
  Offset? _dragCurrent;
  Rect? _previewRect;

  final double svgViewW = 1000.0;
  final double svgViewH = 800.0;

  @override
  void initState() {
    super.initState();
    _loadExhibitions();
  }

  Future<void> _loadExhibitions() async {
    final exhs = await _db.getExhibitions();
    setState(() {
      _exhibitions = exhs;
      if (_exhibitions.isNotEmpty) {
        _selectedExhId ??= _exhibitions.first['id'] as int;
        _selectedSvgAsset ??=
        _exhibitions.first['svg_asset'] as String?;
      }
    });
    if (_selectedExhId != null) await _loadBooths(_selectedExhId!);
  }

  Future<void> _loadBooths(int exhibitionId) async {
    final b = await _db.getBoothsByExhibition(exhibitionId);
    setState(() {
      _booths = b;
    });
  }

  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {
    setState(() {
      _dragStart = details.localPosition;
      _dragCurrent = _dragStart;
      _updatePreviewRect(constraints);
    });
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    setState(() {
      _dragCurrent = details.localPosition;
      _updatePreviewRect(constraints);
    });
  }

  void _onPanEnd(BoxConstraints constraints) async {
    if (_previewRect == null || _selectedExhId == null) {
      setState(() {
        _dragStart = null;
        _dragCurrent = null;
        _previewRect = null;
      });
      return;
    }
    final px = _previewRect!;
    final renderW = constraints.maxWidth;
    final scale = renderW / svgViewW;
    final svgX = px.left / scale;
    final svgY = px.top / scale;
    final svgW = px.width / scale;
    final svgH = px.height / scale;

    final res =
    await showDialog<Map<String, dynamic>>(context: context, builder: (_) {
      final codeCtrl = TextEditingController();
      final priceCtrl = TextEditingController();
      final sizeCtrl = TextEditingController();
      return AlertDialog(
        title: const Text('Create booth'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: codeCtrl,
                decoration:
                const InputDecoration(labelText: 'Booth code')),
            TextField(
                controller: priceCtrl,
                decoration:
                const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number),
            TextField(
                controller: sizeCtrl,
                decoration: const InputDecoration(
                    labelText: 'Size (e.g., 20sqm)')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop({
                'booth_code': codeCtrl.text.trim(),
                'price': double.tryParse(priceCtrl.text) ?? 0.0,
                'size': sizeCtrl.text.trim(),
              });
            },
            child: const Text('Save'),
          )
        ],
      );
    });

    if (res != null) {
      final boothMap = {
        'booth_code': res['booth_code'] ??
            'B-${DateTime.now().millisecondsSinceEpoch}',
        'exhibition_id': _selectedExhId,
        'price': res['price'] ?? 0.0,
        'size': res['size'] ?? '',
        'status': 'available',
        'x': svgX,
        'y': svgY,
        'width': svgW,
        'height': svgH,
      };
      await _db.saveBooth(boothMap);
      await _loadBooths(_selectedExhId!);
    }

    setState(() {
      _dragStart = null;
      _dragCurrent = null;
      _previewRect = null;
    });
  }

  void _updatePreviewRect(BoxConstraints constraints) {
    if (_dragStart == null || _dragCurrent == null) {
      _previewRect = null;
      return;
    }
    final start = _dragStart!;
    final curr = _dragCurrent!;
    final left = mathMin(start.dx, curr.dx);
    final top = mathMin(start.dy, curr.dy);
    final right = mathMax(start.dx, curr.dx);
    final bottom = mathMax(start.dy, curr.dy);
    setState(() {
      _previewRect =
          Rect.fromLTWH(left, top, right - left, bottom - top);
    });
  }

  Rect svgToScreenRect(Map<String, dynamic> booth, double renderWidth) {
    final scale = renderWidth / svgViewW;
    final left = (booth['x'] as num).toDouble() * scale;
    final top = (booth['y'] as num).toDouble() * scale;
    final w = (booth['width'] as num).toDouble() * scale;
    final h = (booth['height'] as num).toDouble() * scale;
    return Rect.fromLTWH(left, top, w, h);
  }

  @override
  Widget build(BuildContext context) {
    return RootScaffold(
      title: 'Admin — Floorplan Mapping',
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            const Text('Exhibition: '),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<int>(
                value: _selectedExhId,
                isExpanded: true,
                hint: const Text('Select exhibition'),
                items: _exhibitions.map((e) {
                  return DropdownMenuItem(
                      value: e['id'] as int,
                      child: Text(e['title'] ?? ''));
                }).toList(),
                onChanged: (v) async {
                  setState(() {
                    _selectedExhId = v;
                    _selectedSvgAsset = _exhibitions
                        .firstWhere((x) => x['id'] == v)['svg_asset']
                    as String?;
                    _booths = [];
                  });
                  if (v != null) await _loadBooths(v);
                },
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _selectedExhId == null
                  ? null
                  : () => _loadBooths(_selectedExhId!),
              child: const Text('Reload'),
            )
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: _selectedSvgAsset == null
                ? const Center(child: Text('No exhibition selected'))
                : LayoutBuilder(builder: (context, constraints) {
              final renderW = constraints.maxWidth;
              final scale = renderW / svgViewW;
              final renderH = svgViewH * scale;
              return Column(children: [
                Expanded(
                  child: SizedBox(
                    width: renderW,
                    height: renderH,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (d) =>
                          _onPanStart(d, constraints),
                      onPanUpdate: (d) =>
                          _onPanUpdate(d, constraints),
                      onPanEnd: (d) =>
                          _onPanEnd(constraints),
                      child: Stack(children: [
                        Positioned.fill(
                            child: SvgPicture.asset(
                                _selectedSvgAsset!,
                                fit: BoxFit.fill)),
                        ..._booths.map((b) {
                          final rect =
                          svgToScreenRect(b, renderW);
                          return Positioned(
                            left: rect.left,
                            top: rect.top,
                            width: rect.width,
                            height: rect.height,
                            child: GestureDetector(
                              onTap: () async {
                                final updated =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (_) =>
                                      BoothEditDialog(
                                          booth: b),
                                );
                                if (updated == true &&
                                    _selectedExhId !=
                                        null) {
                                  await _loadBooths(
                                      _selectedExhId!);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: b['status'] ==
                                      'available'
                                      ? Colors.green
                                      .withValues(
                                      alpha: 0.5)
                                      : Colors.red
                                      .withValues(
                                      alpha: 0.6),
                                  border: Border.all(
                                      color: Colors.black),
                                ),
                                child: Center(
                                    child: Text(
                                        b['booth_code'] ??
                                            '')),
                              ),
                            ),
                          );
                        }).toList(),
                        if (_previewRect != null)
                          Positioned(
                            left: _previewRect!.left,
                            top: _previewRect!.top,
                            width: _previewRect!.width,
                            height: _previewRect!.height,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue
                                    .withValues(
                                    alpha: 0.3),
                                border: Border.all(
                                    color: Colors.blue),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                    'Tip: drag on the map to draw a new booth rectangle. Tap an existing booth to edit/delete.'),
              ]);
            }),
          ),
        ]),
      ),
    );
  }
}

double mathMin(double a, double b) => (a < b ? a : b);
double mathMax(double a, double b) => (a > b ? a : b);
