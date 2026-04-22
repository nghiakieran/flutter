class AdminReview {
  const AdminReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.isVisible,
    this.adminReply,
    this.userName,
    this.productName,
  });

  final int id;
  final int rating;
  final String comment;
  final bool isVisible;
  final String? adminReply;
  final String? userName;
  final String? productName;

  factory AdminReview.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : <String, dynamic>{};
    final product = json['product'] is Map<String, dynamic>
        ? json['product'] as Map<String, dynamic>
        : <String, dynamic>{};
    return AdminReview(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      rating: int.tryParse(json['rating']?.toString() ?? '') ?? 0,
      comment: json['comment']?.toString() ?? '',
      isVisible: json['isVisible'] == true,
      adminReply: json['adminReply']?.toString(),
      userName: user['name']?.toString(),
      productName: product['name']?.toString(),
    );
  }
}

class AdminReviewPage {
  const AdminReviewPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<AdminReview> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
}
