part of 'response_parser_base.dart';

/// {@template response_parser_base}
/// Response Parser makes it easier to parse data and error response from server.
///
/// You can write this:
/// ```dart
/// Future<Either<User, ApiFailure>> fetchUser() async {
///   return parseApiResponse(
///     requestAction: () => dio.get('/user'),
///     mapper: User.fromJson,
///   );
/// }
/// ```
/// Instead of writing this boring code all the time
/// ```dart
/// Future<Either<User, ApiFailure>> fetchUser() async {
///   final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
///   try {
///     final request = await dio.get('/user');
///     final data = request.data?['data'];
///     if (data == null) {
///       final error = request.data?['error'];
///       if (error != null) {
///         return ApiFailure.serverFailure(error['message']);
///       } else {
///         return ApiFailure.unknown();
///       }
///     } else {
///       return User.fromJson(data);
///     }
///   } catch (error, st) {
///     ApiFailure? apiFailure;
///     if (error is DioError) {
///       final responseFailure = error.response?.data;
///       if (responseFailure is Map<String, dynamic>) {
///         apiFailure = ApiFailure.serverFailure(responseFailure['message']);
///       } else {
///         apiFailure = ApiFailure.httpError(error.response?.statusCode);
///       }
///     }
///     return apiFailure ?? ApiFailure.unknown();
///   }
/// }
/// ```
/// To do so you need to do a little preparation. For example lets assume your server returns such response:
/// ```json
/// {
///   "data": {
///     // Data you requested
///   },
///   "error": {
///     // Server error which you should parse and show to user
///     "message": "Something went wrong"
///   }
/// }
/// ```
/// And your error model looks this way:
/// ```dart
/// class ApiFailure {
///   factory ApiFailure.unknown() = _UnknownApiFailure;
///   factory ApiFailure.serverFailure(String errorMessage) = _ServerFailure;
///   factory ApiFailure.httpError(int? statusCode) = _HttpError;
/// }
/// ```
/// {@endtemplate}
/// Then you need to implement `dataExtractor`, `failureParser` and `errorCatcher` this way:
/// ```dart
/// final _exampleResponseParser = ResponseParser<Response, ApiFailure>(
///   dataExtractor: (response) => response.data['data']!,
///   failureParser: (response) {
///     final error = json['error'];
///     if (error is Map<String, dynamic>) {
///       return ApiFailure.serverFailure(error['message']);
///     } else {
///       return null;
///     }
///   },
///   errorCatcher: (error, stackTrace) {
///     ApiFailure? apiFailure;
///     if (error is DioError) {
///       apiFailure = ApiFailure.httpError(error.response?.statusCode);
///     }
///
///     return apiFailure ?? ApiFailure.unknown();
///   },
/// );
/// ```
/// {@template response_parser_usage}
/// And create top level [parseApiResponse], [parseListApiResponse] and [parseEmptyApiResponse] functions.
/// ```dart
/// final parseApiResponse = _exampleResponseParser.parseApiResponse;
/// final parseListApiResponse = _exampleResponseParser.parseListApiResponse;
/// final parseEmptyApiResponse = _exampleResponseParser.parseEmptyApiResponse;
/// ```
/// That's all!\
/// For more info you can take a look at the example.
/// {@endtemplate}
/// See also:
/// * [ResponseParserBase] - an extendable version of [ResponseParser].
class ResponseParser<Response, Failure>
    extends ResponseParserBase<Response, Failure> {
  /// {@macro response_parser}
  const ResponseParser({
    required DataExtractor<Response> dataExtractor,
    required FailureParser<Failure, Response> failureParser,
    required ErrorCatcher<Failure> errorCatcher,
  })  : _dataExtractor = dataExtractor,
        _failureParser = failureParser,
        _errorCatcher = errorCatcher;

  final DataExtractor<Response> _dataExtractor;
  final FailureParser<Failure, Response> _failureParser;
  final ErrorCatcher<Failure> _errorCatcher;

  @override
  Failure catchError(Object error, StackTrace stackTrace) {
    return _errorCatcher(error, stackTrace);
  }

  @override
  Object extractData(Response response) {
    return _dataExtractor(response);
  }

  @override
  Failure? parseFailure(Response response) {
    return _failureParser(response);
  }
}

/// {@template data_extractor}
/// Function which returns data (List or Map) from [Response].
///
/// It's called when [FailureParser] returns `null`.
/// {@endtemplate}
typedef DataExtractor<Response> = Object Function(Response response);

/// {@template failure_parser}
/// Function which parses [Failure] from [Response] if any.
/// {@endtemplate}
typedef FailureParser<Failure, Response> = Failure? Function(Response response);

/// {@template error_catcher}
/// Function which handles catched [error] and [stackTrace].
///
/// It's called when [DataExtractor] or [FailureParser] throws an error.
/// {@endtemplate}
typedef ErrorCatcher<Failure> = Failure Function(
  Object error,
  StackTrace stackTrace,
);
