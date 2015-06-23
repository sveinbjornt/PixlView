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

- (void)setPixelData:(NSData *)pixelData {
    _pixelData = pixelData;
    [self createTexture];
}

- (void)setFrame:(NSRect)frameRect {
    frameRect.size.width = frameRect.size.width * self.scale;
    frameRect.size.height = frameRect.size.height * self.scale;
    [super setFrame:frameRect];
    //[self createTexture];
}

#pragma mark -

- (void)reshape {
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
    
    if (self.pixelData == nil) {
        return;
    }
    
    
    NSRect backingFrameRect = [self bounds];
    if (self.wantsBestResolutionOpenGLSurface) {
        backingFrameRect = [self convertRectToBacking:[self bounds]];
    }
    
    int maxSize;
    glGetIntegerv(GL_MAX_VIEWPORT_DIMS, &maxSize);
    
    int vpw = backingFrameRect.size.width > maxSize ? maxSize : backingFrameRect.size.width;
    int vph = backingFrameRect.size.height > maxSize ? maxSize : backingFrameRect.size.height;
    
    glViewport(0, 0, vpw, vph);
//    NSLog(NSStringFromRect(self.bounds));
//    NSLog(NSStringFromRect(backingFrameRect));
    
    
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

//    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
//    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
//    glOrtho(0, self.frame.size.width, self.frame.size.height, 0 , 0, 1);

//    GLenum DrawBuffers[1] = {GL_COLOR_ATTACHMENT0};
//    glDrawBuffers(1, DrawBuffers);
    
    
    
    
    
    
//    [self drawPixelData];
    
//    int dataLength = self.frame.size.width * self.frame.size.height * 4;
//    unsigned char *buf = malloc(dataLength);
////    glReadPixels(0, 0, self.frame.size.width, self.frame.size.height, GL_RGBA, GL_UNSIGNED_BYTE, buf);
//    glGetTexImage(GL_TEXTURE_2D, 0, GL_RGB, GL_UNSIGNED_BYTE, buf);
//    [[NSData dataWithBytes:buf length:dataLength] writeToFile:@"/Users/sveinbjorn/Desktop/tex.data" atomically:NO];
    
    
//    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    
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
    
    if (texture) {
        glDeleteTextures(1, &texture);
    }
    
    // The texture we're going to render to
    glGenTextures(1, &texture);
    if (!texture) {
        NSLog(@"Failed to create texture");
        return;
    }
    glBindTexture(GL_TEXTURE_2D, texture);
    
    int w = self.frame.size.width/self.scale;
    int h = self.frame.size.height/self.scale;
    
    // Give an empty image to OpenGL
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
        
        memset_pattern4(buf, &val,bufLength);
        
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
    
    [[NSData dataWithBytes:buf length:bufLength] writeToFile:@"/Users/sveinbjorn/Desktop/tex.data" atomically:NO];
    free(buf);
    
    NSLog(@"Created texture %.1f x %.1f", self.frame.size.width, self.frame.size.height);

    
}

//- (void)drawPixelData {
//    
//    if (!self.pixelData) {
//        NSLog(@"No pixel data available");
//        return;
//    }
//    
//    unsigned char *bytes = (unsigned char *)[self.pixelData bytes];
//    int length = (int)[self.pixelData length];
//    int width = self.frame.size.width;
//    int height = self.frame.size.height;
//    int stride = width * 4;
//    
//    glPointSize(1.0f);
//    
//    // iterate over rgba buffer
//    for (int y = 0; y < height; y++) {
//        
//        for (int x = 0; x < width; x++) {
//            
//            int pos = (y * stride) + (x * 4);
//            if (pos < length-3) {
//                
//                // read 4 components
//                float rf = (float)bytes[pos] / 255;
//                float gf = (float)bytes[pos+1] / 255;
//                float bf = (float)bytes[pos+2] / 255;
//                float af = (float)bytes[pos+3] / 255;
//                
//                glColor4f(rf,gf,bf,af);
//                
//            } else {
//                glColor4f(1,1,1,1);
//            }
//
//            // Draw point
//            glBegin(GL_POINTS);
//            glVertex2f(x, y);
//            glEnd();
//        }
//    }
//}

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
