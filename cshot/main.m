//
//  main.m
//  cshot
//
//  Created by AY on 25/03/2017.
//  Copyright © 2017 ZetLabs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LockWatcher : NSObject
- (id) init;
- (void)screenUnlocked;
@end


@implementation LockWatcher
- (id) init {
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(screenUnlocked)
                   name:@"com.apple.screenIsUnlocked"
                 object:nil
     ];

    return self;
}

- (void)screenUnlocked {
    NSLog(@"Screen is unlocked!");
}
@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Hi there!!");

        // NOTE: without variable program is failing with exception... maybe there is some optimizations?
        LockWatcher *lw = [[LockWatcher alloc]init];
        [[NSRunLoop currentRunLoop] run];

        NSLog(@"How ar u?");
    }
    return 0;
}
