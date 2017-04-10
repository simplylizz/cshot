//
//  capture.h
//  cshot
//
//  Created by AY on 25/03/2017.
//  Copyright © 2017 ZetLabs. All rights reserved.
//

#ifndef capture_h
#define capture_h


#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>

@interface Capture : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (weak) AVCaptureSession* session;
- (void) captureOutput: (AVCaptureOutput*) output
 didOutputSampleBuffer: (CMSampleBufferRef) buffer
        fromConnection: (AVCaptureConnection*) connection;
@end
@interface Capture ()
{
    CVImageBufferRef head;
    CFRunLoopRef runLoop;
    int count;
}
- (void) save;
@end


#endif /* capture_h */
