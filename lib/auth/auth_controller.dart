import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Demo authentication state. The "token" lives in secure storage (Keychain /
/// Android Keystore / DPAPI), so the user stays signed in across restarts.
///
/// Used as `GoRouter.refreshListenable`: every [notifyListeners] re-runs redirects.
class AuthController extends ChangeNotifier {
  AuthController({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userNameKey = 'auth_user_name';

  final FlutterSecureStorage _storage;
  String? _userName;

  String? get userName => _userName;
  bool get isLoggedIn => _userName != null;

  /// Call once before `runApp` so the first route already knows the auth state.
  Future<void> restore() async {
    final token = await _storage.read(key: _tokenKey);
    _userName = token == null ? null : await _storage.read(key: _userNameKey);
    notifyListeners();
  }

  Future<void> login(String userName) async {
    // A real app gets the token from the backend.
    await _storage.write(key: _tokenKey, value: 'demo-${DateTime.now().millisecondsSinceEpoch}');
    await _storage.write(key: _userNameKey, value: userName);
    _userName = userName;
    notifyListeners();
  }

  Future<void> updateUserName(String userName) async {
    await _storage.write(key: _userNameKey, value: userName);
    _userName = userName;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userNameKey);
    _userName = null;
    notifyListeners();
  }
}
