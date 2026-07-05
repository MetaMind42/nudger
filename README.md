# Nudger

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MPL][license_badge]][license_link]
[![Powered by Dart Frog](https://img.shields.io/endpoint?url=https://tinyurl.com/dartfrog-badge)](https://dartfrog.vgv.dev)

Keep-alive utility for scale-to-zero Oracle ATP DBs. Provides you with a /nudge endpoint.

## Stack

- Dart 3.5.4
- Dart Frog 1.0.0
- dart_odbc 4.1.2+1
- Oracle Instant Client 21 (ODBC driver)
- Docker

## Deployment
Use the provided Dockerfile to deploy the utility. You can call the /nudge endpoint then.

```
docker build -t nudger .
docker run -p 8080:8080 nudger
curl http://localhost:8080/nudge
```

## License
Released under [Mozilla Public License 2.0](https://opensource.org/license/mpl-2.0/). Use, modify and distribute freely. Including for commercial purposes, as long as changes to MPL-licensed files stay under the same license and the license notice is preserved.

[license_badge]: https://img.shields.io/badge/license-MPL--2.0-blue.svg
[license_link]: https://opensource.org/licenses/MPL-2.0
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
