//
//  AppDelegate.m
//  PixelViewer
//
//  Created by Sveinbjorn Thordarson on 19/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import "AppDelegate.h"
#import "GLPixelView.h"
#import "PixelBuffer.h"

@implementation AppDelegate

- (void)awakeFromNib {

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag {
    return NO;
}

//- (BOOL)application:(NSApplication *)theApplication
//           openFile:(NSString *)filename {
//    return YES;
//}

- (IBAction)newRandomBuffer:(id)sender {
    int length = 1228800;
    
    void *d = malloc(length);
    arc4random_buf(d, length);
    [[NSData dataWithBytes:d length:length] writeToFile:@"/tmp/random.data" atomically:NO];
    free(d);
    NSString *appPath = [[[NSBundle mainBundle] bundleURL] path];
    [[NSWorkspace sharedWorkspace] openFile:@"/tmp/random.data" withApplication:appPath];
//    [[NSApplication sharedApplication] ]
}

@end
