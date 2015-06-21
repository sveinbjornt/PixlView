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
        NSLog(@"Pixel buffer inited with data length %lu", self.data.length);
    }
    return self;
}

- (unsigned char *)bytes {
    return (unsigned char *)[self.data bytes];
}

+ (NSArray *)supportedFormats {
    return [NSArray arrayWithObjects:@"RGBA",
                                     @"RGB24",
                                     @"RGB8",
                                     @"YUV420p",
                                    nil];
}

#pragma mark - Pixel format conversion routines

- (NSData *)rgb24_2_rgba {

    unsigned char *rgbBuffer = (unsigned char *)[self.data bytes];
    int rgbBufferLength = (int)[self.data length];
    int pixelCount = rgbBufferLength/3;
    
    if (pixelCount == 0 || rgbBufferLength < 3) {
        NSLog(@"Aborted conversion of rgb24 buffer length %d", rgbBufferLength);
        return nil;
    }
    
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

//    void *src = (void *)[self.data bytes];
//    
//    void *dst =
//    , void *dst, int width, int height
//    
//    unsigned char y, u,v;
//    char *rgb = dst;
//    
//    int pixelcount = width * height;
//    unsigned char *yptr = src;
//    unsigned char *uptr = src + pixelcount;
//    unsigned char *vptr = src + pixelcount + (pixelcount/4);
//    
//    int linesize[3];
//    linesize[0] = width;
//    linesize[1] = width / 2;
//    linesize[2] = width / 2;
//    
//    int i =0;
//    
//    for (int py = 0; py < height; py++)
//    {
//        for (int px = 0; px < width; px++, i+= 3)
//        {
//            y = yptr[py * linesize[0] + px];
//            u = uptr[py/2 * linesize[1] + px/2];
//            v = vptr[py/2 * linesize[2] + px/2];
//            
//            rgb[ i ] = y + 1.402 * (v-128);
//            rgb[ i + 1 ] = y - 0.34414 * (u-128) - 0.71414 * (v-128);
//            rgb[ i + 2] = y + 1.772 * (u-128);
//        }
//    }
    
    return 0;

}

- (NSData *)toRGBA
{
    NSData *d = self.data;
    NSString *fmtName = [[PixelBuffer supportedFormats] objectAtIndex:(int)self.pixelFormat];
    NSLog(@"Converting format %@ to RGBA", fmtName);

    NSLog(@"Data length before conversion: %d", (int)d.length);
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
    NSLog(@"Data length after conversion: %d", (int)d.length);
    return d;
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

@end
