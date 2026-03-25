abstract class ITokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> clearTokens();
}
