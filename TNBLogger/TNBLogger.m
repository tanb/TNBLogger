//
//  TNBLogger.m
//  TNBLogger
//
//  Created by tanB on 2/24/14.
//  Copyright (c) 2014 tanb. All rights reserved.
//
//  It was inspired by SOLogger. https://github.com/billgarrison/SOLogger
//

#import "TNBLogger.h"

@interface TNBLogger ()
@property (nonatomic) NSCache *ASLClientCache;
@property (nonatomic) int outputFileDescriptor;
@property (nonatomic) NSString *facility;
@property (nonatomic) uint32_t options;
@property (nonatomic) int severityFilterMask;
@property (nonatomic) NSString *outputFilePath;

- (aslclient)currentASLClientRef;
- (void)logWithLevel:(int)aslLevel format:(NSString *)format arguments:(va_list)arguments;
@end


@interface _TNBASLClient : NSObject
@property (nonatomic) aslclient aslclientRef;

- (id)initWithLogger:(TNBLogger *)logger outputFileDescriptor:(int)descriptor
            facility:(NSString *)facility options:(uint32_t)options;
- (aslclient)aslclientRef;
@end


@implementation TNBLogger

- (id)initWithOutputFilePath:(NSString *)filePath
{
    NSString *appBundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
    int fileDescriptor = open([filePath fileSystemRepresentation], O_CREAT | O_WRONLY | O_APPEND, S_IRUSR | S_IWUSR);

    if (fileDescriptor == -1) {
#if DEBUG
        NSLog(@"[TNBLogger] can't open file: %@", filePath);
#endif
        return nil;
    }
#if DEBUG
    NSLog(@"[TNBLogger] log file location: %@", filePath);
#endif
    self = [[TNBLogger alloc] initWithOutputFileDescriptor:fileDescriptor
                                                  facility:appBundleID
                                                   options:ASL_OPT_STDERR | ASL_OPT_NO_DELAY | ASL_OPT_NO_REMOTE];
    _outputFilePath = filePath;
    _outputFileLogFormat = @"$(Time) $(Sender) [$(PID)] <$((Level)(str))>: $Message";
    return self;
}

- (id)initWithOutputFileDescriptor:(int)descriptor
                          facility:(NSString *)facility
                           options:(uint32_t)options
{
	self = [super init];
	if ( !self ) return nil;
    _outputFileDescriptor = descriptor;
    _facility = [facility copy];
    _options = options;
    _ASLClientCache = [NSCache new];

#if DEBUG
    _severityFilterMask = ASL_FILTER_MASK_UPTO(ASL_LEVEL_DEBUG);
#else
    _severityFilterMask = ASL_FILTER_MASK_UPTO(ASL_LEVEL_NOTICE);
#endif
    
	return self;
}

- (aslclient)currentASLClientRef
{
    NSString *threadKey = [NSString stringWithFormat:@"Thread%p", [NSThread currentThread]];
    _TNBASLClient *ASLClient = [self.ASLClientCache objectForKey:threadKey];
    
    if (!ASLClient) {
        ASLClient = [[_TNBASLClient alloc] initWithLogger:self
                                     outputFileDescriptor:self.outputFileDescriptor
                                                 facility:self.facility
                                                  options:self.options];

        if (!ASLClient) return NULL;
        
        [_ASLClientCache setObject:ASLClient forKey:threadKey];
        asl_set_filter(ASLClient.aslclientRef, self.severityFilterMask);
    }
    
    return ASLClient.aslclientRef;
}

- (void)logWithLevel:(int)aslLevel format:(NSString *)format arguments:(va_list)arguments
{
    if (format == nil) return;
    
    aslclient aslclient = [self currentASLClientRef];
    
    if (aslclient == NULL) {
#if DEBUG
        NSLog (@"Getting current thread ASL client failed.");
#endif
        return;
    }
    
    aslmsg message = asl_new(ASL_TYPE_MSG);
    asl_set(message, ASL_KEY_FACILITY, [self.facility UTF8String]);
    
    NSString *text = [[NSString alloc] initWithFormat:format arguments:arguments];
    
    int err = asl_log(aslclient, message, aslLevel, "%s", [text UTF8String]);
    
    if (err != 0) {
#if DEBUG
        NSLog (@"asl_log failed. message: %@", text);
#endif
    }
    
    asl_free (message);
    
    [self truncateLogFile];
}

