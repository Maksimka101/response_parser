import 'package:fpdart/fpdart.dart';

part 'response_parser_helpers.dart';
part 'response_parser.dart';

/// {@macro response_parser_base}
/// Then you need to implement the [extractData], [parseFailure] and [catchError] this way:
/// ```dart
/// class DefaultResponseParser extends ResponseParser<Response, ApiFailure>{
///   Object extractData(Response response) => response.data['data']!;
///
///   Failure? parseFailure(Response response) {
///     final error = json['error'];
///     if (error is Map<String, dynamic>) {
///       return ApiFailure.serverFailure(error['message']);
///     } else {
///       return null;
///     }
///   };
///
///   Failure catchError(Object error, StackTrace stackTrace) {
///     ApiFailure? apiFailure;
///     if (error is DioError) {
///       apiFailure = ApiFailure.httpError(error.response?.statusCode);
///     }
///
///     return apiFailure ?? ApiFailure.unknown();
///   };
/// }
/// ```
/// {@macro response_parser_usage}
/// See also:
/// * [ResponseParser] - a shorter version of [ResponseParserBase].
abstract class ResponseParserBase<Response, Failure> {
  const ResponseParserBase();

  /// {@macro data_extractor}
  Object extractData(Response response);

  /// {@macro failure_parser}
  Failure? parseFailure(Response response);

  /// {@macro error_catcher}
  Failure catchError(Object error, StackTrace stackTrace);

  /// This method parses [Failure] or [Data] from [Response].
  ///
  /// {@template parse_response_parameters_description}
  /// It gains [requestAction] which will be immediately executed and [mapper] to parse [Data] from json.
  /// {@endtemplate}
  Future<Either<Failure, Data>> parseApiResponse<Data>({
    required RequestAction<Response> requestAction,
    required JsonMapper<Data> mapper,
  }) async {
    try {
      final response = await requestAction();

      return _parseResponse(
        response,
        dataParser: (data) => _dataParser(data, mapper),
        dataExtractor: extractData,
        failureParser: parseFailure,
      );
    } catch (e, st) {
      return left(catchError(e, st));
    }
  }

  /// This method parses [Failure] or List of [Data] from [Response].
  ///
  /// {@macro parse_response_parameters_description}
  Future<Either<Failure, List<Data>>> parseListApiResponse<Data>({
    required RequestAction<Response> requestAction,
    required JsonMapper<Data> mapper,
  }) async {
    try {
      final response = await requestAction();

      return _parseResponse(
        response,
        dataParser: (data) => _listDataParser(data, mapper),
        dataExtractor: extractData,
        failureParser: parseFailure,
      );
    } catch (e, st) {
      return left(catchError(e, st));
    }
  }

  /// This method parses [Failure] from response if any.
  ///
  /// It gains [requestAction] which will be immediately executed.
  Future<Option<Failure>> parseEmptyApiResponse({
    required RequestAction<Response> requestAction,
  }) async {
    try {
      final response = await requestAction();

      final responseFailure = parseFailure(response);
      return optionOf(responseFailure);
    } catch (e, st) {
      return some(catchError(e, st));
    }
  }
}

/// Typedef for [json] to [Data] parser.
typedef JsonMapper<Data> = Data Function(Map<String, dynamic> json);

/// Typedef for api request which returns [Response].
typedef RequestAction<Response> = Future<Response> Function();
