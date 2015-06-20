//
//  CGPixelView.m
//  PixelViewer
//
//  Created by Sveinbjorn Thordarson on 20/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import "CGPixelView.h"

@implementation CGPixelView

- (CGContextRef) currentContext {
    return [NSGraphicsContext.currentContext graphicsPort];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    CGContextRef context = self.currentContext;
    
    // Set the background and border size attributes.
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0); // Black
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0); // White
    CGContextSetLineWidth(context, 1.0);
    
    
}





@end
