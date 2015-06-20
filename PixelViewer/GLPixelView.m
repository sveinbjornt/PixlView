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
#import "PixelFormat.h"



@implementation GLPixelView

- (void)prepareOpenGL {
    glClearColor(0, 0, 0, 0);
    glDisable(GL_POINT_SMOOTH);
    glHint(GL_POINT_SMOOTH_HINT, GL_FASTEST);
    glEnable(GL_BLEND);
    

    return;
}


- (void)reshape {
//    [[self openGLContext] update];

    [[self openGLContext] makeCurrentContext];
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    //extern void glOrtho (GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar);
    
    
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
    
    //extern void glOrtho (GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar);

    
    // Use OS X style coordinates, 0,0 is bottom left
    glOrtho(0, self.frame.size.width, self.frame.size.height, 0 , 0, 1);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    glColor3f(1, .85, .35);
    glBegin(GL_TRIANGLES);
//    glVertex2f(0, 0.6);
//    glVertex2f(-0.2, -0.30);
//    glVertex2f(.2, -.3);
    glVertex2f(100, 100);
    glVertex2f(200, 200);
    glVertex2f(100, 200);

    glEnd();
    
    
    [self drawPixelData:nil];
    
    
    
    
    glFlush();
    
    [[self openGLContext] flushBuffer];
}

- (void)drawPixelData:(unsigned char *)pixelDataPtr {
    
    
//    int len = 640*480*3;
//    void *d = malloc(len);
//    memset(d, 100, len);
//    NSData *rgbData = [NSData dataWithBytes:d length:len];
//    [rgbData writeToFile:@"/Users/sveinbjorn/Desktop/data.rgb" atomically:YES];

    
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/sveinbjorn/Desktop/kisi.data"];
    unsigned char *bytes = [data bytes];
    int length = [data length];
    int width = self.frame.size.width;
    int height = self.frame.size.height;
    int stride = width * 3;
    
    
    
    for (int y = 0; y < height; y++) {
        
        for (int x = 0; x < width; x++) {
            
            int pos = (y * stride) + (x * 3);
            if (pos < length-2) {
                
                unsigned char r = bytes[pos];
                unsigned char g = bytes[pos+1];
                unsigned char b = bytes[pos+2];
                
                float rf = (float)r / 255;
                float gf = (float)g / 255;
                float bf = (float)b / 255;
                
                glColor4f(rf,gf,bf, 0.0);
                
            } else {
                glColor4f(1,1,1,0.5);
            }

            
            
            glPointSize(1.0f);
            glBegin(GL_POINTS);
            glVertex2f(x, y);
            glEnd();
        }

        
        
    }
    
}





















@end
