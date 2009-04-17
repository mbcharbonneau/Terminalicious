//
//  DSHTransparentDraggableWindow.h
//  Terminalicious
//
//  Created by Marc Charbonneau on 3/14/05.
//  Copyright 2005 Downtown Software House. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DSHTransparentWindow.h"


@interface DSHTransparentDraggableWindow : DSHTransparentWindow
{
	NSPoint initialLocation;
}

- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseDragged:(NSEvent *)theEvent;

@end
