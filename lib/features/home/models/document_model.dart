class DocumentModel {
  final String id;
  final String userId;
  final String title;
  final String? rootNodeId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DocumentModel({
    required this.id,
    required this.userId,
    required this.title,
    this.rootNodeId,
    required this.createdAt,
    this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      rootNodeId: json['root_node_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }
}
