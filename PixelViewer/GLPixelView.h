//
//  PixelGLView.h
//  PixelViewer
//
//  Created by Sveinbjorn Thordarson on 20/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GLPixelView : NSOpenGLView
{
    
}
@property (retain, atomic) NSData *pixelData;
@property CGFloat scale;

- (void)refresh;
@end
