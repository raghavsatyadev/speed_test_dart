library speed_test_dart;

import 'dart:async';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:sync/sync.dart';
import 'package:xml/xml.dart';

import 'classes/classes.dart';
import 'constants.dart';
import 'enums/file_size.dart';

/// A Speed tester.
class SpeedTestDart {
  /// Returns [Settings] from speedtest.net.
  Future<Settings> getSettings() async {
    final response = await http.get(Uri.parse(configUrl));
    final settings = Settings.fromXMLElement(
      XmlDocument.parse(response.body).getElement('settings'),
    );

    var serversConfig = ServersList(<Server>[]);
    for (final element in serversUrls) {
      if (serversConfig.servers.isNotEmpty) {
        break;
      }
      try {
        final resp = await http.get(Uri.parse(element));

        serversConfig = ServersList.fromXMLElement(
          XmlDocument.parse(resp.body).getElement('settings'),
        );
      } on Exception {
        serversConfig = ServersList(<Server>[]);
      }
    }

    final ignoredIds = settings.serverConfig.ignoreIds.split(',');
    serversConfig.calculateDistances(settings.client.geoCoordinate);
    settings.servers = serversConfig.servers
        .where(
          (final s) => !ignoredIds.contains(s.id.toString()),
        )
        .toList();
    settings.servers
        .sort((final a, final b) => a.distance.compareTo(b.distance));

    return settings;
  }

  /// Returns a List[Server] with the best servers, ordered
  /// by lowest to highest latency.
  Future<List<Server>> getBestServers({
    required final List<Server> servers,
    final int retryCount = 2,
    final int timeoutInSeconds = 2,
  }) async {
    final List<Server> serversToTest = [];

    for (final server in servers) {
      final latencyUri = createTestUrl(server, 'latency.txt');
      final stopwatch = Stopwatch()..start();
      try {
        await http.get(latencyUri).timeout(
              Duration(
                seconds: timeoutInSeconds,
              ),
              onTimeout: () => http.Response(
                '999999999',
                500,
              ),
            );
        // If a server fails the request, continue in the iteration
      } on Exception {
        continue;
      } finally {
        stopwatch.stop();
      }

      final latency = stopwatch.elapsedMilliseconds / retryCount;
      if (latency < 500) {
        server.latency = latency;
        serversToTest.add(server);
      }
    }

    serversToTest.sort((final a, final b) => a.latency.compareTo(b.latency));

    return serversToTest;
  }

  /// Creates [Uri] from [Server] and [String] file
  Uri createTestUrl(final Server server, final String file) {
    return Uri.parse(
      Uri.parse(server.url).toString().replaceAll('upload.php', file),
    );
  }

  /// Returns urls for download test.
  List<String> generateDownloadUrls(
    final Server server,
    final int retryCount,
    final List<FileSize> downloadSizes,
  ) {
    final downloadUriBase = createTestUrl(server, 'random{0}x{0}.jpg?r={1}');
    final result = <String>[];
    for (final ds in downloadSizes) {
      for (var i = 0; i < retryCount; i++) {
        result.add(
          downloadUriBase
              .toString()
              .replaceAll('%7B0%7D', FILE_SIZE_MAPPING[ds].toString())
              .replaceAll('%7B1%7D', i.toString()),
        );
      }
    }
    return result;
  }

  /// Returns [double] downloaded speed in MB/s.
  Future<double> testDownloadSpeed({
    required final List<Server> servers,
    final int simultaneousDownloads = 2,
    final int retryCount = 3,
    final List<FileSize> downloadSizes = defaultDownloadSizes,
  }) async {
    double downloadSpeed = 0;

    // Iterates over all servers, if one request fails, the next one is tried.
    for (final s in servers) {
      final testData = generateDownloadUrls(s, retryCount, downloadSizes);
      final semaphore = Semaphore(simultaneousDownloads);
      final tasks = <int>[];
      final stopwatch = Stopwatch()..start();

      try {
        await Future.forEach(testData, (final String td) async {
          await semaphore.acquire();
          try {
            final data = await http.get(Uri.parse(td));
            tasks.add(data.bodyBytes.length);
          } finally {
            semaphore.release();
          }
        });
        stopwatch.stop();
        final totalSize = tasks.reduce((final a, final b) => a + b);
        downloadSpeed = (totalSize * 8 / 1024) /
            (stopwatch.elapsedMilliseconds / 1000) /
            1000;
        break;
      } on Exception catch (_) {
        continue;
      }
    }
    return downloadSpeed;
  }

  /// Returns [double] upload speed in MB/s.
  Future<double> testUploadSpeed({
    required final List<Server> servers,
    final int simultaneousUploads = 2,
    final int retryCount = 3,
  }) async {
    double uploadSpeed = 0;
    for (final s in servers) {
      final testData = generateUploadData(retryCount);
      final semaphore = Semaphore(simultaneousUploads);
      final stopwatch = Stopwatch()..start();
      final tasks = <int>[];

      try {
        await Future.forEach(testData, (final String td) async {
          await semaphore.acquire();
          try {
            // do post request to measure time for upload
            await http.post(Uri.parse(s.url), body: td);
            tasks.add(td.length);
          } finally {
            semaphore.release();
          }
        });
        stopwatch.stop();
        final totalSize = tasks.reduce((final a, final b) => a + b);
        uploadSpeed = (totalSize * 8 / 1024) /
            (stopwatch.elapsedMilliseconds / 1000) /
            1000;
        break;
      } on Exception catch (_) {
        continue;
      }
    }
    return uploadSpeed;
  }

  /// Generate list of [String] urls for upload.
  List<String> generateUploadData(final int retryCount) {
    final random = Random();
    final result = <String>[];

    for (var sizeCounter = 1; sizeCounter < maxUploadSize + 1; sizeCounter++) {
      final size = sizeCounter * 200 * 1024;
      final builder = StringBuffer()..write('content $sizeCounter=');

      for (var i = 0; i < size; ++i) {
        builder.write(hars[random.nextInt(hars.length)]);
      }

      for (var i = 0; i < retryCount; i++) {
        result.add(builder.toString());
      }
    }

    return result;
  }
}
