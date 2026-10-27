/// Deployed booking site. Native builds have no browser origin (`file:///`),
/// and [Uri.origin] throws on that scheme. Stripe return links need http(s).
const defaultPublicWebOrigin = 'https://iturrieta-book.netlify.app';

const configuredPublicWebUrl = String.fromEnvironment('PUBLIC_WEB_URL');

/// Origin for links that leave this screen: Stripe success/cancel and the
/// copied manage link.
///
/// A web session uses the page origin. Android, iOS, and desktop use
/// `PUBLIC_WEB_URL` when it is set, then [defaultPublicWebOrigin].
String? publicWebOrigin({Uri? base, String? configured, String? fallback}) {
  final fromPage = _httpOrigin(base ?? Uri.base);
  if (fromPage != null) return fromPage;
  final fromConfig = _httpOrigin(
    Uri.tryParse(configured ?? configuredPublicWebUrl),
  );
  if (fromConfig != null) return fromConfig;
  return _httpOrigin(Uri.tryParse(fallback ?? defaultPublicWebOrigin));
}

String? _httpOrigin(Uri? uri) {
  if (uri == null) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  if (uri.host.isEmpty) return null;
  return uri.origin;
}
