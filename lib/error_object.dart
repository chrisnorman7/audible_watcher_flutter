/// A class for holding error information.
class ErrorObject {
  /// Create an instance.
  const ErrorObject(this.e, this.s);

  /// The error to show.
  final Object e;

  /// The stack trace to show.
  final StackTrace? s;
}
