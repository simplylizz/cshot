// capture image from webcam(e.g. face time)
// for OSX 10.9 (use AVFoundation API instead of deprecated QTKit)
// clang -fobjc-arc -Wall -Wextra -pedantic avcapture.m
//    -framework Cocoa -framework AVFoundation -framework CoreMedia
//    -framework QuartzCore -o avcapture

#import "capture.h"
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>


@implementation Capture
@synthesize session;

- (id) init
{
    self = [super init];
    runLoop = CFRunLoopGetCurrent();
    head = nil;
    count = 0;
    return self;
}

- (void) dealloc
{
    @synchronized (self) {
        CVBufferRelease(head);
    }
    NSLog(@"capture released");
}

- (void) save
{
    @synchronized (self) {
        CIImage* ciImage =
        [CIImage imageWithCVImageBuffer: head];
        NSBitmapImageRep* bitmapRep =
        [[NSBitmapImageRep alloc] initWithCIImage: ciImage];

        NSData* jpgData =
        [bitmapRep representationUsingType:NSJPEGFileType properties: nil];
        [jpgData writeToFile: @"/Users/sp/result.jpg" atomically: NO];
    }
    NSLog(@"Saved");
}

- (void) captureOutput: (AVCaptureOutput*) output
 didOutputSampleBuffer: (CMSampleBufferRef) buffer
        fromConnection: (AVCaptureConnection*) connection
{
#pragma unused (output)
#pragma unused (connection)
    CVImageBufferRef frame = CMSampleBufferGetImageBuffer(buffer);
    CVImageBufferRef prev;
    CVBufferRetain(frame);
    @synchronized (self) {
        prev = head;
        head = frame;
        count++;
        NSLog(@"Captured");
    }
    CVBufferRelease(prev);
    if (count == 6) {
        // after skipped 5 frames
        [self save];
        [self.session stopRunning];
        CFRunLoopStop(runLoop);
    }
}
@end


int quit(NSError * error)
{
    NSLog(@"[error] %@", [error localizedDescription]);
    return 1;
}
