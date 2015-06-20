//
//  AppDelegate.m
//  PixelViewer
//
//  Created by Sveinbjorn Thordarson on 19/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import "AppDelegate.h"
#import "GLPixelView.h"
#import "BackingView.h"

@implementation AppDelegate

- (void)awakeFromNib {
    
    
    int width = [[widthTextField stringValue] intValue];
    int height = [[heightTextField stringValue] intValue];
    
    
    
    
    
    
    // populate pixel format menu button
//    [formatPopupButton removeAllItems];
//    for (NSString *format in PIXEL_FORMATS) {
//        NSString *fmtName = [NSClassFromString(format) name];
//        [formatPopupButton addItemWithTitle:fmtName];
//    }

    //
//    NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:glAttributes];
//    NSOpenGLContext *openGLContext = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];
//    [openGLContext makeCurrentContext];
    
    BackingView *backingView = [[BackingView alloc] initWithFrame:[pixelScrollView frame]];
    backingView.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
    backingView.wantsLayer = YES;
    backingView.layer.backgroundColor = CGColorCreateGenericRGB(1.0, 0.0, 0.0, 0.4);

    NSRect glFrame = NSMakeRect(0, 0, width, height);
    glView = [[GLPixelView alloc] initWithFrame:glFrame pixelFormat:nil];
    glView.autoresizingMask = NSViewNotSizable | NSViewMaxXMargin;
    [backingView addSubview:glView];
    
    
    [pixelScrollView setDocumentView:backingView];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

//- (void)textDidChange:(NSNotification *)aNotification {
//    NSLog(@"Bleh!");
////    if ([aNotification object] == widthTextField || [aNotification object] == widthTextField) {
//    
//        int width = [[widthTextField stringValue] intValue];
//        int height = [[heightTextField stringValue] intValue];
//
//        NSRect glFrame = NSMakeRect(0, 0, width, height);
//        glView.frame = glFrame;
////    }
//}

- (void)controlTextDidChange:(NSNotification *)notification {
    int width = [[widthTextField stringValue] intValue];
    int height = [[heightTextField stringValue] intValue];

    NSRect glFrame = NSMakeRect(0, 0, width, height);
    glView.frame = glFrame;


}


- (void)openFile:(NSString *)filePath {
    
    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:filePath];
    [fileIconImageView setImage:icon];
    [filePathTextField setStringValue:filePath];
    [fileMD5TextField setStringValue:[self md5hashForFileAtPath:filePath]];
}

- (IBAction)selectFile:(id)sender {
    
    //create open panel
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setPrompt:@"Open"];
    [oPanel setAllowsMultipleSelection:NO];
    [oPanel setCanChooseDirectories:NO];
    
    //run open panel sheet
    [oPanel beginSheetModalForWindow:mainWindow completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            NSString *filePath = [[[oPanel URLs] objectAtIndex:0] path];
            [self openFile:filePath];
        }
    }];
}


- (NSString *)md5hashForFileAtPath:(NSString *)path
{
    BOOL isDir;
    
    //make sure it exists and isn't folder
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: &isDir] || isDir) {
        return nil;
    }
    
    NSPipe *pipe = [NSPipe pipe];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/sbin/md5"];
    [task setArguments:[NSArray arrayWithObject:path]];
    [task setStandardOutput:pipe];
    [task launch];
    
    //read the output from the command
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    
    NSString *outputStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    return [[outputStr componentsSeparatedByString:@" = "] objectAtIndex:1];
}


@end
