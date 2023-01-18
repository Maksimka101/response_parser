import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:response_parser/response_parser.dart';
import 'custom_response.dart';
import 'mocks.dart';

void main() {
  late DataExtractor<TestResponse> dataExtractor;
  late ResponseParser<TestResponse, Failure> mockedResponseParser;
  late ResponseParser<TestResponse, Failure> responseParser;
  late FailureParser<Failure, TestResponse> failureParser;
  late ErrorCatcher<Failure> errorCatcher;

  setUp(() {
    dataExtractor = MockDataExtractor<TestResponse>();
    failureParser = MockFailureParser<Failure, TestResponse>();
    errorCatcher = MockErrorCatcher<Failure>();

    mockedResponseParser = ResponseParser<TestResponse, Failure>(
      dataExtractor: dataExtractor,
      failureParser: failureParser,
      errorCatcher: errorCatcher,
    );
    responseParser = ResponseParser<TestResponse, Failure>(
      dataExtractor: (response) => response.data['data'],
      failureParser: (response) =>
          response.data['error'] != null ? Failure() : null,
      errorCatcher: (error, stackTrace) => Failure(),
    );

    registerFallbackValue(FakeTestResponse());
    registerFallbackValue(FakeStackTrace());
    when(() => dataExtractor(any())).thenReturn(testSuccessResponseData);
    when(() => failureParser(any())).thenReturn(null);
    when(() => errorCatcher(any(), any())).thenReturn(Failure());
  });

  group("Test that 'errorCatcher'", () {
    Future<Either<Failure, TestResponseData>> parseApiResponse() async {
      return mockedResponseParser.parseApiResponse(
        requestAction: () async => testSuccessResponse,
        mapper: TestResponseData.fromJson,
      );
    }

    test("catches error in the 'dataExtractor'", () async {
      when(() => dataExtractor(any())).thenThrow(Exception());
      await parseApiResponse();
      verify(() => errorCatcher(any(), any())).called(1);
    });

    test("catches error in the 'failureParser'", () async {
      when(() => failureParser(any())).thenThrow(Exception());
      await parseApiResponse();
      verify(() => errorCatcher(any(), any())).called(1);
    });

    test("catches error in the 'requestAction'", () async {
      await mockedResponseParser.parseApiResponse(
        requestAction: () async {
          throw Exception();
        },
        mapper: TestResponseData.fromJson,
      );
      verify(() => errorCatcher(any(), any())).called(1);
    });

    test("catches error in the 'mapper'", () async {
      await mockedResponseParser.parseApiResponse(
        requestAction: () async => testSuccessResponse,
        mapper: (_) {
          throw Exception();
        },
      );
      verify(() => errorCatcher(any(), any())).called(1);
    });

    test("catches error in the 'parseListApiResponse'", () async {
      when(() => dataExtractor(any())).thenThrow(Exception());
      await mockedResponseParser.parseListApiResponse(
        requestAction: () async => testSuccessResponse,
        mapper: TestResponseData.fromJson,
      );
      verify(() => errorCatcher(any(), any())).called(1);
    });

    test("catches error in the 'parseEmptyApiResponse'", () async {
      when(() => failureParser(any())).thenThrow(Exception());
      await mockedResponseParser.parseEmptyApiResponse(
        requestAction: () async => testSuccessResponse,
      );
      verify(() => errorCatcher(any(), any())).called(1);
    });
  });

  group('Test data parsing in the', () {
    test("'parseApiResponse' method", () async {
      final result = await responseParser.parseApiResponse(
        requestAction: () async => testSuccessResponse,
        mapper: TestResponseData.fromJson,
      );
      expect(result.getRight().toNullable(), testSuccessResponseData);
    });

    test("'parseListApiResponse' method", () async {
      final result = await responseParser.parseListApiResponse(
        requestAction: () async => testListSuccessResponse,
        mapper: TestResponseData.fromJson,
      );
      expect(result.getRight().toNullable(), testListSuccessResponseData);
    });
  });

  group('Test failure parser in the', () {
    test("'parseApiResponse' method", () async {
      final result = await responseParser.parseApiResponse(
        requestAction: () async => testFailureResponse,
        mapper: TestResponseData.fromJson,
      );
      expect(result.getLeft().toNullable(), isA<Failure>());
    });

    test("'parseListApiResponse' method", () async {
      final result = await responseParser.parseListApiResponse(
        requestAction: () async => testFailureResponse,
        mapper: TestResponseData.fromJson,
      );
      expect(result.getLeft().toNullable(), isA<Failure>());
    });

    test("'parseEmptyApiResponse' method", () async {
      final result = await responseParser.parseEmptyApiResponse(
        requestAction: () async => testFailureResponse,
      );
      expect(result.toNullable(), isA<Failure>());
    });
  });
}
