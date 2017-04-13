//
//  NSTimer+ZDUtility.h
//  Pods
//
//  Created by 符现超 on 2017/4/13.
//
//

#import <Foundation/Foundation.h>

@interface NSTimer (ZDUtility)

+ (NSTimer *)zd_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats;

+ (NSTimer *)zd_timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats;

@end
