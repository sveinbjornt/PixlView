//
//  PixelGLView.m
//  PixelViewer
//
//  Created by Sveinbjorn Thordarson on 20/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import "GLPixelView.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

@implementation GLPixelView

- (instancetype)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat *)format scale:(CGFloat)scale {
    
    frameRect.size.width = frameRect.size.width * scale ;
    frameRect.size.height = frameRect.size.height * scale;
    if ((self = [super initWithFrame:frameRect pixelFormat:format])) {
        self.scale = scale;
    }
    return self;
}

- (void)prepareOpenGL {
    glClearColor(0, 0, 0, 0);
    glDisable(GL_POINT_SMOOTH);
    glHint(GL_POINT_SMOOTH_HINT, GL_FASTEST);
    glEnable(GL_BLEND);
    [self createTexture];
}

#pragma mark -

- (void *)readGLBuffer {
    [[self openGLContext] makeCurrentContext];
    
    void *buf = malloc(self.frame.size.width * self.frame.size.height * 4);
    glReadPixels(0, 0, self.frame.size.width, self.frame.size.height, GL_RGBA, GL_UNSIGNED_BYTE, buf);
    
    return buf;
}

- (void)setPixelData:(NSData *)pixelData {
    _pixelData = pixelData;
    [self createTexture];
}

- (void)setFrame:(NSRect)frameRect {
    frameRect.size.width = frameRect.size.width * self.scale;
    frameRect.size.height = frameRect.size.height * self.scale;
    [super setFrame:frameRect];
}

#pragma mark -

- (void)reshape {
//    [[self openGLContext] makeCurrentContext];
//    [[self openGLContext] update];

//    [[self openGLContext] makeCurrentContext];
//    
//    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
//    
//    glMatrixMode(GL_PROJECTION);
//    glLoadIdentity();
//    
//    // Use OS X style coordinates, 0,0 is bottom left
//    glOrtho(0, self.frame.size.width, self.frame.size.height, 0 , 0, 1);
//    
//    glMatrixMode(GL_MODELVIEW);
//    glLoadIdentity();
}

- (void)refresh {
    [self drawRect:[self bounds]];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [[self openGLContext] makeCurrentContext];
    [super drawRect:dirtyRect];
    
    NSRect backingFrameRect = [self bounds];
    if (self.wantsBestResolutionOpenGLSurface) {
        backingFrameRect = [self convertRectToBacking:[self bounds]];
    }
    
    int maxSize;
    glGetIntegerv(GL_MAX_VIEWPORT_DIMS, &maxSize);
    
    int vpw = backingFrameRect.size.width > maxSize ? maxSize : backingFrameRect.size.width;
    int vph = backingFrameRect.size.height > maxSize ? maxSize : backingFrameRect.size.height;
    
    glViewport(0, 0, vpw, vph);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    // x=0,y=0 is top left
    glOrtho(0, self.frame.size.width, self.frame.size.height, 0 , 0, 1);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    NSColor *color = [NSColor redColor];
    id colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"BufferOverflowColor"];
    if (colorData) {
        color = [NSUnarchiver unarchiveObjectWithData:colorData];
    }
    glClearColor(color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Draw texture
    if (texture) {
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, texture);
        
        int x1 = 0;
        int y1 = 0;
        
        int x2 = self.frame.size.width;
        int y2 = self.frame.size.height;
        
        glBegin(GL_QUADS);
        
        glTexCoord2f(0.0f,1.0f);
        glVertex2f(x1,y2);
        
        glTexCoord2f(0.0f,0.0f);
        glVertex2f(x1,y1);
        
        glTexCoord2f(1.0f,0.0f);
        glVertex2f(x2,y1);
        
        glTexCoord2f(1.0f,1.0f);
        glVertex2f(x2,y2);
        
        glEnd();
    }

    [[self openGLContext] flushBuffer];
}

- (void)createTexture {
    [[self openGLContext] makeCurrentContext];
    
    // delete previous texture
    if (texture) {
        glDeleteTextures(1, &texture);
    }
    
    // Create the texture we're going to render to
    glGenTextures(1, &texture);
    if (!texture) {
        NSLog(@"Failed to create texture");
        return;
    }
    glBindTexture(GL_TEXTURE_2D, texture);
    
    int w = self.frame.size.width/self.scale;
    int h = self.frame.size.height/self.scale;
    
    int bufLength = w * h * 4;
    unsigned char *buf = malloc(bufLength);
    if (self.pixelData.length >= bufLength) {
        memcpy(buf, self.pixelData.bytes, bufLength);
    } else {
        
        NSColor *color = [NSColor blackColor];
        id archivedColor = [[NSUserDefaults standardUserDefaults] objectForKey:@"BackgroundColor"];
        if (archivedColor) {
            color = [NSUnarchiver unarchiveObjectWithData:archivedColor];
        }
        unsigned char val[4];
        val[0] = color.redComponent * 255;
        val[1] = color.greenComponent * 255;
        val[2] = color.blueComponent * 255;
        val[3] = color.alphaComponent * 255;
        
        memset_pattern4(buf, &val, bufLength);
        memcpy(buf, self.pixelData.bytes, self.pixelData.length);
    }
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0,GL_RGBA, GL_UNSIGNED_BYTE, buf);
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseAntialiasing"]) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    } else {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    }
    
    free(buf);
    
    NSLog(@"Created texture %.1f x %.1f", self.frame.size.width, self.frame.size.height);

    
}

#pragma mark - Event handling

- (void)mouseUp:(NSEvent*)event
{
    if (!self.delegate) {
        return;
    }
    
    NSInteger clickCount = [event clickCount];
    if (2 == clickCount) {
        [self.delegate glPixelViewDoubleClicked:event];
    } else {
        [self.delegate glPixelViewClicked:event];
    }
}


#pragma mark -

-(BOOL)isFlipped
{
    return YES;
}


@end
