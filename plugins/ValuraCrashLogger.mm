// ValuraCrashLogger.mm
//
// Installs a C++ std::terminate handler (NOT NSSetUncaughtExceptionHandler,
// which does not fire for this crash path) to capture the reason of
// Objective-C exceptions that get re-thrown as C++ exceptions inside React
// Native's TurboModule void-method invocation path
// (facebook::react::ObjCTurboModule::performVoidMethodInvocation), which is
// otherwise invisible in Apple's on-device .ips crash reports.
//
// This file installs itself automatically via +load, so nothing else in the
// app (Swift/AppDelegate) needs to call anything.

#import <Foundation/Foundation.h>
#include <exception>

static void valura_terminate_handler(void) {
  @try {
    if (auto currentException = std::current_exception()) {
      std::rethrow_exception(currentException);
    }
  } @catch (NSException *exception) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZZ";
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];

    NSString *report = [NSString stringWithFormat:
      @"Timestamp: %@\nName: %@\nReason: %@\nCall Stack Symbols:\n%@\n",
      timestamp,
      exception.name,
      exception.reason ?: @"(no reason provided)",
      [exception.callStackSymbols componentsJoinedByString:@"\n"]];

    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(
      NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = paths.firstObject;
    if (documentsPath != nil) {
      NSString *logPath = [documentsPath stringByAppendingPathComponent:@"crash_log.txt"];
      NSError *writeError = nil;
      [report writeToFile:logPath
               atomically:YES
                 encoding:NSUTF8StringEncoding
                    error:&writeError];
    }
  } @catch (...) {
    // Not an NSException (a plain C++ exception) - can't extract a
    // human-readable reason this way, but at least we won't crash while
    // trying to log the crash.
  }
  // Let the process terminate as it normally would.
  abort();
}

@interface ValuraCrashLoggerInstaller : NSObject
@end

@implementation ValuraCrashLoggerInstaller
+ (void)load {
  std::set_terminate(&valura_terminate_handler);
}
@end
