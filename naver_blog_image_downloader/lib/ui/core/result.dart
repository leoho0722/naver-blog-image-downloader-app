/// 操作結果的泛型封裝，用於統一表達成功與失敗兩種狀態。
///
/// 採用 sealed class 模式，確保所有使用端透過 switch 窮舉
/// [Ok] 與 [Error] 兩種子類型，避免遺漏錯誤處理。
sealed class Result<T> {
  const Result();

  /// 建立成功結果，攜帶 [value]。
  factory Result.ok(T value) = Ok<T>;

  /// 建立失敗結果，攜帶 [error]。
  factory Result.error(Exception error) = Error<T>;
}

/// 表示操作成功的結果，包含回傳值 [value]。
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  /// 操作成功時的回傳值。
  final T value;
}

/// 表示操作失敗的結果，包含例外 [error]。
final class Error<T> extends Result<T> {
  const Error(this.error);

  /// 操作失敗時的例外資訊。
  final Exception error;
}
