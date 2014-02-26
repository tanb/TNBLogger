TNBLogger
==============

ASL (Apple System Log) APIs wrapper.

Inspired by [billgarrison/SOLogger](https://github.com/billgarrison/SOLogger). TNBLogger can adapt a filter mask to specified output file (**It's available from OSX10.9 and iOS7**). And be more simple than [SOLogger](https://github.com/billgarrison/SOLogger). See also [asl(3)](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man3/asl.3.html)

## Usage
Set output file path.
```objective-c
NSString *appBundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
NSString *logPath = [NSString stringWithFormat:@"/Users/%@/Desktop", NSUserName()];
NSString *fileName = [NSString stringWithFormat:@"%@.log", appBundleID];
NSString *logFilePath = [logPath stringByAppendingPathComponent:fileName];

TNBLogger *logger = [[TNBLogger alloc] initWithOutputFilePath:logFilePath];

[logger debug:@"%@", @"Hello. I am TNBLogger."];
```

See the log file from terminal.
```bash
✓[~] $ tail -f ~/Desktop/me.tanb.TNBLoggerSample.log
2014-02-26 11:29:15Z tanbmba.local TNBLoggerSample[1872] <Debug>: application:didFinishLaunchingWithOptions:
2014-02-26 11:29:15Z tanbmba.local TNBLoggerSample[1872] <Debug>: applicationDidBecomeActive:
2014-02-26 11:30:17Z tanbmba.local TNBLoggerSample[1885] <Debug>: application:didFinishLaunchingWithOptions:
2014-02-26 11:30:17Z tanbmba.local TNBLoggerSample[1885] <Debug>: applicationDidBecomeActive:
2014-02-26 11:31:05Z tanbmba.local TNBLoggerSample[1963] <Debug>: application:didFinishLaunchingWithOptions:
2014-02-26 11:31:05Z tanbmba.local TNBLoggerSample[1963] <Debug>: applicationDidBecomeActive:
2014-02-26 11:37:20Z tanbmba.local TNBLoggerSample[2062] <Debug>: application:didFinishLaunchingWithOptions:
2014-02-26 11:37:20Z tanbmba.local TNBLoggerSample[2062] <Debug>: applicationDidBecomeActive:
```

## Tips

Useful macro.
```
#ifdef DEBUG
#define DLog(fmt, ...) [gLogger debug:(@"[Line %d] %s " fmt), __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__];
#else
#define DLog(...)
#endif
```


## License
TNBLogger is available under the MIT license. See the LICENSE file for more info.
