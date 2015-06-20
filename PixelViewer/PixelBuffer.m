//
//  PixelBuffer.m
//  PixelViewer
//
//  Created by Sveinbjorn Thordarson on 20/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import "PixelBuffer.h"

@implementation PixelBuffer

- (instancetype)initWithContentsOfFile:(NSString *)path {
    
    NSData *d = [NSData dataWithContentsOfFile:path];
    return [self initWithData:d];
}

- (instancetype)initWithData:(NSData *)d {
    if ((self = [super init])) {
        self.data = d;
    }
    return self;
}

- (unsigned char *)bytes {
    return (unsigned char *)[self.data bytes];
}

+ (NSArray *)supportedFormats {
    return [NSArray arrayWithObjects:nil];
}

- (unsigned char *)rgb24_2_rgba {
    
    unsigned char *rgb24buffer = (unsigned char *)[self.data bytes];
    int rgb24bufferLength = (int)[self.data length];
    
    int rgbaBufferLength = [self.data length] * 1.25;
    unsigned char *rgbaBuffer = malloc(rgbaBufferLength);
    
    int rgbaIndex = 0;
    
    for (int i = 0; i < rgb24bufferLength; i++) {
        rgbaBuffer[rgbaIndex] = rgb24buffer[i];
        rgbaIndex++;

        if (i % 3 == 0 && i != 0) {
            rgbaBuffer[rgbaIndex] = 255;
            rgbaIndex++;
        }
    }
    
    return rgbaBuffer;
}

- (unsigned char *)rgb8_2_rgba  {
    unsigned char *rgbaDataPtr;
    return rgbaDataPtr;
}

- (unsigned char *)yuv420p_2_rgba  {
    unsigned char *rgbaDataPtr;
    return rgbaDataPtr;
}

- (NSData *)toRGBA
{
    
    
    return nil;
}

@end
