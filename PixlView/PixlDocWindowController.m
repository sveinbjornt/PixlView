//
//  DocumentWindowController.m
//  PixelViewer
//
//  Created by Sveinbjorn Thordarson on 21/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import "PixlDocWindowController.h"

@implementation PixlDocWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.doc = self.document;
    presetIndex = -1;

    // Create GL view and add to scroll view
    int width = [[widthTextField stringValue] intValue];
    int height = [[heightTextField stringValue] intValue];
    CGFloat scale = 1.0f;
    NSOpenGLPixelFormatAttribute pixelFormatAttributes[] = { 0 };
    NSRect glFrame = NSMakeRect(0, 0, width, height);
    glView = [[GLPixelView alloc] initWithFrame:glFrame
                                    pixelFormat:[[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes]
                                          scale:scale];
    glView.autoresizingMask = NSViewNotSizable;
    glView.delegate = self;
    BOOL useRetinaBacking = [[NSUserDefaults standardUserDefaults] boolForKey:@"UseRetinaBacking"];
    [glView setWantsBestResolutionOpenGLSurface:useRetinaBacking];
    [pixelScrollView setDocumentView:glView];

    // Offset can never be greater than file length
    [offsetSlider setMaxValue:[self.doc.pixelBuffer length]];
    
    // Populate pixel format popup
    [formatPopupButton removeAllItems];
    for (NSString *format in [PixelBuffer supportedFormats]) {
        [formatPopupButton addItemWithTitle:format];
    }

    // Populate presets menu
    [self loadResolutionsArray];
    [self populatePresetPopupMenu];

    [fileMD5TextField setStringValue:[self md5hashForFileAtPath:self.doc.filePath]];
    
    
    // Guess pixel format from suffix
    PixelFormat pixFmt = [PixelBuffer pixelFormatForSuffix:[self.doc.filePath pathExtension]];
    if ((NSInteger)pixFmt != -1) {
        self.doc.pixelBuffer.pixelFormat = pixFmt;
        [formatPopupButton selectItemAtIndex:pixFmt];
    } else {
        self.doc.pixelBuffer.pixelFormat = [formatPopupButton indexOfSelectedItem];
        [self loadBestPreset];
    }
    
    // Attach rgba representation of pixel data to gl view
    glView.pixelData = [self.doc.pixelBuffer toRGBA];
    [glView setNeedsDisplay:YES];
    
    [self updateBufferInfoTextField];
    
}


#pragma mark - Control delegate


- (IBAction)pixelFormatChanged:(id)sender {
    self.doc.pixelBuffer.pixelFormat = [formatPopupButton indexOfSelectedItem];
    glView.pixelData = [self.doc.pixelBuffer toRGBA];
    [glView setNeedsDisplay:YES];
    [self updateBufferInfoTextField];
}

- (void)controlTextDidChange:(NSNotification *)notification {

    if ([notification object] == scaleTextField) {
        return;
    }

    int width = [[widthTextField stringValue] intValue];
    int height = [[heightTextField stringValue] intValue];
    int offset = [[offsetTextField stringValue] intValue];

    [widthSlider setIntValue:width];
    [heightSlider setIntValue:height];
    [offsetSlider setIntValue:offset];

    if ([notification object] == offsetTextField) {
        PixlDoc *doc = self.document;
        doc.pixelBuffer.offset = offset;
        glView.pixelData = [doc.pixelBuffer toRGBA];
    }

    glView.frame = NSMakeRect(0, 0, width, height);
    [glView createTexture];
    [glView setNeedsDisplay:YES];
    [self updateBufferInfoTextField];
}

- (void)updateBufferInfoTextField {
    int width = [[widthTextField stringValue] intValue];
    int height = [[heightTextField stringValue] intValue];
    
    PixlDoc *doc = self.document;
    int fileDataLength = [doc.pixelBuffer length];
    int bufferSize = [doc.pixelBuffer expectedBitLengthForImageSize:NSMakeSize(width, height)] / 8;
    
    NSString *bufferInfoString = [NSString stringWithFormat:
                                  @"Data in: %d    Buffer out: %d   Diff: %@%d   ",
                                  fileDataLength,
                                  bufferSize,
                                  fileDataLength-bufferSize > 0 ? @"+" : @"",
                                  fileDataLength-bufferSize
                                  ];
    
    NSString *msg = fileDataLength-bufferSize > 0 ? @"Buffer smaller than source data" : @"Buffer larger than source data";
    NSColor *color = fileDataLength-bufferSize > 0 ? [NSColor orangeColor] : [NSColor redColor];
    if (fileDataLength-bufferSize == 0) {
        msg = @"Buffer size == source data size";
        color = [NSColor greenColor];
    }
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:msg];
    [string addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,string.length)];
    
    
    NSMutableAttributedString *finalStr = [[NSMutableAttributedString alloc] initWithString:bufferInfoString attributes:nil];
    [finalStr appendAttributedString:string];
    
    
    [bufferInfoTextField setAttributedStringValue:finalStr];
}

