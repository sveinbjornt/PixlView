//
//  PixelGLView.h
//  PixelViewer
//
//  Created by Sveinbjorn Thordarson on 20/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol GLPixelViewDelegate <NSObject>
- (void)glPixelViewDoubleClicked:(NSEvent *)event;
- (void)glPixelViewClicked:(NSEvent *)event;
@end

@interface GLPixelView : NSOpenGLView
{
    GLuint framebuffer;
    GLuint texture;
}
@property (retain, nonatomic) NSData *pixelData;
@property CGFloat scale;
@property id delegate;

- (instancetype)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format scale:(CGFloat)scale;
- (void)refresh;
- (void)createTexture;

@end
