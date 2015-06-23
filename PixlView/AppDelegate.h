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
    
}

@end

