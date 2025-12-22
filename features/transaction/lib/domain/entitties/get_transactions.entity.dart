class QueryGetTransactions {
  final String? search;
  final DateTime? date;
  final int? limit;
  final int? offset;

  const QueryGetTransactions({this.search, this.date, this.limit, this.offset});
}
