//
//  main.m
//  PixelViewer
//
//  Created by Sveinbjorn Thordarson on 19/06/15.
//  Copyright (c) 2015 Sveinbjorn Thordarson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

void exceptionHandler(NSException *exception) {
    NSLog(@"%@", [exception reason]);
    NSLog(@"%@", [exception userInfo]);
    NSLog(@"%@", [exception callStackReturnAddresses]);
    NSLog(@"%@", [exception callStackSymbols]);
}

int main(int argc, const char * argv[]) {
    
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    return NSApplicationMain(argc, argv);
}
