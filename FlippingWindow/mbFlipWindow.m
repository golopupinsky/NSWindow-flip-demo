//
//  mbFlipWindow.m
//  FlippingWindow
//
//  Created by Sergey Yuzepovich on 12.10.14.
//  Copyright (c) 2014 Sergey Yuzepovich. All rights reserved.
//

#import "mbFlipWindow.h"
#import <QuartzCore/QuartzCore.h>

@interface mbFlipWindow ()
- (NSWindow *) windowForAnimation:(NSRect)aFrame;
- (CALayer *) layerFromView :(NSView*)view;
NSRect RectToScreen(NSRect aRect, NSView *aView);
NSRect RectFromScreen(NSRect aRect, NSView *aView);
NSRect RectFromViewToView(NSRect aRect, NSView *fromView, NSView *toView);
- (CAAnimation *) animationWithDuration:(CGFloat)time flip:(BOOL)bFlip right:(BOOL)rightFlip;
@end

@implementation mbFlipWindow
{
    double _scaleAnimation;
}
@synthesize flipRight;
@synthesize duration;

- (id)init
{
    self = [super init];
    if (self) {
        duration = 2.0;
        flipRight = YES;
        _scaleAnimation = 1.2;
    }
    return self;
}

- (NSWindow *) windowForAnimation:(NSRect)aFrame {
    
    NSWindow *wnd =  [[NSWindow alloc] initWithContentRect:aFrame
                                                 styleMask:NSBorderlessWindowMask
                                                   backing:NSBackingStoreBuffered
                                                     defer:NO];
    [wnd setOpaque:NO];
    [wnd setHasShadow:NO];
    [wnd setBackgroundColor:[NSColor clearColor]];
    [wnd.contentView setWantsLayer:YES];
    [wnd setLevel:NSScreenSaverWindowLevel];
    return wnd;
}

- (CALayer *) layerFromView :(NSView*)view {
    
    NSBitmapImageRep *image = [view bitmapImageRepForCachingDisplayInRect:view.bounds];
    [view cacheDisplayInRect:view.bounds toBitmapImageRep:image];
    
    CALayer *layer = [CALayer layer];
    layer.contents = (id)image.CGImage;
    layer.doubleSided = NO;
    
    [layer setShadowOpacity:0.5f];
    [layer setShadowOffset:CGSizeMake(0,-10)];
    [layer setShadowRadius:15.0f];
    
    
    return layer;
}


NSRect RectToScreen(NSRect aRect, NSView *aView) {
    aRect = [aView convertRect:aRect toView:nil];
    aRect = [aView.window convertRectToScreen:aRect];
    return aRect;
}

NSRect RectFromScreen(NSRect aRect, NSView *aView) {
    aRect = [aView.window convertRectFromScreen:aRect];
    aRect = [aView convertRect:aRect fromView:nil];
    return aRect;
}

NSRect RectFromViewToView(NSRect aRect, NSView *fromView, NSView *toView) {
    
    aRect = RectToScreen(aRect, fromView);
    aRect = RectFromScreen(aRect, toView);
    
    return aRect;
}

- (CAAnimation *) animationWithDuration:(CGFloat)time flip:(BOOL)bFlip right:(BOOL)rightFlip{
    
    CABasicAnimation *flipAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    
    CGFloat startValue, endValue;
    
    if ( rightFlip ) {
        startValue = bFlip ? 0.0f : -M_PI;
        endValue = bFlip ? M_PI : 0.0f;
    } else {
        startValue = bFlip ? 0.0f : M_PI;
        endValue = bFlip ? -M_PI : 0.0f;
    }
    
    flipAnimation.fromValue = [NSNumber numberWithDouble:startValue];
    flipAnimation.toValue = [NSNumber numberWithDouble:endValue];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.toValue = [NSNumber numberWithFloat:_scaleAnimation];
    scaleAnimation.duration = time * 0.5;
    scaleAnimation.autoreverses = YES;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:flipAnimation, scaleAnimation, nil];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.duration = time;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    
    return animationGroup;
}


- (void) animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    
    if (flag) {
        [mTargetWindow makeKeyAndOrderFront:nil];
        [mAnimationWindow orderOut:nil];
        
        mTargetWindow = nil;
        mAnimationWindow = nil;
    }
}

- (void) flip:(NSWindow *)activeWindow to:(NSWindow *)targetWindow {
    
    CGFloat durat = duration * (activeWindow.currentEvent.modifierFlags & NSShiftKeyMask ? 10.0 : 1.0);
    CGFloat zDistance = 1500.0f;
    
    NSView *activeView = [activeWindow.contentView superview];
    NSView *targetView = [targetWindow.contentView superview];
    
    CGFloat maxWidth  = MAX(NSWidth(activeWindow.frame), NSWidth(targetWindow.frame));
    CGFloat maxHeight = MAX(NSHeight(activeWindow.frame), NSHeight(targetWindow.frame));
    if(_scaleAnimation > 0.0){
        double xscale = _scaleAnimation * 2.0;
        maxWidth += maxWidth * xscale;
        maxHeight += maxHeight * xscale;
    }
    
    CGRect animationFrame = CGRectMake(NSMidX(activeWindow.frame) - (maxWidth / 2),
                                       NSMidY(activeWindow.frame) - (maxHeight / 2),
                                       maxWidth,
                                       maxHeight);
    
    mAnimationWindow = [self windowForAnimation:NSRectFromCGRect(animationFrame)];
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / zDistance;
    
    CGRect targetFrame = CGRectMake(NSMidX(activeWindow.frame) - (NSWidth(targetWindow.frame) / 2 ),
                                    NSMaxY(activeWindow.frame) - NSHeight(targetWindow.frame),
                                    NSWidth(targetWindow.frame),
                                    NSHeight(targetWindow.frame));
    
    [targetWindow setFrame:NSRectFromCGRect(targetFrame) display:NO];
    
    mTargetWindow = targetWindow;
    
    [CATransaction begin];
    CALayer *activeWindowLayer = [self layerFromView: activeView];
    CALayer *targetWindowLayer = [self layerFromView:targetView];
    [CATransaction commit];
    
    [mAnimationWindow makeKeyAndOrderFront:nil];
    
    activeWindowLayer.frame = NSRectToCGRect(RectFromViewToView(activeView.frame, activeView,
                                                                [mAnimationWindow contentView]));
    targetWindowLayer.frame = NSRectToCGRect(RectFromViewToView(targetView.frame, targetView,
                                                                [mAnimationWindow contentView]));
    
    activeWindowLayer.transform = transform;
    targetWindowLayer.transform = transform;
    
    
    [CATransaction begin];
    [[mAnimationWindow.contentView layer] addSublayer:activeWindowLayer];
    [CATransaction commit];
    
    
    
    [CATransaction begin];
    [[mAnimationWindow.contentView layer] addSublayer:targetWindowLayer];
    [CATransaction commit];
    
    [CATransaction begin];
    CAAnimation *activeAnim = [self animationWithDuration:(durat * 0.5) flip:YES right:flipRight];
    CAAnimation *targetAnim = [self animationWithDuration:(durat * 0.5) flip:NO  right:flipRight];
    [CATransaction commit];
    
    targetAnim.delegate = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [activeWindow orderOut:nil];
    });
    
    [CATransaction begin];
    [activeWindowLayer addAnimation:activeAnim forKey:@"flipWnd"];
    [targetWindowLayer addAnimation:targetAnim forKey:@"flipWnd"];
    [CATransaction commit];
}
@end
