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

- (void)prepareOpenGL {
    glClearColor(0, 0, 0, 0);
    glDisable(GL_POINT_SMOOTH);
    glHint(GL_POINT_SMOOTH_HINT, GL_FASTEST);
    glEnable(GL_BLEND);
    glPointSize(1.0f);

    return;
}


- (void)reshape {
//    [[self openGLContext] update];

    [[self openGLContext] makeCurrentContext];
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    // Use OS X style coordinates, 0,0 is bottom left
    glOrtho(0, self.frame.size.width, self.frame.size.height, 0 , 0, 1);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();


}

- (void)refresh {
    [self drawRect:[self bounds]];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[self openGLContext] makeCurrentContext];
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    // Use OS X style coordinates, 0,0 is bottom left
    glOrtho(0, self.frame.size.width, self.frame.size.height, 0 , 0, 1);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self drawPixelData];
    
    [[self openGLContext] flushBuffer];
}

- (void)drawPixelData {
    
    NSData *data = self.pixelData;
    if (!data) {
        NSLog(@"No pixel data available");
        return;
    }
    
    unsigned char *bytes = (unsigned char *)[data bytes];
    int length = (int)[data length];
    int width = self.frame.size.width;
    int height = self.frame.size.height;
    int stride = width * 4;
    
    // iterate over rgba buffer
    for (int y = 0; y < height; y++) {
        
        for (int x = 0; x < width; x++) {
            
            int pos = (y * stride) + (x * 3);
            if (pos < length-3) {
                
                // read 4 components
                unsigned char r = bytes[pos];
                unsigned char g = bytes[pos+1];
                unsigned char b = bytes[pos+2];
                unsigned char a = bytes[pos+3];
                
                float rf = (float)r / 255;
                float gf = (float)g / 255;
                float bf = (float)b / 255;
                float af = (float)a / 255;
                
                glColor4f(rf,gf,bf,af);
                
            } else {
                glColor4f(1,1,1,1);
            }

            // Draw point
            glBegin(GL_POINTS);
            glVertex2f(x, y);
            glEnd();
        }

        
        
    }
    
}





















@end
