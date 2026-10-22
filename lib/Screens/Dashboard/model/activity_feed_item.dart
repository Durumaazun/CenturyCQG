class ActivityFeedItem {
  const ActivityFeedItem({
    required this.id,
    required this.system,
    required this.type,
    required this.statusText,
    required this.title,
  });

  final String id;
  final String system;
  final String type;
  final String statusText;
  final String title;

  factory ActivityFeedItem.fromJson(Map<String, dynamic> json) {
    return ActivityFeedItem(
      id: json['id']?.toString() ?? '',
      system: json['system']?.toString() ?? '',
      type: json['type']?.toString().toLowerCase() ?? '',
      statusText:
          json['statusText']?.toString() ?? json['status']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }
}
