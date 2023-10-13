import 'package:xml/xml.dart';

import 'classes.dart';

class Server {
  Server(
    this.id,
    this.name,
    this.country,
    this.sponsor,
    this.host,
    this.url,
    this.latitude,
    this.longitude,
    this.distance,
    this.latency,
    this.geoCoordinate,
  );

  Server.fromXMLElement(final XmlElement? element)
      : id = int.parse(element!.getAttribute('id')!),
        name = element.getAttribute('name')!,
        country = element.getAttribute('country')!,
        sponsor = element.getAttribute('sponsor')!,
        host = element.getAttribute('host')!,
        url = element.getAttribute('url')!,
        latitude = double.parse(element.getAttribute('lat')!),
        longitude = double.parse(element.getAttribute('lon')!),
        distance = 99999999999,
        latency = 99999999999,
        geoCoordinate = Coordinate(
          double.parse(element.getAttribute('lat')!),
          double.parse(element.getAttribute('lon')!),
        );

  int id;
  String name;
  String country;
  String sponsor;
  String host;
  String url;
  double latitude;
  double longitude;
  double distance;
  double latency;
  Coordinate geoCoordinate;
}

class ServersList {
  ServersList(
    this.servers,
  );

  ServersList.fromXMLElement(final XmlElement? element)
      : servers = element!
            .getElement('servers')!
            .children
            .whereType<XmlElement>()
            .map((final element) {
          final server = Server.fromXMLElement(element);
          return server;
        });

  Iterable<Server> servers;

  void calculateDistances(final Coordinate clientCoordinate) {
    for (final s in servers) {
      s.distance = clientCoordinate.getDistanceTo(s.geoCoordinate);
    }
  }
}
