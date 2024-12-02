import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_odbc/dart_odbc.dart';
import 'package:logging/logging.dart';

/// You can choose one of the following log levels to tell Nudger what to log:
/// * [none]: No logging.
/// * [onError]: Logs only database connection or nudge errors.
/// * [onNudge]: Logs complete database connection and nudge execution flow.
enum Logging {
  /// I don't want any logs.
  none,

  /// I want to log database connection or nudge errors only.
  onError,

  /// I want to log complete database connection and nudge execution flow.
  onNudge
}

/// This configuration defines how Nudger connects to your database and what it
/// can and can't log.
final class Config {
  /// Before using Nudger, you must tell it what are your database connection p-
  /// arameters and choose a log level.
  ///
  /// [dsn]: What is the host, port and database name of your database?
  /// [databaseUser] and [databasePassword]: What are your database credentials?
  /// [logLevel]: What do you want to log?
  const Config(
      this.dsn,
      this.databaseUser,
      this.databasePassword,
      this.logLevel,
  );

  // What is the host, port and database name of your database?
  final String dsn;

  // Who is your database user?
  final String databaseUser;

  // What is the password for your database user?
  final String databasePassword;

  // What do you want to log?
  final Logging logLevel;
}

/// This decorator adds database nudging capabilities to the dart_odbc library.
///
/// Nudger keeps the database alive by sending a lightweight (SQL) query regula-
/// rly.
///
/// Usage:
/// ```dart
/// final db = DartOdbc(...);
/// final config = Config(logLevel: Logging.onNudge);
///
/// // Nudge your database every 5 minutes to keep it alive
/// Timer.periodic(Duration(minutes: 5), (_) async {
///   await db.nudge(config);
/// });
/// ```
extension Nudger on DartOdbc {
  /// Before nudging your database, make sure you've set up a [Config] with your
  /// database connection parameters and a log level.
  ///
  /// [config]: What are your database connection parameters and log level?
  ///
  /// Returns [true] if the database has been nudged successfully. Returns [fal-
  /// se] if it hasn't.
  Future<bool> nudge(Config config) async {
    // Establish a logger
    final logger = Logger('Nudger')
      ..level = switch(config.logLevel) {
        Logging.none => Level.OFF,
        Logging.onError => Level.SEVERE,
        Logging.onNudge => Level.INFO
      };

    try {
      // Lightweight (SQL) query
      await execute('SELECT NOW();');
      logger.info('Database nudged');
      return true;
    } catch (error) {
      logger.severe("Couldn't nudge the database ($error).");
      return false;
    }
  }
}

// This route provides an HTTP endpoint for database nudges.
Future<Response> onRequest(RequestContext context) async {
  // Create a Config using environment variables; they are empty if not set.
  final config = Config(
    Platform.environment['DSN'] ?? '',
    Platform.environment['USER'] ?? '',
    Platform.environment['PASSWORD'] ?? '',
    Logging.none,
  );

  // Establish a logger
  final logger = Logger('ODBC')
    ..level = switch(config.logLevel) {
      Logging.none => Level.OFF,
      Logging.onError => Level.SEVERE,
      Logging.onNudge => Level.INFO
    };

  final database = DartOdbc(
    dsn: Platform.environment['DSN'] ?? '',
    pathToDriver: '/usr/lib/oracle/client/lib/libsqora.so.19.1',
  );

  // Connect to a database
  try {
    await database.connect(
      username: config.databaseUser,
      password: config.databasePassword,
    );
  } catch (error) {
    logger.shout("Couldn't connect to the database: $error.");

    return Response(
      statusCode: 500,
      headers: {'Content-Type': 'application/json'},
      body: '{"error": "$error"}',
    );
  }

  logger.info('Connected to the database.');

  // Nudge a database
  try {
    await database.nudge(config);
  } catch (error) {
    logger.shout("Nudger couldn't nudge the database.");

    return Response(
      statusCode: 500,
      headers: {'Content-Type': 'application/json'},
      body: '{"error": "$error"}',
    );
  } finally {
    await database.disconnect();
  }

  logger.info('Nudged the database.');

  return Response();  // Return a successful HTTP response
}