- (IBAction)scaleToActualSize:(id)sender {
    [scaleSlider setIntValue:100/5];
    [self scaleSliderValueChanged:nil];
}


#pragma mark - Slider actions

- (IBAction)scaleSliderValueChanged:(id)sender {
    int perc = ([scaleSlider intValue] * 5);
    float scale = (float)perc / 100;
    if (glView.scale == scale) {
        return;
    }
    glView.scale = scale;
    [scaleTextField setStringValue:[NSString stringWithFormat:@"%d%%", perc]];

    int width = [[widthTextField stringValue] intValue];
    int height = [[heightTextField stringValue] intValue];
    
    glView.frame = NSMakeRect(0, 0, width, height);
    

    [glView setNeedsDisplay:YES];
}

- (IBAction)widthSliderValueChanged:(id)sender {
    [widthTextField setStringValue:[NSString stringWithFormat:@"%d", [sender intValue]]];
    [self controlTextDidChange:nil];
}

- (IBAction)heightSliderValueChanged:(id)sender {
    [heightTextField setStringValue:[NSString stringWithFormat:@"%d", [sender intValue]]];
    [self controlTextDidChange:nil];
}

- (IBAction)offsetSliderValueChanged:(id)sender {
    [offsetTextField setStringValue:[NSString stringWithFormat:@"%d", [sender intValue]]];
    PixlDoc *doc = self.document;
    doc.pixelBuffer.offset = [sender intValue];
    glView.pixelData = [doc.pixelBuffer toRGBA];
    [glView setNeedsDisplay:YES];
    [self updateBufferInfoTextField];
}

#pragma mark - Menu-based slider control

- (IBAction)decreaseScale:(id)sender {
    [scaleSlider setIntValue:[scaleSlider intValue]-1 < 1 ? 1 : [scaleSlider intValue]-1];
    [self scaleSliderValueChanged:nil];
}

- (IBAction)increaseScale:(id)sender {
    [scaleSlider setIntValue:[scaleSlider intValue]+1];
    [self scaleSliderValueChanged:nil];
}

- (IBAction)decreaseWidth:(id)sender {
    int newWidth = [[widthTextField stringValue] intValue]-1 < 0 ? 0 : [[widthTextField stringValue] intValue]-1;
    [widthTextField setStringValue:[NSString stringWithFormat:@"%d", newWidth]];
    [self controlTextDidChange:nil];
}

- (IBAction)increaseWidth:(id)sender {
    [widthTextField setStringValue:[NSString stringWithFormat:@"%d", [[widthTextField stringValue] intValue]+1]];
    [self controlTextDidChange:nil];
}

- (IBAction)decreaseHeight:(id)sender {
    int newHeight = [[heightTextField stringValue] intValue]-1 < 0 ? 0 : [[heightTextField stringValue] intValue]-1;
    [heightTextField setStringValue:[NSString stringWithFormat:@"%d", newHeight]];
    [self controlTextDidChange:nil];
}

- (IBAction)increaseHeight:(id)sender {
    [heightTextField setStringValue:[NSString stringWithFormat:@"%d", [[heightTextField stringValue] intValue]+1]];
    [self controlTextDidChange:nil];

}

#pragma mark - Presets

- (IBAction)bestFitButtonPressed:(id)sender {
    
    
    if (presetIndex == -1) {
        if ([self loadBestPreset] == NO) {
            NSBeep();
            return;
        }
    }
    NSArray *matches = [self matchingResolutionPresets];
    if (presetIndex >= [matches count]-1 || presetIndex == -1) {
        presetIndex = 0;
    } else {
        presetIndex++;
    }
    [self loadPreset:[matches objectAtIndex:presetIndex]];
    
}

- (BOOL)loadBestPreset {
    NSDictionary *res = [self bestPreset];
    if (res != nil) {
        int index = (int)[resolutions indexOfObject:res];
        [self loadPreset:[resolutions objectAtIndex:index]];
        return YES;
    }
    return NO;
}

- (IBAction)presetSelected:(id)sender {
    int index = (int)[presetPopupButton indexOfSelectedItem];
    [self loadPreset:[resolutions objectAtIndex:index]];
}

- (NSDictionary *)bestPreset {
    NSArray *matches = [self matchingResolutionPresets];
    //PixelFormat fmt = [PixelBuffer pixelFormatForSuffix:[self.doc.filePath pathExtension]];
    
    if ([matches count]) {
        return [matches objectAtIndex:0];
    }
    return nil;
}

- (void)loadPreset:(NSDictionary *)res {
    int w = [[res objectForKey:@"width"] intValue];
    int h = [[res objectForKey:@"height"] intValue];
    PixelFormat pixFmt = [self pixelFormatMatchingResolution:res];
    
    [widthTextField setStringValue:[NSString stringWithFormat:@"%d", w]];
    [heightTextField setStringValue:[NSString stringWithFormat:@"%d", h]];
    
    if ((NSUInteger)pixFmt != -1) {
        [formatPopupButton selectItemAtIndex:pixFmt];
        [self pixelFormatChanged:nil];
    }
    
    [self controlTextDidChange:nil];
    
    [presetPopupButton selectItemAtIndex:[resolutions indexOfObject:res]];
}

