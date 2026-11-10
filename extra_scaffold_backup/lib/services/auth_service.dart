abstract class AuthService {
  Future<String?> getToken();
  bool get isAuthenticated;
  String? get parentId;
}

class MockAuthService implements AuthService {
  @override
  Future<String?> getToken() async => 'mock_jwt_token_for_development';

  @override
  bool get isAuthenticated => true;

  @override
  String? get parentId => 'parent_001';
}
