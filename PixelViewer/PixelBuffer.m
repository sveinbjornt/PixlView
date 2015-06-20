//
//  PixelBuffer.m
//  PixelViewer
//
//  Created by Sveinbjorn Thordarson on 20/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import "PixelBuffer.h"

#define CASE(str)                       if ([__s__ isEqualToString:(str)])
#define SWITCH(s)                       for (NSString *__s__ = (s); ; )
#define DEFAULT

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

- (const void *)bytes {
    return [self.data bytes];
}

+ (NSArray *)supportedFormats {
    return [NSArray arrayWithObjects:nil];
}

- (unsigned char *)rgba
{
//SWITCH (string) {
//    CASE (@"AAA") {
//        break;
//    }
//    CASE (@"BBB") {
//        break;
//    }
//    CASE (@"CCC") {
//        break;
//    }
//    DEFAULT {
//        break;
//    }
//}
    return nil;
}

@end
