import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/exhibition_provider.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/root_scaffold.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExhibitionDetailScreen extends ConsumerWidget {
  final int exhibitionId;

  const ExhibitionDetailScreen({
    super.key,
    required this.exhibitionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exhAsync = ref.watch(exhibitionByIdProvider(exhibitionId));
    final auth = ref.watch(authProvider);

    return exhAsync.when(
      data: (e) {
        if (e == null) {
          return const RootScaffold(
            title: 'Exhibition',
            child: Center(child: Text('Exhibition not found')),
          );
        }

        return RootScaffold(
          title: e.title,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    e.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(e.description),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Text('Dates: ${e.startDate} → ${e.endDate}'),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: SvgPicture.asset(
                              e.svgAsset,
                              width: 340,
                              height: 240,
                              fit: BoxFit.contain,
                              placeholderBuilder: (_) =>
                              const Icon(Icons.map, size: 120),
                            ),
                          ),
                        ),

                        const Divider(height: 1),

                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: OverflowBar(
                            spacing: 12,
                            overflowAlignment: OverflowBarAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  context.goNamed(
                                    'floorplan',
                                    pathParameters: {
                                      'exhId': e.id.toString(),
                                    },
                                  );
                                },
                                child: const Text('View Floorplan'),
                              ),

                              // Require login before applying
                              ElevatedButton(
                                onPressed: () {
                                  if (auth.username == null) {
                                    context.goNamed('login');
                                  } else {
                                    context.goNamed(
                                      'floorplan',
                                      pathParameters: {
                                        'exhId': e.id.toString(),
                                      },
                                    );
                                  }
                                },
                                child: const Text('Apply Now'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },

      loading: () => const RootScaffold(
        title: 'Loading',
        child: Center(child: CircularProgressIndicator()),
      ),

      error: (err, _) => RootScaffold(
        title: 'Error',
        child: Center(child: Text('Error: $err')),
      ),
    );
  }
}
