//
//  AppDelegate.h
//  PixelViewer
//
//  Created by Sveinbjorn Thordarson on 19/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GLPixelView.h"
#import "PixelBuffer.h"

#define PIXEL_FORMATS [NSArray arrayWithObjects: @"RGBPixelFormat", nil]

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate>
{
    IBOutlet id mainWindow;
    
    IBOutlet NSImageView *fileIconImageView;
    IBOutlet id filePathTextField;
    IBOutlet id fileMD5TextField;
    
    IBOutlet id formatPopupButton;
    IBOutlet id widthTextField;
    IBOutlet id heightTextField;
    IBOutlet id offsetTextField;

    IBOutlet id pixelScrollView;
    
    GLPixelView *glView;
    PixelBuffer *pixelBuffer;
}

@end

