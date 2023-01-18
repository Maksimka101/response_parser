import 'package:mocktail/mocktail.dart';

import 'custom_response.dart';

class MockDataExtractor<Response> extends Mock {
  Object call(Response response);
}

class MockFailureParser<Failure, Response> extends Mock {
  Failure? call(Response response);
}

class MockErrorCatcher<Failure> extends Mock {
  Failure call(Object error, StackTrace stackTrace);
}

class FakeTestResponse extends Fake implements TestResponse {}

class FakeStackTrace extends Fake implements StackTrace {}
