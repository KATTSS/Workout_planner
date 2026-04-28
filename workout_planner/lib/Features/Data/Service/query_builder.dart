class QueryBuilder {
  String? _table;
  final List<String> _selectColumns = [];
  final List<String> _whereConditions = [];
  final List<dynamic> _whereArgs = [];
  final List<String> _orderByColumns = [];
  int? _limit;
  int? _offset;

  Map<String, dynamic>? _values;
  QueryType _type = QueryType.select;

  QueryBuilder select([List<String>? columns]) {
    _type = QueryType.select;
    if (columns != null) _selectColumns.addAll(columns);
    return this;
  }

  QueryBuilder insert(Map<String, dynamic> values) {
    _type = QueryType.insert;
    _values = values;
    return this;
  }

  QueryBuilder update(Map<String, dynamic> values) {
    _type = QueryType.update;
    _values = values;
    return this;
  }

  QueryBuilder delete() {
    _type = QueryType.delete;
    return this;
  }

  QueryBuilder from(String tableName) {
    _table = tableName;
    return this;
  }

  QueryBuilder where(String column, String operator, dynamic value) {
    _whereConditions.add("$column $operator ?");
    _whereArgs.add(value);
    return this;
  }

  QueryBuilder whereRaw(String condition, [List<dynamic>? args]) {
    _whereConditions.add(condition);
    if (args != null) _whereArgs.addAll(args);
    return this;
  }

  QueryBuilder orderBy(String column, {bool descending = false}) {
    _orderByColumns.add("$column ${descending ? 'DESC' : 'ASC'}");
    return this;
  }

  QueryBuilder limit(int limit) {
    _limit = limit;
    return this;
  }

  QueryBuilder offset(int offset) {
    _offset = offset;
    return this;
  }

  String build() {
    if (_table == null) {
      throw StateError("Table name is required");
    }

    switch (_type) {
      case QueryType.select:
        return _buildSelect();
      case QueryType.insert:
        return _buildInsert();
      case QueryType.update:
        return _buildUpdate();
      case QueryType.delete:
        return _buildDelete();
    }
  }

  List<dynamic> get args => List.unmodifiable(_whereArgs);
  Map<String, dynamic>? get values => _values;
  QueryType get type => _type;

  String _buildSelect() {
    final buffer = StringBuffer();
    final columns = _selectColumns.isEmpty ? "*" : _selectColumns.join(", ");
    buffer.write("SELECT $columns FROM $_table");
    _appendWhere(buffer);
    _appendOrderBy(buffer);
    _appendLimitOffset(buffer);
    buffer.write(";");
    return buffer.toString();
  }

  String _buildInsert() {
    if (_values == null || _values!.isEmpty) {
      throw StateError("Values required for INSERT operation");
    }
    final columns = _values!.keys.join(", ");
    final placeholders = _values!.keys.map((_) => "?").join(", ");
    return "INSERT INTO $_table ($columns) VALUES ($placeholders)";
  }

  String _buildUpdate() {
    if (_values == null || _values!.isEmpty) {
      throw StateError("Values required for UPDATE operation");
    }
    final buffer = StringBuffer();
    buffer.write("UPDATE $_table SET ");
    buffer.write(_values!.keys.map((k) => "$k = ?").join(", "));
    _appendWhere(buffer);
    buffer.write(";");
    return buffer.toString();
  }

  String _buildDelete() {
    final buffer = StringBuffer();
    buffer.write("DELETE FROM $_table");
    _appendWhere(buffer);
    buffer.write(";");
    return buffer.toString();
  }

  void _appendWhere(StringBuffer buffer) {
    if (_whereConditions.isNotEmpty) {
      buffer.write(" WHERE ${_whereConditions.join(" AND ")}");
    }
  }

  void _appendOrderBy(StringBuffer buffer) {
    if (_orderByColumns.isNotEmpty) {
      buffer.write(" ORDER BY ${_orderByColumns.join(", ")}");
    }
  }

  void _appendLimitOffset(StringBuffer buffer) {
    if (_limit != null) buffer.write(" LIMIT $_limit");
    if (_offset != null) buffer.write(" OFFSET $_offset");
  }

  void reset() {
    _table = null;
    _selectColumns.clear();
    _whereConditions.clear();
    _whereArgs.clear();
    _orderByColumns.clear();
    _limit = null;
    _offset = null;
    _values = null;
    _type = QueryType.select;
  }
}

enum QueryType { select, insert, update, delete }
