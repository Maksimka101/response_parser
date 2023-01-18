part of 'response_parser_base.dart';

/// Internal
T _dataParser<T>(Object data, JsonMapper<T> mapper) {
  return mapper(data as Map<String, dynamic>);
}

/// Internal
List<T> _listDataParser<T>(Object data, JsonMapper<T> mapper) {
  return (data as List).map((e) => mapper(e as Map<String, dynamic>)).toList();
}

/// Internal
Either<Failure, Data> _parseResponse<Failure, Data, Response>(
  Response response, {
  required _DataParser<Data> dataParser,
  required FailureParser<Failure, Response> failureParser,
  required DataExtractor<Response> dataExtractor,
}) {
  final failure = failureParser(response);
  if (failure != null) {
    return left(failure);
  }

  final responseData = dataExtractor(response);
  assert(
    responseData is List && responseData.every((element) => element is Map) ||
        responseData is Map,
    "Response data is supposed to be a List of Maps or a Map",
  );
  return right(dataParser(responseData));
}

/// Internal
typedef _DataParser<T> = T Function(Object data);
