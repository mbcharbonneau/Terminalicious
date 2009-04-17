//
//  DSHTransparentView.m
//  Terminalicious
//
//  Created by Marc Charbonneau on 3/13/05.
//  Copyright 2005 Downtown Software House. All rights reserved.
//

#import "DSHTransparentView.h"

@implementation DSHTransparentView

- (void)awakeFromNib 
{
	// Some day I should convert this to using a rounded bezier path instead of 
	// an image.
	
	background = [NSImage imageNamed:@"background"];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect 
{
	// I had a call to fill the window with clearColor before-- pretty sure I 
	// don't need that.
	
	[background compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver fraction:0.7];
	[[self window] invalidateShadow];
}

@end
