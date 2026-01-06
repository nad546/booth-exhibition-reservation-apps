class ApplicationModel {
  final int id;
  final int exhibitorId;
  final int exhibitionId;
  final int boothId;
  final String companyName;
  final String companyDescription;
  final String exhibitProfile;
  final String eventStart;
  final String eventEnd;
  final String status;

  ApplicationModel({
    required this.id,
    required this.exhibitorId,
    required this.exhibitionId,
    required this.boothId,
    required this.companyName,
    required this.companyDescription,
    required this.exhibitProfile,
    required this.eventStart,
    required this.eventEnd,
    required this.status,
  });

  factory ApplicationModel.fromMap(Map<String, dynamic> m) => ApplicationModel(
        id: m['id'] as int,
        exhibitorId: m['exhibitor_id'] ?? 0,
        exhibitionId: m['exhibition_id'] ?? 0,
        boothId: m['booth_id'] ?? 0,
        companyName: m['company_name'] ?? '',
        companyDescription: m['company_description'] ?? '',
        exhibitProfile: m['exhibit_profile'] ?? '',
        eventStart: m['event_startdate'] ?? '',
        eventEnd: m['event_enddate'] ?? '',
        status: m['status'] ?? 'pending',
      );
}