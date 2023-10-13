import 'package:xml/xml.dart';

class Upload {
  Upload(
    this.testLength,
    this.ratio,
    this.initialTest,
    this.minTestSize,
    this.threads,
    this.maxChunkSize,
    this.maxChunkCount,
    this.threadsPerUrl,
  );

  Upload.fromXMLElement(final XmlElement? element)
      : testLength = int.parse(element!.getAttribute('testlength')!),
        ratio = int.parse(element.getAttribute('ratio')!),
        initialTest = int.parse(element.getAttribute('initialtest')!),
        minTestSize = element.getAttribute('mintestsize')!,
        threads = int.parse(element.getAttribute('threads')!),
        maxChunkSize = element.getAttribute('maxchunksize')!,
        maxChunkCount = element.getAttribute('maxchunkcount')!,
        threadsPerUrl = int.parse(element.getAttribute('threadsperurl')!);

  int testLength;
  int ratio;
  int initialTest;
  String minTestSize;
  int threads;
  String maxChunkSize;
  String maxChunkCount;
  int threadsPerUrl;
}

class Download {
  Download(
    this.testLength,
    this.initialTest,
    this.minTestSize,
    this.threadsPerUrl,
  );

  Download.fromXMLElement(final XmlElement? element)
      : testLength = int.parse(element!.getAttribute('testlength')!),
        initialTest = element.getAttribute('initialtest')!,
        minTestSize = element.getAttribute('mintestsize')!,
        threadsPerUrl = int.parse(element.getAttribute('threadsperurl')!);

  int testLength;
  String initialTest;
  String minTestSize;
  int threadsPerUrl;
}
