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
    
    int width = [[widthTextField stringValue] intValue];
    int height = [[heightTextField stringValue] intValue];
    CGFloat scale = 1.0f;
    
    // Create GL view and add to scroll view
    NSRect glFrame = NSMakeRect(0, 0, width, height);
    glView = [[GLPixelView alloc] initWithFrame:glFrame pixelFormat:nil scale:scale];
    glView.scale = scale;
    glView.autoresizingMask = NSViewNotSizable;
    [pixelScrollView setDocumentView:glView];
    
    // Populate pixel format popup
    [formatPopupButton removeAllItems];
    for (NSString *format in [PixelBuffer supportedFormats]) {
        [formatPopupButton addItemWithTitle:format];
    }

}

#pragma mark - Control delegate

- (IBAction)pixelFormatChanged:(id)sender {
    pixelBuffer.pixelFormat = [formatPopupButton indexOfSelectedItem];
    glView.pixelData = [pixelBuffer toRGBA];
    [glView setNeedsDisplay:YES];
    [self updateBufferInfo];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    int width = [[widthTextField stringValue] intValue];
    int height = [[heightTextField stringValue] intValue];

    glView.frame = NSMakeRect(0, 0, width, height);
    [glView setNeedsDisplay:YES];
    [self updateBufferInfo];
}

- (IBAction)scaleSliderValueChanged:(id)sender {
    int perc = ([sender intValue] * 5);
    glView.scale = (float)perc / 100;
    [scaleTextField setStringValue:[NSString stringWithFormat:@"%d%%", perc]];

    
    int width = [[widthTextField stringValue] intValue];
    int height = [[heightTextField stringValue] intValue];
    glView.frame = NSMakeRect(0, 0, width, height);
    [glView setNeedsDisplay:YES];
}

- (void)updateBufferInfo {
    int width = [[widthTextField stringValue] intValue];
    int height = [[heightTextField stringValue] intValue];

    int fileDataLength = pixelBuffer.data.length;
    int bufferSize = [pixelBuffer expectedBitLengthForImageSize:NSMakeSize(width, height)] / 8;
    
    NSString *bufferInfoString = [NSString stringWithFormat:
                                  @"Data in: %d    Buffer out: %d   Diff: %@%d",
                                  fileDataLength,
                                  bufferSize,
                                  fileDataLength-bufferSize > 0 ? @"+" : @"",
                                  fileDataLength-bufferSize];
    [bufferInfoTextField setStringValue:bufferInfoString];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    [self openFile:@"/Users/sveinbjorn/Desktop/kisi.data"];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


#pragma mark - File

- (void)openFile:(NSString *)filePath {
    
    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:filePath];
    [fileIconImageView setImage:icon];
    [filePathTextField setStringValue:filePath];
    [fileMD5TextField setStringValue:[self md5hashForFileAtPath:filePath]];
    
    pixelBuffer = [[PixelBuffer alloc] initWithContentsOfFile:filePath];
    pixelBuffer.pixelFormat = [formatPopupButton indexOfSelectedItem];
    glView.pixelData = [pixelBuffer toRGBA];
    [glView setNeedsDisplay:YES];
    
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
