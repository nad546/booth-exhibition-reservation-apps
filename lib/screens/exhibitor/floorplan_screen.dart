import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/booth_provider.dart';
import '../../providers/exhibition_provider.dart';
import '../../models/booth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/root_scaffold.dart';

class FloorplanScreen extends ConsumerStatefulWidget {
  final int exhibitionId;
  const FloorplanScreen({super.key, required this.exhibitionId});

  @override
  ConsumerState<FloorplanScreen> createState() =>
      _FloorplanScreenState();
}

class _FloorplanScreenState extends ConsumerState<FloorplanScreen> {
  final Set<int> _selectedBoothIds = {};

  @override
  Widget build(BuildContext context) {
    final exhAsync =
    ref.watch(exhibitionByIdProvider(widget.exhibitionId));
    final boothsAsync =
    ref.watch(boothsByExhibitionProvider(widget.exhibitionId));

    return exhAsync.when(
      data: (exh) {
        if (exh == null) {
          return const RootScaffold(
            title: 'Floorplan',
            child: Center(child: Text('Exhibition not found')),
          );
        }

        return RootScaffold(
          title: 'Floorplan - ${exh.title}',
          floatingActionButton: _selectedBoothIds.isNotEmpty
              ? FloatingActionButton.extended(
            onPressed: () => _navigateToApply(context),
            label:
            Text('Apply (${_selectedBoothIds.length})'),
            icon: const Icon(Icons.check),
          )
              : null,
          child: boothsAsync.when(
            data: (booths) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  const svgW = 1000.0;
                  const svgH = 800.0;
                  final scale = constraints.maxWidth / svgW;
                  final displayHeight = svgH * scale;

                  return SingleChildScrollView(
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: displayHeight,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: SvgPicture.asset(
                              exh.svgAsset,
                              fit: BoxFit.fill,
                            ),
                          ),
                          ...booths
                              .map((b) =>
                              _buildBoothWidget(b, scale))
                              .toList(),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () =>
            const Center(child: CircularProgressIndicator()),
            error: (e, s) =>
                Center(child: Text('Error: $e')),
          ),
        );
      },
      loading: () => const RootScaffold(
        title: 'Loading',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => RootScaffold(
        title: 'Error',
        child: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBoothWidget(Booth b, double scale) {
    final left = b.x * scale;
    final top = b.y * scale;
    final w = b.width * scale;
    final h = b.height * scale;

    final available = b.status == 'available';
    final selected = _selectedBoothIds.contains(b.id);

    final color = selected
        ? Colors.blue.withValues(alpha: 0.7)
        : (available
        ? Colors.green.withValues(alpha: 0.5)
        : Colors.red.withValues(alpha: 0.6));

    return Positioned(
      left: left,
      top: top,
      width: w,
      height: h,
      child: GestureDetector(
        onTap: available
            ? () {
          setState(() {
            if (selected) {
              _selectedBoothIds.remove(b.id);
            } else {
              _selectedBoothIds.add(b.id);
            }
          });
        }
            : null,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  b.boothCode,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '\$${b.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToApply(BuildContext context) {
    if (_selectedBoothIds.isEmpty) return;

    final boothCsv = _selectedBoothIds.join(',');

    context.goNamed(
      'apply',
      pathParameters: {
        'exhId': widget.exhibitionId.toString(),
      },
      queryParameters: {'booths': boothCsv},
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
