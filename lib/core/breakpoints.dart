/// Layout widths: mobile under 600, tablet under 1024, otherwise desktop.
class Breakpoints {
  const Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;
  static const double contentMaxWidth = 1100;

  static bool isMobile(double width) => width < mobile;

  static bool isTablet(double width) => width >= mobile && width < tablet;

  static bool isDesktop(double width) => width >= tablet;
}
