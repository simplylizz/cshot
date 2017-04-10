//
//  main.m
//  cshot
//
//  Created by AY on 25/03/2017.
//  Copyright © 2017 ZetLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "capture.h"


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

    // Below is copy-paste from https://gist.github.com/bellbind/6954679
    NSError* error = nil;
    Capture* capture = [[Capture alloc] init];

    //NSArray* devices =
    //  [AVCaptureDevice devicesWithMediaType: AVMediaTypeVideo];
    //AVCaptureDevice* device = [devices objectAtIndex: 0];
    AVCaptureDevice* device =
    [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    NSLog(@"[device] %@", device);

    AVCaptureDeviceInput* input =
    [AVCaptureDeviceInput deviceInputWithDevice: device  error: &error];
    NSLog(@"[input] %@", input);

    AVCaptureVideoDataOutput* output =
    [[AVCaptureVideoDataOutput alloc] init];
    [output setSampleBufferDelegate: capture queue: dispatch_get_main_queue()];
    NSLog(@"[output] %@", output);

    AVCaptureSession* session = [[AVCaptureSession alloc] init];
    [session addInput: input];
    [session addOutput: output];

    capture.session = session;
    [session startRunning];
    NSLog(@"Started");
    CFRunLoopRun();

    NSLog(@"Stopped");
}
@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Starting program...");

        // NOTE: without variable program is failing with exception... maybe there is some optimizations?
        LockWatcher *lw = [[LockWatcher alloc]init];
        #pragma unused(lw)

        [[NSRunLoop currentRunLoop] run];

        NSLog(@"How ar u?");
    }
    return 0;
}
