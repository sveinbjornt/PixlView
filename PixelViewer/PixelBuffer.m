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

#pragma mark - Info

- (unsigned char *)bytes {
    return (unsigned char *)([self.data bytes] + self.offset);
}

- (int)length {
    return (int)self.data.length - self.offset;
}

+ (NSArray *)supportedFormats {
    return [NSArray arrayWithObjects:@"RGBA",
                                     @"RGB24",
                                     @"RGB8",
                                     //@"YUV420p",
                                    nil];
}

#pragma mark - Pixel format conversion routines

- (NSData *)rgb24_2_rgba {

    unsigned char *rgbBuffer = (unsigned char *)[self bytes];
    int rgbBufferLength = (int)[self length];
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
    
    unsigned char *rgb8Buffer = (unsigned char *)[self bytes];
    int rgb8BufferLength = (int)[self length];
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
    NSString *fmtName = [[PixelBuffer supportedFormats] objectAtIndex:(int)self.pixelFormat];
    NSLog(@"Converting format %@ to RGBA", fmtName);

    switch (self.pixelFormat) {
            
        case PIXEL_FORMAT_RGBA:
            NSLog(@"Data length %d", [self length]);
            return [NSData dataWithBytes:[self bytes] length:[self length]];
            break;
        case PIXEL_FORMAT_RGB24:
            return [self rgb24_2_rgba];
            break;
        case PIXEL_FORMAT_RGB8:
            return [self rgb8_2_rgba];
            break;
        case PIXEL_FORMAT_YUV420P:
            break;
    }
    
    return nil;
}

- (int)expectedBitLengthForImageSize:(NSSize)size
{
    int bpp = 32;
    
    switch (self.pixelFormat) {
            
        case PIXEL_FORMAT_RGBA:
            bpp = 32;
            break;
        case PIXEL_FORMAT_RGB24:
            bpp = 24;
            break;
        case PIXEL_FORMAT_RGB8:
            bpp = 8;
            break;
        case PIXEL_FORMAT_YUV420P:
            bpp = 12;
            break;
    }
    return size.width * size.height * bpp;
}


@end
