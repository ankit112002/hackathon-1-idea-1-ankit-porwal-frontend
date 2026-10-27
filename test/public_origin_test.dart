import 'package:flutter_test/flutter_test.dart';
import 'package:iturrieta_book/core/public_origin.dart';

void main() {
  test('uses the page origin on the web', () {
    expect(
      publicWebOrigin(
        base: Uri.parse('https://book.example/book/confirm?token=abc'),
        configured: '',
        fallback: '',
      ),
      'https://book.example',
    );
  });

  test('does not read origin from a file uri', () {
    expect(
      publicWebOrigin(
        base: Uri.parse('file:///'),
        configured: 'https://pay.example/app',
        fallback: defaultPublicWebOrigin,
      ),
      'https://pay.example',
    );
  });

  test('falls back to the deployed site on a phone', () {
    expect(
      publicWebOrigin(
        base: Uri.parse('file:///android_asset/flutter_assets/'),
        configured: '',
        fallback: defaultPublicWebOrigin,
      ),
      defaultPublicWebOrigin,
    );
  });
}
