//
//  Document.h
//  documentsTest
//
//  Created by Sveinbjorn Thordarson on 21/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PixelDocumentController.h"
#import "PixelBuffer.h"

@class PixelDocumentController;
@interface PixelDocument : NSDocument
{
    
}
@property (retain, nonatomic) PixelDocumentController *controller;
@property (retain, nonatomic) PixelBuffer *pixelBuffer;
@property (retain, nonatomic) NSString *filePath;
@end

