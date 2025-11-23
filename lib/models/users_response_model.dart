import 'user_model.dart';

// Users Response Model - Represents users list API response
class UsersResponseModel {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<UserModel> users;

  UsersResponseModel({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.users,
  });

  // Factory constructor to create UsersResponseModel from JSON
  factory UsersResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] as List<dynamic>;
    final List<UserModel> usersList = data
        .map((userJson) => UserModel.fromJson(userJson as Map<String, dynamic>))
        .toList();

    return UsersResponseModel(
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      users: usersList,
    );
  }
}

