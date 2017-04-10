// capture image from webcam (e.g. face time)
// for OSX 10.9 (use AVFoundation API instead of deprecated QTKit)
// clang -fobjc-arc -Wall -Wextra -pedantic avcapture.m
//    -framework Cocoa -framework AVFoundation -framework CoreMedia
//    -framework QuartzCore -o avcapture

#import "capture.h"
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>

#define SHOTS_DIR_NAME @"cshots"


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
        // TODO: move some objects initialization to constructor

        CIImage* ciImage = [CIImage imageWithCVImageBuffer: head];
        NSBitmapImageRep* bitmapRep = [[NSBitmapImageRep alloc] initWithCIImage: ciImage];

        // TBD: which props to use?
        NSData* jpgData = [bitmapRep representationUsingType: NSJPEGFileType properties: nil];

        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSString* path = [[fileManager homeDirectoryForCurrentUser] path];
        path = [NSString stringWithFormat: @"%@/%@/", path, SHOTS_DIR_NAME];

        NSLog(@"Creating shots dir: %@", path);
        [fileManager createDirectoryAtPath: path
               withIntermediateDirectories: YES
                                attributes: nil
                                     error: nil];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"yyyyMMdd_HHmmss"];
        NSString *date = [formatter stringFromDate: [NSDate date]];

        NSString *fileName = [NSString stringWithFormat: @"%@%@.jpg", path, date];

        NSLog(@"Saving shot as %@", fileName);
        [jpgData writeToFile: fileName atomically: NO];
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
