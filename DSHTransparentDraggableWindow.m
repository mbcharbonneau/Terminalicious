//
//  DSHTransparentDraggableWindow.m
//  Terminalicious
//
//  Created by Marc Charbonneau on 3/14/05.
//  Copyright 2005 Downtown Software House. All rights reserved.
//

#import "DSHTransparentDraggableWindow.h"
#import "DSHController.h"

@implementation DSHTransparentDraggableWindow

//We start tracking the a drag operation here when the user first clicks the mouse,
//to establish the initial location.
- (void)mouseDown:(NSEvent *)theEvent {
    NSRect  windowFrame = [self frame];
	
    //grab the mouse location in global coordinates
	initialLocation = [self convertBaseToScreen:[theEvent locationInWindow]];
	initialLocation.x -= windowFrame.origin.x;
	initialLocation.y -= windowFrame.origin.y;
}

//Once the user starts dragging the mouse, we move the window with it. We do this because the window has no title
//bar for the user to drag (so we have to implement dragging ourselves)
- (void)mouseDragged:(NSEvent *)theEvent {
	NSPoint currentLocation;
	NSPoint newOrigin;
	NSRect  screenFrame = [[NSScreen mainScreen] frame];
	NSRect  windowFrame = [self frame];
	
	
	//grab the current global mouse location; we could just as easily get the mouse location 
	//in the same way as we do in -mouseDown:
    currentLocation = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];
    newOrigin.x = currentLocation.x - initialLocation.x;
    newOrigin.y = currentLocation.y - initialLocation.y;
    
    // Don't let window get dragged up under the menu bar
    if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) ){
		newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
    }
    
    //go ahead and move the window to the new location
    [self setFrameOrigin:newOrigin];
	
	[[self delegate] windowMoved:self];
}

@end
