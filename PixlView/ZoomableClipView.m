//
//  ZoomableScrollView.m
//  PixlView
//
//  Created by Sveinbjorn Thordarson on 23/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import "ZoomableClipView.h"

@implementation ZoomableClipView


-(void)resetCursorRects
{
    NSImage *image = [NSImage imageNamed:@"small-zoom-in-cursor.png"];

    unsigned int currentFlags = [[[NSApplication sharedApplication] currentEvent] modifierFlags];
    
    if (currentFlags & NSShiftKeyMask) {
        image = [NSImage imageNamed:@"small-zoom-cursor.png"];
    }

    NSCursor *cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSZeroPoint];
    
    [self addCursorRect:[self bounds] cursor:cursor];
}

- (void)flagsChanged:(NSEvent *)theEvent {
    if (([theEvent modifierFlags] & NSShiftKeyMask) == NSAlternateKeyMask) {
        [self.window resetCursorRects];
    }
}

- (BOOL)acceptsFirstResponder {
    return TRUE;
}


@end
