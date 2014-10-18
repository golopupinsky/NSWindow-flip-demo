//
//  mbFlipWindow.h
//  FlippingWindow
//
//  Created by Sergey Yuzepovich on 12.10.14.
//  Copyright (c) 2014 Sergey Yuzepovich. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
@interface mbFlipWindow : NSObject
{
    BOOL flipRight;
    double duration;
    NSWindow *mAnimationWindow;
    NSWindow *mTargetWindow;
}
- (void) flip:(NSWindow *)activeWindow to:(NSWindow *)targetWindow;

@property BOOL flipRight;
@property double duration;

@end
