//
//  DSHTransparentView.h
//  Terminalicious
//
//  Created by Marc Charbonneau on 3/13/05.
//  Copyright 2005 Downtown Software House. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DSHTransparentView : NSView
{
	NSImage *background;
}

- (void)awakeFromNib;
- (void)drawRect:(NSRect)rect;

@end
