//
//  Document.m
//  documentsTest
//
//  Created by Sveinbjorn Thordarson on 21/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import "PixelDocument.h"

@implementation PixelDocument

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

//Lazy instantiation of window controller
- (PixelDocumentController *)controller {
    if (!_controller) {
        _controller = [[PixelDocumentController alloc] initWithWindowNibName:@"PixelDocument"];
    }
    
    return _controller;
}

- (void)makeWindowControllers {
    [self addWindowController:self.controller];
}


//- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
//    [super windowControllerDidLoadNib:aController];
//    // Add any code here that needs to be executed once the windowController has loaded the document's window.
//    
//    
//}

+ (BOOL)autosavesInPlace {
    return YES;
}

//- (NSString *)windowNibName {
//    // Override returning the nib file name of the document
//    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
//    return @"Document";
//}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return nil;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
 
    self.filePath = [url path];
    self.pixelBuffer = [[PixelBuffer alloc] initWithContentsOfFile:self.filePath];
    
    return YES;
}

//- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
//    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
//    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
//    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
//    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
//    
//
//    
//    
//    return YES;
//}
//
@end
