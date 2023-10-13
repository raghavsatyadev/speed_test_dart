import 'package:xml/xml.dart';

class Times {
  Times(
    this.download1,
    this.download2,
    this.download3,
    this.upload1,
    this.upload2,
    this.upload3,
  );

  Times.fromXMLElement(final XmlElement? element)
      : download1 = int.parse(element!.getAttribute('dl1')!),
        download2 = int.parse(element.getAttribute('dl2')!),
        download3 = int.parse(element.getAttribute('dl3')!),
        upload1 = int.parse(element.getAttribute('ul1')!),
        upload2 = int.parse(element.getAttribute('ul2')!),
        upload3 = int.parse(element.getAttribute('ul3')!);

  int download1;
  int download2;
  int download3;

  int upload1;
  int upload2;
  int upload3;
}
