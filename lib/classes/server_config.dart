import 'package:xml/xml.dart';

class ServerConfig {
  ServerConfig(
    this.ignoreIds,
  );

  /// Factory constructor for creating a new ServerConfig from a [XmlElement].
  ServerConfig.fromXMLElement(final XmlElement? element)
      : ignoreIds = element!.getAttribute('ignoreids')!;

  String ignoreIds;
}
