class Booth {
  final int id;
  final String boothCode;
  final int exhibitionId;
  final double price;
  final String size;
  final String status;
  final double x, y, width, height;

  Booth({
    required this.id,
    required this.boothCode,
    required this.exhibitionId,
    required this.price,
    required this.size,
    required this.status,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory Booth.fromMap(Map<String, dynamic> m) => Booth(
        id: m['id'] as int,
        boothCode: m['booth_code'] ?? '',
        exhibitionId: m['exhibition_id'] ?? 1,
        price: (m['price'] as num).toDouble(),
        size: m['size'] ?? '',
        status: m['status'] ?? 'available',
        x: (m['x'] as num).toDouble(),
        y: (m['y'] as num).toDouble(),
        width: (m['width'] as num).toDouble(),
        height: (m['height'] as num).toDouble(),
      );
}