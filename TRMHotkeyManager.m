//
//  TRMHotkeyManager.m
//  Terminalicious
//
//  Created by Marc Charbonneau on 6/9/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TRMHotkeyManager.h"

@interface TRMHotkeyManager (Private)

- (void)_keyPressed;

@end

OSStatus eventHandler( EventHandlerCallRef nextHandler, EventRef theEvent, void *userData )
{
	[[TRMHotkeyManager sharedManager] _keyPressed];
	NSLog( @"do stuff" );
	return noErr;
}

@implementation TRMHotkeyManager

#pragma mark API

+ (id)sharedManager;
{
	static id sharedManager = nil;
	
	if ( sharedManager == nil )
		sharedManager = [[self alloc] init];
	
	return sharedManager;
}

- (id)target;
{
	return _target;
}

- (SEL)action;
{
	return _action;
}

- (void)setTarget:(id)target;
{
	_target = target;
}

- (void)setAction:(SEL)action;
{
	_action = action;
}

#pragma mark NSObject Overrides

- (id)init;
{
	if ( ![super init] )
		return nil;
	
	EventHotKeyRef gMyHotKeyRef;
	EventHotKeyID gMyHotKeyID;
	EventTypeSpec eventType;
	
	eventType.eventClass = kEventClassKeyboard;
	eventType.eventKind = kEventHotKeyPressed;
	
	InstallApplicationEventHandler( &eventHandler, 1, &eventType, NULL, NULL );
	
	gMyHotKeyID.signature = 'htk1';
	gMyHotKeyID.id = 1;
	
	RegisterEventHotKey( 49, cmdKey+optionKey, gMyHotKeyID, GetApplicationEventTarget(), 0, &gMyHotKeyRef );
	
	return self;
}

@end

@implementation TRMHotkeyManager (Private)

- (void)_keyPressed;
{
	if ( [[self target] respondsToSelector:[self action]] )
		[[self target] performSelector:[self action]];
}

@end