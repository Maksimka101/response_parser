class TestResponse {
  const TestResponse({
    required this.data,
  });

  final Map<String, dynamic> data;
}

final testSuccessResponse = TestResponse(data: {
  'data': {
    'id': 1,
    'name': 'Test',
  },
});

final testListSuccessResponse = TestResponse(data: {
  'data': [
    {
      'id': 1,
      'name': 'Test',
    },
    {
      'id': 2,
      'name': 'Test 2',
    }
  ],
});

final testFailureResponse = TestResponse(data: {
  'error': 'Test error',
});

class TestResponseData {
  const TestResponseData({
    required this.id,
    required this.name,
  });

  factory TestResponseData.fromJson(Map<String, dynamic> json) {
    return TestResponseData(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  final int id;
  final String name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestResponseData && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}

final testSuccessResponseData = TestResponseData(id: 1, name: 'Test');
final testListSuccessResponseData = [
  TestResponseData(id: 1, name: 'Test'),
  TestResponseData(id: 2, name: 'Test 2')
];

class Failure {}
