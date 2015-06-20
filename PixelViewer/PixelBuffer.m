//
//  PixelBuffer.m
//  PixelViewer
//
//  Created by Sveinbjorn Thordarson on 20/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import "PixelBuffer.h"

void simple_unpack(char* rgba, const char* rgb, const int count) {
    for(int i=0; i<count; ++i) {
        for(int j=0; j<3; ++j) {
            rgba[j] = rgb[j];
        }
        rgba += 4;
        rgb  += 3;
    }
}



@implementation PixelBuffer

- (instancetype)initWithContentsOfFile:(NSString *)path {
    
    NSData *d = [NSData dataWithContentsOfFile:path];
    return [self initWithData:d];
}

- (instancetype)initWithData:(NSData *)d {
    if ((self = [super init])) {
        self.data = d;
        NSLog(@"Pixel buffer inited with data length %d", self.data.length);
    }
    return self;
}

- (unsigned char *)bytes {
    return (unsigned char *)[self.data bytes];
}

+ (NSArray *)supportedFormats {
    return [NSArray arrayWithObjects:nil];
}

- (NSData *)rgb24_2_rgba {
    

    
    unsigned char *rgbBuffer = (unsigned char *)[self.data bytes];
    int rgbBufferLength = (int)[self.data length];
    int pixelCount = rgbBufferLength/3;
    
    int rgbaBufferLength = pixelCount * 4;
    unsigned char *rgbaBuffer = malloc(rgbaBufferLength);
    
    int rgbaIndex = 0;
    int rgbIndex = 0;
    for (int i = 0; i < pixelCount; i++) {
        rgbaBuffer[rgbaIndex] = rgbBuffer[rgbIndex];
        rgbaBuffer[rgbaIndex+1] = rgbBuffer[rgbIndex+1];
        rgbaBuffer[rgbaIndex+2] = rgbBuffer[rgbIndex+2];
        rgbaBuffer[rgbaIndex+3] = 1;

        rgbaIndex += 4;
        rgbIndex += 3;
    }
    
    
    return [NSData dataWithBytes:rgbaBuffer length:rgbaBufferLength];
}

- (NSData *)rgb8_2_rgba  {
    unsigned char *rgb8Buffer = (unsigned char *)[self.data bytes];
    int rgb8BufferLength = (int)[self.data length];
    int pixelCount = rgb8BufferLength;
    
    int rgbaBufferLength = pixelCount * 4;
    unsigned char *rgbaBuffer = malloc(rgbaBufferLength);
    
    int rgbaIndex = 0;
    int rgb8Index = 0;
    for (int i = 0; i < pixelCount; i++) {
        rgbaBuffer[rgbaIndex] = rgb8Buffer[rgb8Index];
        rgbaBuffer[rgbaIndex+1] = rgb8Buffer[rgb8Index];
        rgbaBuffer[rgbaIndex+2] = rgb8Buffer[rgb8Index];
        rgbaBuffer[rgbaIndex+3] = 1;
        
        rgbaIndex += 4;
        rgb8Index += 1;
    }
    
    
    return [NSData dataWithBytes:rgbaBuffer length:rgbaBufferLength];

}

- (unsigned char *)yuv420p_2_rgba  {
    unsigned char *rgbaDataPtr;
    return rgbaDataPtr;
}

- (int)expectedBytesForImageSize:(NSSize)size
{
    int bytesPerPixel = 32;
    
    switch (self.pixelFormat) {
            
        case PIXEL_FORMAT_RGBA:
            bytesPerPixel = 32;
            break;
        case PIXEL_FORMAT_RGB24:
            bytesPerPixel = 24;
            break;
        case PIXEL_FORMAT_RGB8:
            bytesPerPixel = 8;
            break;
        case PIXEL_FORMAT_YUV420P:
            bytesPerPixel = 12;
            break;
    }
    return size.width * size.height * bytesPerPixel;
}

- (NSData *)toRGBA
{
    NSData *d = self.data;
    NSLog(@"Converting format %d to RGBA", self.pixelFormat);

    NSLog(@"Data length before conversion: %d", d.length);
    switch (self.pixelFormat) {
            
        case PIXEL_FORMAT_RGBA:
            break;
        case PIXEL_FORMAT_RGB24:
            d = [self rgb24_2_rgba];
            break;
        case PIXEL_FORMAT_RGB8:
            d = [self rgb8_2_rgba];
            break;
        case PIXEL_FORMAT_YUV420P:
            break;
    }
    NSLog(@"Data length after conversion: %d", d.length);
    return d;
}

@end
