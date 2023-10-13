import 'package:xml/xml.dart';

import 'classes.dart';

class Settings {
  Settings(
    this.client,
    this.times,
    this.download,
    this.upload,
    this.serverConfig,
    this.servers,
  );

  Settings.fromXMLElement(final XmlElement? element)
      : client = Client.fromXMLElement(element?.getElement('client')),
        times = Times.fromXMLElement(element?.getElement('times')),
        download = Download.fromXMLElement(element?.getElement('download')),
        upload = Upload.fromXMLElement(element?.getElement('upload')),
        serverConfig =
            ServerConfig.fromXMLElement(element?.getElement('server-config')),
        servers = <Server>[];
  Client client;

  Times times;

  Download download;

  Upload upload;

  ServerConfig serverConfig;

  List<Server> servers;
}
