//
//  AppDelegate.m
//  FlippingWindow
//
//  Created by Sergey Yuzepovich on 12.10.14.
//  Copyright (c) 2014 Sergey Yuzepovich. All rights reserved.
//

#import "AppDelegate.h"
#import "mbFlipWindow.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    NSWindow *mainWindow;
    NSWindow *secondaryWindow;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupWindows];
}




-(void)setupWindows
{
    mainWindow = [NSApplication sharedApplication].windows[0];
    secondaryWindow = [[NSWindow alloc]init];
    [secondaryWindow setFrame:mainWindow.frame display:false];
    
    NSStoryboard *mainStoryboard = [NSStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    NSViewController *vc = [mainStoryboard instantiateControllerWithIdentifier:@"BackViewController"];
    [secondaryWindow setContentViewController:vc];
}

- (void)flip {
    
    static mbFlipWindow *flipWnd;
    if(flipWnd == nil)
    {
        flipWnd = [[mbFlipWindow alloc]init];
    }
    
    if(flipWnd.flipRight)
        [flipWnd flip:mainWindow to:secondaryWindow];
    else
        [flipWnd flip:secondaryWindow to:mainWindow];
    
    flipWnd.flipRight = !flipWnd.flipRight;
    
}



@end
