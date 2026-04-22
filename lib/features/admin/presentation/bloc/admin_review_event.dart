abstract class AdminReviewEvent {
  const AdminReviewEvent();
}

class LoadAdminReviewsRequested extends AdminReviewEvent {
  const LoadAdminReviewsRequested({this.search, this.page, this.limit});
  final String? search;
  final int? page;
  final int? limit;
}

class UpdateAdminReviewVisibilityRequested extends AdminReviewEvent {
  const UpdateAdminReviewVisibilityRequested({
    required this.id,
    required this.isVisible,
  });
  final int id;
  final bool isVisible;
}

class ReplyAdminReviewRequested extends AdminReviewEvent {
  const ReplyAdminReviewRequested({required this.id, required this.adminReply});
  final int id;
  final String adminReply;
}
