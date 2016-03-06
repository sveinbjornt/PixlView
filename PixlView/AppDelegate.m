//
//  AppDelegate.m
//  PixelViewer
//
//  Created by Sveinbjorn Thordarson on 19/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import "Constants.h"
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
    
    //[[NSDocumentController sharedDocumentController] openDocument:self];
    return NO;
}

//- (BOOL)application:(NSApplication *)theApplication
//           openFile:(NSString *)filename {
//    return YES;
//}

- (IBAction)newRandomBuffer:(id)sender {
    // prepare filename
    NSString *appPath = [[[NSBundle mainBundle] bundleURL] path];
    NSString *filename = @"/tmp/random.data";
    while ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        filename = [NSString stringWithFormat:@"/tmp/random%d.data", arc4random()];
    }
    
    // write
    int length = RANDOM_PIXEL_BUFFER_WIDTH * RANDOM_PIXEL_BUFFER_HEIGHT * 3;
    void *d = malloc(length);
    arc4random_buf(d, length);
    [[NSData dataWithBytes:d length:length] writeToFile:filename atomically:NO];
    free(d);

    // open
    [[NSWorkspace sharedWorkspace] openFile:filename withApplication:appPath];
}

@end
