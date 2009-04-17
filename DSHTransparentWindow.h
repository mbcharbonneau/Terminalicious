//
//  DSHTransparentWindow.h
//  Terminalicious
//
//  Created by Marc Charbonneau on 3/13/05.
//  Copyright 2005 Downtown Software House. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DSHTransparentWindow : NSWindow {}

- (void)fadeWithTimer:(NSTimer *)aTimer;

@end