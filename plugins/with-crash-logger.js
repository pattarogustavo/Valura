const { withAppDelegate } = require('@expo/config-plugins');
const { mergeContents } = require('@expo/config-plugins/build/utils/generateCode');

// Installs an NSSetUncaughtExceptionHandler as early as possible in
// didFinishLaunchingWithOptions, before super.application(...) runs, so we
// can capture the Objective-C exception reason/callstack that Apple's .ips
// crash reports on-device are omitting from "Application Specific Information".
const HANDLER_FUNCTION = `
func valuraUncaughtExceptionHandler(_ exception: NSException) {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
  let timestamp = dateFormatter.string(from: Date())

  let report = """
  Timestamp: \\(timestamp)
  Name: \\(exception.name.rawValue)
  Reason: \\(exception.reason ?? "unknown")
  Call Stack Symbols:
  \\(exception.callStackSymbols.joined(separator: "\\n"))
  """

  if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
    let logPath = documentsPath.appendingPathComponent("crash_log.txt")
    try? report.write(to: logPath, atomically: true, encoding: .utf8)
  }
}
`;

const INSTALL_HANDLER_CALL = 'NSSetUncaughtExceptionHandler(valuraUncaughtExceptionHandler)';

function withCrashLogger(config) {
  return withAppDelegate(config, (config) => {
    if (config.modResults.language !== 'swift') {
      throw new Error(
        'withCrashLogger: expected AppDelegate.swift, got ' + config.modResults.language
      );
    }

    let contents = config.modResults.contents;

    // mergeContents matches `anchor` against individual lines, so anchors
    // must be single-line regexes, not multi-line patterns.
    const mergedFunction = mergeContents({
      src: contents,
      newSrc: HANDLER_FUNCTION,
      tag: 'valura-crash-logger-function',
      anchor: /^import ReactAppDependencyProvider$/,
      offset: 1,
      comment: '//',
    });
    contents = mergedFunction.contents;

    const mergedInstall = mergeContents({
      src: contents,
      newSrc: `    ${INSTALL_HANDLER_CALL}`,
      tag: 'valura-crash-logger-install',
      anchor: /let delegate = ReactNativeDelegate\(\)/,
      offset: 0,
      comment: '//',
    });
    contents = mergedInstall.contents;

    config.modResults.contents = contents;
    return config;
  });
}

module.exports = withCrashLogger;
