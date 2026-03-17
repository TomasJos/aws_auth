import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../data/services/auth_service.dart';
import '../../core/utils/error_handler.dart';

enum AuthStatus { initial, unauthenticated, authenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  String? _currentUserEmail;
  String? _currentUserName;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;

  AuthProvider() {
    checkAuthStatus();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(Exception e) {
    _status = AuthStatus.unauthenticated;
    _errorMessage = ErrorHandler.handleAuthException(e);
    notifyListeners();
  }

  Future<bool> _hasInternet() async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      _setError(Exception('No internet connection'));
      return false;
    }
    return true;
  }

  Future<void> checkAuthStatus() async {
    _setLoading();
    if (!await _hasInternet()) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    final userData = await _authService.getCurrentUserAndAttributes();
    if (userData != null) {
      _status = AuthStatus.authenticated;
      _currentUserEmail = userData['user'].username;
      _currentUserName = userData['name'];
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading();
    if (!await _hasInternet()) return false;
    
    try {
      final success = await _authService.signIn(email, password);
      if (success) {
        final userData = await _authService.getCurrentUserAndAttributes();
        
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        if (userData != null) {
          _currentUserEmail = userData['user'].username;
          _currentUserName = userData['name'];
        } else {
          _currentUserEmail = email;
        }
        
        notifyListeners();
        return true;
      }
    } on Exception catch (e) {
      _setError(e);
    }
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading();
    if (!await _hasInternet()) return false;
    
    try {
      final success = await _authService.signUp(email, password, name);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return success;
    } on Exception catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> confirmSignUp(String email, String code) async {
    _setLoading();
    if (!await _hasInternet()) return false;

    try {
      final success = await _authService.confirmSignUp(email, code);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return success;
    } on Exception catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading();
    if (!await _hasInternet()) return false;

    try {
      await _authService.resetPassword(email);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> confirmResetPassword(
      String email, String newPassword, String code) async {
    _setLoading();
    if (!await _hasInternet()) return false;

    try {
      await _authService.confirmResetPassword(email, newPassword, code);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading();
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint('Error signing out: \$e');
    }
    _status = AuthStatus.unauthenticated;
    _currentUserEmail = null;
    notifyListeners();
  }
}
