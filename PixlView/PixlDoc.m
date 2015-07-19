//
//  Document.m
//  documentsTest
//
//  Created by Sveinbjorn Thordarson on 21/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import "PixlDoc.h"

@implementation PixlDoc

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

//Lazy instantiation of window controller
- (PixlDocWindowController *)controller {
    if (!_controller) {
        _controller = [[PixlDocWindowController alloc] initWithWindowNibName:@"PixlDoc"];
    }
    return _controller;
}

- (void)makeWindowControllers {
    [self addWindowController:self.controller];
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
 
    self.filePath = [url path];
    self.pixelBuffer = [[PixelBuffer alloc] initWithContentsOfFile:self.filePath];
    
    return self.pixelBuffer != nil;
}

@end
