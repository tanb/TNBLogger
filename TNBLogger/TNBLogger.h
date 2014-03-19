//
//  TNBLogger.h
//  TNBLogger
//
//  Created by tanB on 2/24/14.
//  Copyright (c) 2014 tanb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <asl.h>

@interface TNBLogger : NSObject
/* outputFileLogFormat. Default is @"$(Time) $(Sender) [$(PID)] <$((Level)(str))>: $Message".
 See also asl(3) https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man3/asl.3.html
 */
@property (nonatomic) NSString *outputFileLogFormat;


/*
 #define ASL_LEVEL_EMERG   0
 #define ASL_LEVEL_ALERT   1
 #define ASL_LEVEL_CRIT    2
 #define ASL_LEVEL_ERR     3
 #define ASL_LEVEL_WARNING 4
 #define ASL_LEVEL_NOTICE  5
 #define ASL_LEVEL_INFO    6
 #define ASL_LEVEL_DEBUG   7
 */
- (id)initWithOutputFilePath:(NSString *)filePath filterLevel:(int)filterLevel;

#pragma mark - Logging methods
- (void)emergency:(NSString *)message, ...;
- (void)alert:(NSString *)message, ...;
- (void)critical:(NSString *)message, ...;
- (void)error:(NSString *)message, ...;
- (void)warning:(NSString *)message, ...;
- (void)notice:(NSString *)message, ...;
- (void)info:(NSString *)message, ...;
- (void)debug:(NSString *)message, ...;

@end
