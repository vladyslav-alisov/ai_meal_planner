Future<void> runSafely(Future<void> Function() action) async {
  try {
    await action();
  } catch (_) {
    // Analytics must never affect the app flow.
  }
}
