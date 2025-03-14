import 'Logger.dart';

class stopWatch {
  static Stopwatch stopwatch = new Stopwatch();

  static start() {
    stopwatch.start();
  }

  static stop() {
    stopwatch.stop();
  }

  static reset() {
    stopwatch.reset();
  }

  static getElapsedTime() {
    stop();
    Duration duration = stopwatch.elapsed;
    logger.i(duration.inMilliseconds.toString() + " ms");
    reset();
  }
}
