//
//  PixelBuffer.h
//  PixelViewer
//
//  Created by Sveinbjorn Thordarson on 20/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PIXEL_FORMAT_RGBA,
    PIXEL_FORMAT_RGB24,
    PIXEL_FORMAT_RGB8,
    PIXEL_FORMAT_YUV420P
} PixelFormat;

@interface PixelBuffer : NSObject
{
    
}
@property (retain, nonatomic) NSData *data;
@property PixelFormat pixelFormat;
@property int offset;

- (instancetype)initWithContentsOfFile:(NSString *)path;
- (instancetype)initWithData:(NSData *)d;
- (void)readResolutions;
- (unsigned char *)bytes;
- (int)length;
+ (NSArray *)supportedFormats;
- (NSData *)toRGBA;
- (int)expectedBitLengthForImageSize:(NSSize)size;
- (BOOL)guessResolution:(NSSize *)outSize pixelFormat:(PixelFormat *)format;
@end
