//
//  TRMHotkeyManager.h
//  Terminalicious
//
//  Created by Marc Charbonneau on 6/9/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface TRMHotkeyManager : NSObject 
{
	id _target;
	SEL _action;
}

+ (id)sharedManager;

- (id)target;
- (SEL)action;

- (void)setTarget:(id)target;
- (void)setAction:(SEL)action;

@end
