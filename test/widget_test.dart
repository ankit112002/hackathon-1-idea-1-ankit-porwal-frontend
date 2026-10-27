import 'package:flutter_test/flutter_test.dart';
import 'package:iturrieta_book/core/breakpoints.dart';

void main() {
  test('breakpoints split mobile, tablet, and desktop', () {
    expect(Breakpoints.isMobile(360), isTrue);
    expect(Breakpoints.isMobile(600), isFalse);
    expect(Breakpoints.isTablet(768), isTrue);
    expect(Breakpoints.isTablet(1024), isFalse);
    expect(Breakpoints.isDesktop(1280), isTrue);
    expect(Breakpoints.contentMaxWidth, 1100);
  });
}