- (void)truncateLogFile
{
    NSData *orginData = [NSData dataWithContentsOfFile:self.outputFilePath];
    NSInteger maxFileSize = 1024 * 1024 * 1; // 1MB

    if ([orginData length] > maxFileSize) {
        // truncate log file to half size.
        NSRange range = {[orginData length] / 2, ([orginData length] / 2) -1};
        
        NSData *shortData = [[NSData dataWithContentsOfFile:self.outputFilePath] subdataWithRange:range];
        
        [shortData writeToFile:self.outputFilePath atomically:YES];
    }
}

#pragma mark - Logging methods.
- (void)emergency:(NSString *)format, ...
{
    va_list arglist;
    va_start (arglist, format);
    [self logWithLevel:ASL_LEVEL_EMERG format:format arguments:arglist];
    va_end (arglist);
}

- (void)alert:(NSString *)format, ...
{
    va_list arglist;
    va_start (arglist, format);
    [self logWithLevel:ASL_LEVEL_ALERT format:format arguments:arglist];
    va_end (arglist);
}

- (void)critical:(NSString *)format, ...
{
    va_list arglist;
    va_start (arglist, format);
    [self logWithLevel:ASL_LEVEL_CRIT format:format arguments:arglist];
    va_end (arglist);
}

- (void)error:(NSString *)format, ...
{
    va_list arglist;
    va_start (arglist, format);
    [self logWithLevel:ASL_LEVEL_ERR format:format arguments:arglist];
    va_end (arglist);
}

- (void)warning:(NSString *)format, ...
{
    va_list arglist;
    va_start (arglist, format);
    [self logWithLevel:ASL_LEVEL_WARNING format:format arguments:arglist];
    va_end (arglist);
}

- (void)notice:(NSString *)format, ...
{
    va_list arglist;
    va_start (arglist, format);
    [self logWithLevel:ASL_LEVEL_NOTICE format:format arguments:arglist];
    va_end (arglist);
}

- (void)info:(NSString *)format, ...
{
#if DEBUG
    va_list arglist;
    va_start (arglist, format);
    [self logWithLevel:ASL_LEVEL_INFO format:format arguments:arglist];
    va_end (arglist);
#endif
}

- (void)debug:(NSString *)format, ...
{
#if DEBUG
    va_list arglist;
    va_start (arglist, format);
    [self logWithLevel:ASL_LEVEL_DEBUG format:format arguments:arglist];
    va_end (arglist);
#endif
}

#pragma mark - Clean up
- (void)dealloc;
{
    _ASLClientCache = nil;
    _facility = nil;
}

@end


@implementation _TNBASLClient
/* Presentation of connection to ASL server. */

- (id)initWithLogger:(TNBLogger *)logger outputFileDescriptor:(int)descriptor
            facility:(NSString *)facility options:(uint32_t)options
{
	self = [super init];
	if (!self) return nil;
    if (!logger) return nil;
    
	self.aslclientRef = asl_open(NULL, [facility UTF8String] , options);

    int err = 0;
    float versionNumber = floor(NSFoundationVersionNumber);

#if TARGET_OS_IPHONE
    float unavailableVersion = NSFoundationVersionNumber_iOS_6_1;
#else
    float unavailableVersion = NSFoundationVersionNumber10_8_4;
#endif
    
    if (versionNumber <= unavailableVersion) {
        err = asl_add_log_file(_aslclientRef, descriptor);
    } else {
        // The feature which adapting filter mask to each output file
        // is available from MAC_10_9 and IPHONE_7_0.
        err = asl_add_output_file(_aslclientRef, descriptor,
                                  [logger.outputFileLogFormat UTF8String],
                                  ASL_TIME_FMT_UTC,
                                  logger.severityFilterMask,
                                  ASL_ENCODE_SAFE);
    }
    
    if (err != 0) {
#if DEBUG
        NSLog (@"asl_add_log_file failed. descriptor: %d", descriptor);
#endif
    }
    
	return self;
}

- (aslclient)aslclientRef
{
    aslclient asl = NULL;
    @synchronized(self) {
        asl = _aslclientRef;
    }
    return asl;
}


#pragma mark - Clean up
- (void)dealloc
{
    if (_aslclientRef) {
		asl_close(_aslclientRef);
        _aslclientRef = NULL;
	}
}

@end