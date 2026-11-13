class Session {
  static Map<String, Object?>? user;

  static bool get isLoggedIn => user != null;

  static void clear() => user = null;
}