#pragma mark - GLPixelViewDelegate

- (void)glPixelViewDoubleClicked:(NSEvent *)event {
    [self scaleToActualSize:self];
}


#pragma mark - File

- (IBAction)export:(id)sender {
    
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

    NSString *outputStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *md5string = [[outputStr componentsSeparatedByString:@" = "] objectAtIndex:1];
    return [NSString stringWithFormat:@"MD5: %@", md5string];
}

#pragma mark - Resolution presets

- (void)populatePresetPopupMenu {

    [presetPopupButton removeAllItems];

    for (NSDictionary *res in resolutions) {
        int w = [[res objectForKey:@"width"] intValue];
        int h = [[res objectForKey:@"height"] intValue];

        NSString *presetName = [NSString stringWithFormat:@"%d x %d", w, h];
        [presetPopupButton addItemWithTitle:presetName];
    }



    NSArray *menuItems = [presetPopupButton itemArray];
    for (NSMenuItem *menuItem in menuItems) {

        int index = (int)[presetPopupButton indexOfItem:menuItem];
        NSDictionary *resInfoDict = [resolutions objectAtIndex:index];

        NSColor *resColor = [NSColor clearColor];
        NSString *title = menuItem.title;
        NSFont *font = [NSFont systemFontOfSize:[NSFont systemFontSize]];

        
        // Check if match
        PixelFormat pixFmt = [self pixelFormatMatchingResolution:resInfoDict];
        if ((NSUInteger)pixFmt != -1) {
            resColor = [NSColor greenColor];
            NSString *pixFmtStr = [[PixelBuffer supportedFormats] objectAtIndex:pixFmt];
            title = [NSString stringWithFormat:@"%@ (%@)", menuItem.title, pixFmtStr];
            font = [NSFont boldSystemFontOfSize: [NSFont systemFontSize]];
        }
        
        NSDictionary *textAttr = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  resColor, NSBackgroundColorAttributeName,
                                  font, NSFontAttributeName, nil];


        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:textAttr];

        [menuItem setAttributedTitle:attrTitle];
    }
}

- (PixelFormat)pixelFormatMatchingResolution:(NSDictionary *)resInfoDict {
    int pixelCount = [[resInfoDict objectForKey:@"pixels"] intValue];

    if (pixelCount * 4 == self.doc.pixelBuffer.length) {
        return PIXEL_FORMAT_RGBA;
    } else if (pixelCount * 3 == self.doc.pixelBuffer.length) {
        return PIXEL_FORMAT_RGB24;
    } else if (pixelCount * 1 == self.doc.pixelBuffer.length) {
        return PIXEL_FORMAT_RGB8;
    }
    return -1;
}

- (NSArray *)matchingResolutionPresets {
    NSMutableArray *matches = [NSMutableArray array];
    if (self.doc.pixelBuffer.data == nil || [self.doc.pixelBuffer.data length] == 0) {
        return matches;
    }

    for (NSDictionary *res in resolutions) {
//        int w = [[res objectForKey:@"width"] intValue];
//        int h = [[res objectForKey:@"height"] intValue];
        int pixCount = [[res objectForKey:@"pixels"] intValue];
        int docDataLength = (int)[self.doc.pixelBuffer.data length];
        BOOL match = NO;
        if (pixCount * 4 == docDataLength) {
            match = YES;
        } else if (pixCount * 3 == docDataLength) {
            match = YES;
        } else if (pixCount * 1 == docDataLength) {
            match = YES;
        }
        if (match) {
            [matches addObject:res];
        }
    }
    return matches;
}

//- (BOOL)guessResolution:(NSSize *)outSize pixelFormat:(PixelFormat *)format {
//    NSString *resFilePath = [[NSBundle mainBundle] pathForResource:@"resolutions" ofType:@"plist"];
//    NSArray *resolutions = [NSArray arrayWithContentsOfFile:resFilePath];
//
//    for (NSDictionary *res in resolutions) {
//        int w = [[res objectForKey:@"width"] intValue];
//        int h = [[res objectForKey:@"height"] intValue];
//        int pixCount = [[res objectForKey:@"pixels"] intValue];
//
//                if (pixCount * 4 == self.data.length) {
//                    *format = PIXEL_FORMAT_RGBA;
//                } else if (pixCount * 3 == self.data.length) {
//                    *format = PIXEL_FORMAT_RGB24;
//                } else if (pixCount * 1 == self.data.length) {
//                    *format = PIXEL_FORMAT_RGB8;
//                } else {
//                    continue;
//                }
//
//        //        NSString *fmtName = [[PixelBuffer supportedFormats] objectAtIndex:*format];
//        //        NSLog(@"Data length %d matches %d x %d format: %@", self.data.length, w, h, fmtName);
//
//    }
//
//    return TRUE;
//}

- (void)loadResolutionsArray {
    NSString *resFilePath = [[NSBundle mainBundle] pathForResource:@"resolutions" ofType:@"plist"];
    resolutions = [NSArray arrayWithContentsOfFile:resFilePath];
}


@end
