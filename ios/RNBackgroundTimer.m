//
//  RNBgTimer.m
//  react-native-bg-timer
//
//  Created by IjzerenHein on 06-09-2016.
//  Copyright (c) ATO Gear. All rights reserved.
//

@import UIKit;
#import "RNBgTimer.h"

@implementation RNBgTimer {
    UIBackgroundTaskIdentifier bgTask;
    int delay;
}

RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents { return @[@"bgTimer", @"bgTimer.timeout"]; }

- (void) _start
{
    [self _stop];
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"RNBgTimer" expirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    UIBackgroundTaskIdentifier thisBgTask = bgTask;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self bridge] != nil && thisBgTask == bgTask) {
            [self sendEventWithName:@"bgTimer" body:[NSNumber numberWithInt:(int)thisBgTask]];
        }
    });
}

- (void) _stop
{
    if (bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
}

RCT_EXPORT_METHOD(start:(int)_delay
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    delay = _delay;
    [self _start];
    resolve([NSNumber numberWithBool:YES]);
}

RCT_EXPORT_METHOD(stop:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self _stop];
    resolve([NSNumber numberWithBool:YES]);
}

RCT_EXPORT_METHOD(setTimeout:(int)timeoutId
                     timeout:(int)timeout
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    __block UIBackgroundTaskIdentifier task = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"RNBgTimer" expirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:task];
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeout * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        if ([self bridge] != nil) {
            [self sendEventWithName:@"bgTimer.timeout" body:[NSNumber numberWithInt:timeoutId]];
        }
        [[UIApplication sharedApplication] endBackgroundTask:task];
    });
    resolve([NSNumber numberWithBool:YES]);
}

/*
RCT_EXPORT_METHOD(clearTimeout:(int)timeoutId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    // Do nothing :)
    // timeout will be ignored in javascript anyway :)
}*/

@end
