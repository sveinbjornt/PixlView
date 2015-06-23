//
//  Document.h
//  documentsTest
//
//  Created by Sveinbjorn Thordarson on 21/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PixlDocWindowController.h"
#import "PixelBuffer.h"

@class PixlDocWindowController;
@interface PixlDoc : NSDocument
{
    
}
@property (retain, nonatomic) PixlDocWindowController *controller;
@property (retain, nonatomic) PixelBuffer *pixelBuffer;
@property (retain, nonatomic) NSString *filePath;
@end

