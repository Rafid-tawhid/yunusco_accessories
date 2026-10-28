import 'package:flutter_test/flutter_test.dart';
import 'package:yunusco_accessories/core/network/api_client.dart';

void main() {
  final client = ApiClient.instance;

  tearDown(() => client.setAccessToken(null));

  test('sends the access token as a bearer authorization header', () {
    client.setAccessToken('test-access-token');

    expect(client.authorizationHeader, 'Bearer test-access-token');
    expect(client.authHeaders, {'Authorization': 'Bearer test-access-token'});
  });

  test('does not send an empty access token', () {
    client.setAccessToken('  ');

    expect(client.authorizationHeader, isNull);
    expect(client.authHeaders, isEmpty);
  });
}
