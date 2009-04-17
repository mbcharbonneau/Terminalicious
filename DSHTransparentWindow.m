//
//  DSHTransparentWindow.m
//  Terminalicious
//
//  Created by Marc Charbonneau on 3/13/05.
//  Copyright 2005 Downtown Software House. All rights reserved.
//

#import "DSHTransparentWindow.h"
#import "DSHController.h"

@implementation DSHTransparentWindow

#pragma mark API

- (void)fadeWithTimer:(NSTimer *)aTimer
{
	if ([self alphaValue] > 0.0)
	{
        // If window is still partially opaque, reduce its opacity and wait
		// until the next fire date.
		
        [self setAlphaValue:[self alphaValue] - 0.2];
    }
	else
	{
        [aTimer invalidate];
        [super orderOut:nil];        
    }
}

#pragma mark NSWindow Overrides

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag 
{
	if ( ![super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:flag] )
		return nil;
	
    // Set the background color to clear. Our content view will handle drawing
	// a partially transparent background.
	
    [self setBackgroundColor:[NSColor clearColor]];
    [self setOpaque:NO];

    return self;
}

- (BOOL)canBecomeKeyWindow 
{
	// Custom windows that use the NSBorderlessWindowMask can't become key by 
	// default, we need to change this.
	
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent 
{	
	unsigned short keyCode = [theEvent keyCode];

	if ( keyCode == 53 )
	{
		[[self delegate] escPressed:self];
	}
	else if ( keyCode == 36 || keyCode == 76 ) 
	{
		[[self delegate] controlTextDidEndEditing:nil];
	}
}

- (void)orderOut:(id)sender
{
	// Begin the fade sequence.
	
	[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(fadeWithTimer:) userInfo:nil repeats:YES];
}

- (void)orderFront:(id)sender
{
	[super orderFront:sender];
	[self setAlphaValue:1.0];
}

- (void)makeKeyAndOrderFront:(id)sender
{
	[super makeKeyAndOrderFront:sender];
	[self setAlphaValue:1.0];
}

@end