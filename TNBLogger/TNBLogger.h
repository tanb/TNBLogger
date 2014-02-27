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

- (id)initWithOutputFilePath:(NSString *)filePath;

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
