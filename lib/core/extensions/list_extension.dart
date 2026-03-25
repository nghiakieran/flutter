extension IterableExtensions<T> on Iterable<T> {
  /// Returns the first element that matches [test], or `null` if none.
  T? firstOrNullWhere(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
