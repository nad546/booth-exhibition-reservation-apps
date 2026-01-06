class Exhibition {
  final int id;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String svgAsset;

  Exhibition({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.svgAsset,
  });

  factory Exhibition.fromMap(Map<String, dynamic> m) => Exhibition(
        id: m['id'] as int,
        title: m['title'] ?? '',
        description: m['description'] ?? '',
        startDate: m['start_date'] ?? '',
        endDate: m['end_date'] ?? '',
        svgAsset: m['svg_asset'] ?? 'assets/svg/expo1.svg',
      );
}