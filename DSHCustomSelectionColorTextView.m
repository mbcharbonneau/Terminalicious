//
//  DSHCustomSelectionColorTextView.m
//  Terminalicious
//
//  Created by Marc Charbonneau on 7/20/05.
//  Copyright 2005 Downtown Software House. All rights reserved.
//

#import "DSHCustomSelectionColorTextView.h"

@implementation DSHCustomSelectionColorTextView

- (void)setSelectedRange:(NSRange)charRange affinity:(NSSelectionAffinity)affinity stillSelecting:(BOOL)flag
{
	// Sadly, setSelectedTextAttributes: & delegate methods do not work the way 
	// I want them to. So, override this instead.
	
	[self setTextColor:[NSColor greenColor]];
	[self setTextColor:[NSColor blackColor] range:charRange];
	
	[super setSelectedRange:charRange affinity:affinity stillSelecting:flag];
}

@end
