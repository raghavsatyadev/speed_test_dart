import 'package:xml/xml.dart';

import 'classes.dart';

class Client {
  Client(
    this.ip,
    this.latitude,
    this.longitude,
    this.isp,
    this.ispRating,
    this.rating,
    this.ispAvarageDownloadSpeed,
    this.ispAvarageUploadSpeed,
    this.geoCoordinate,
  );

  Client.fromXMLElement(final XmlElement? element)
      : ip = element!.getAttribute('ip')!,
        latitude = double.parse(element.getAttribute('lat')!),
        longitude = double.parse(element.getAttribute('lon')!),
        isp = element.getAttribute('isp')!,
        ispRating = double.parse(element.getAttribute('isprating')!),
        rating = double.parse(element.getAttribute('rating')!),
        ispAvarageDownloadSpeed = int.parse(element.getAttribute('ispdlavg')!),
        ispAvarageUploadSpeed = int.parse(element.getAttribute('ispulavg')!),
        geoCoordinate = Coordinate(
          double.parse(element.getAttribute('lat')!),
          double.parse(element.getAttribute('lon')!),
        );

  String ip;
  double latitude;
  double longitude;
  String isp;
  double ispRating;
  double rating;
  int ispAvarageDownloadSpeed;
  int ispAvarageUploadSpeed;
  Coordinate geoCoordinate;
}
