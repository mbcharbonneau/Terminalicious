//
//  DSHController.m
//  Terminalicious
//
//  Created by Marc Charbonneau on 3/13/05.
//  Copyright 2005 Downtown Software House. All rights reserved.
//

#import "DSHController.h"
#import "TRMHotkeyManager.h"
#import "DSHPrefsController.h"
#import "DSHCustomSelectionColorTextView.h"

static NSString *HISTORY_PATH = @"~/Library/Preferences/com.downtownsoftwarehouse.terminalicious.plist";

@interface DSHController (Private)

- (void)_tableViewDoubleClick:(id)sender;
- (void)_positionWindows;
- (void)_launchCommand:(NSString *)command;

@end

@implementation DSHController

#pragma mark API

- (void)windowMoved:(id)sender
{
	if ( sender == commandWindow )
	{
		NSRect frame = [commandWindow frame];
		frame.origin.y -= 5;
		[historyWindow setFrameTopLeftPoint:frame.origin];
	}
}

- (void)escPressed:(id)sender
{
	if ( [historyWindow isVisible] )
	{
		[self toggleHistoryWindow:sender];
	}
	else if ( [commandWindow isVisible] )
	{
		[self toggleCommandWindow:sender];
	}
}

#pragma mark NSTableView DataSource Methods

- (int)numberOfRowsInTableView: (NSTableView *)table;
{
	return [history count];
}

- (id)tableView:(NSTableView *)table objectValueForTableColumn:(NSTableColumn *)column row:(int)row;
{
	return [history objectAtIndex:row];
}

#pragma mark NSTableView Delegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification;
{
	int selected = [[notification object] selectedRow];
	if ( selected != -1 )
	{
		[commandTextField setStringValue:[history objectAtIndex:selected]];
		[historyTableView scrollRowToVisible:selected];
	}
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
{
	NSColor *color = ( [aTableView selectedRow] == rowIndex ) ? [NSColor selectedTextColor] : [NSColor greenColor];
	
	NSFont *font = [NSFont systemFontOfSize:10];
    NSDictionary *text = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, color, NSForegroundColorAttributeName, nil];
	
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:[aCell stringValue] attributes:text];
	
    [aCell setAttributedStringValue:[attrStr autorelease]];
}

#pragma mark NSWindow Delegate Methods

/*	I'm using a custom field editor to set the cursor text color and the selected
text color */

- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject {
	
	id retVal = nil;
	
	if ( anObject == commandTextField )
		retVal = fieldEditor;
	
	return retVal;
}

#pragma mark NSControl Delegate Methods

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	NSString *command = [commandTextField stringValue];
	[self _launchCommand:command];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
	// This method handles key events that are trapped by the field editor
	// in the command window.
	BOOL retVal = NO;
	
	if ( @selector(moveDown:) == command ) {	// move postion in history down
		retVal = YES;
		int currentSelection = [historyTableView selectedRow];
		if ( currentSelection <= ([historyTableView numberOfRows] - 2) ) {
			// We're moving to the first history item. Save the current command string, in case we want to come back to it.
			// We want to select the first history item, even though it's already selected, since it isn't yet in the command field.
			if ( currentSelection == 0 && ![[commandTextField stringValue] isEqualToString:[history objectAtIndex:0]] ) {
				[prevCommandText release];
				prevCommandText = [[commandTextField stringValue] retain];
				[commandTextField setStringValue:[history objectAtIndex:0]];
			} else {
				[historyTableView selectRow:(currentSelection + 1) byExtendingSelection:NO];
			}
		} else {
			NSBeep();
		}
	} else if ( @selector(moveUp:) == command ) {	// move postion in history up
		retVal = YES;
		int currentSelection = [historyTableView selectedRow];
		if ( currentSelection > 0 ) {
			[historyTableView selectRow:(currentSelection - 1) byExtendingSelection:NO];
		} else {
			// Leave history and return to what was originally in the command field:
			[commandTextField setStringValue:prevCommandText];
			NSBeep();
		}
	} else if ( @selector(cancelOperation:) == command ) {	// close window
		retVal = YES;
		[self escPressed:self];
	} else if ( @selector(insertTab:) == command ) {
		// future home of auto-completion?
		retVal = YES;
	}	
	
	return retVal;
} // doCommandBySelector

#pragma mark NSObject Overrides

- (void)awakeFromNib
{
	// Load the command history.
	
	prevCommandText = @"";
	history = [[NSMutableArray arrayWithContentsOfFile:[HISTORY_PATH stringByExpandingTildeInPath]] retain];
	
	if ( history == nil )
	{
		// Create a few useful history items.
		
		history = [[NSMutableArray alloc] initWithObjects:
			@"tail -f /private/var/log/system.log",
			@"top -o cpu -R",
			@"sudo periodic daily",
			@"sudo periodic weekly",
			@"sudo periodic monthly", nil];
	}
	
	// Create history sub-menu.
	
	historyMenu = [[NSMenu alloc] initWithTitle:@"History"];
	NSEnumerator *enumerator = [history objectEnumerator];
	NSString *historyItem;
	
	while ( historyItem = [enumerator nextObject] )
	{
		[historyMenu addItemWithTitle:historyItem action:@selector(launchCommandFromMenu:) keyEquivalent:@""];
	}
	
	[historySubMenu setSubmenu:historyMenu];
	
	// Observer NSUserDefaults for any changes that effect us.
	
	[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"windowPosition" options:0 context:NULL];
	
	// Create the status bar item.
	
	NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
	NSImage *icon = [NSImage imageNamed:@"statusitem"];

	statusBarItem = [[statusBar statusItemWithLength:NSSquareStatusItemLength] retain];
	[statusBarItem setToolTip:@"Start a command in the Terminal."];
	[statusBarItem setImage:icon];
	[statusBarItem setMenu:statusItemMenu];
	[statusBarItem setHighlightMode:YES];
	
	[historyTableView setDoubleAction:@selector(_tableViewDoubleClick:)];

	fieldEditor = [[DSHCustomSelectionColorTextView alloc] initWithFrame:[commandTextField frame]];
	[fieldEditor setFieldEditor:YES];
	[fieldEditor setInsertionPointColor:[NSColor whiteColor]];

	// Set initial window layer. Since setWindowPositions will open both
	// windows, call toggleHistoryWindow to make sure it shows up in the correct
	// location.
	
	[self toggleHistoryWindow:self];
	[self _positionWindows];
	
	// Close the windows that we opened.
	
	[self toggleCommandWindow:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// Act on any changes to the defaults database.
	
	if ( [keyPath isEqualToString:@"windowPosition"] )
	{
		[self _positionWindows];
	}
}

- (void)dealloc;
{
	[history release];
	[prevCommandText release];
	[statusBarItem release];
	[fieldEditor release];
	[historyMenu release];
	
	[super dealloc];
}

#pragma mark Action Methods

/* Note: These two methods should be the only ones opening or closing windows. */

- (IBAction)toggleHistoryWindow:(id)sender {
	if ( [historyWindow isVisible] ) {
		[showHistoryWindowButton setState:NSOffState];
		[historyWindow orderOut:sender];
	} else {
		NSRect frame = [commandWindow frame];
		frame.origin.y -= 5;
		[historyWindow setFrameTopLeftPoint:frame.origin];
		[showHistoryWindowButton setState:NSOnState];
		[commandWindow makeKeyAndOrderFront:sender];	// Make sure command window is also visible.
		[historyWindow makeKeyAndOrderFront:sender];
		[NSApp activateIgnoringOtherApps:YES];	// Give our application focus.
	}
	// NSLog( @"Debug: Toggle history window." );
} // toggleHistoryWindow

- (IBAction)toggleCommandWindow:(id)sender {
	if ( [commandWindow isVisible] ) {
		[historyTableView selectRow:(0) byExtendingSelection:NO];	// Reset history position
		[showHistoryWindowButton setState:NSOffState];
		[historyWindow orderOut:sender];	// Make sure history window is also closed.
		[commandTextField setObjectValue:nil];
		[commandWindow orderOut:self];
	} else {
		[commandWindow makeKeyAndOrderFront:sender];
		[NSApp activateIgnoringOtherApps:YES];	// Give our application focus.
	}
} // showCommandWindow

- (IBAction)showAboutPanel:(id)sender
{
	// Since we're a background only status item, we'll need to steal focus
	// from other apps before opening a window.
	
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:sender];
}

- (IBAction)showPrefsPanel:(id)sender;
{
	[[DSHPrefsController sharedPrefsController] showWindow:sender];
}

- (IBAction)clearHistory:(id)sender
{
	[history removeAllObjects];
	[historyTableView reloadData];
	[history writeToFile:[HISTORY_PATH stringByExpandingTildeInPath] atomically:YES];
	
	NSArray *menuItems = [historyMenu itemArray];
	NSEnumerator *itemsEnum = [menuItems objectEnumerator];
	NSMenuItem *currentItem;
	
	while ( currentItem = [itemsEnum nextObject] )
	{
		[historyMenu removeItem:currentItem];
	}	
}

- (IBAction)openWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.downtownsoftwarehouse.com/Terminalicious/"]];
}

- (IBAction)launchCommandFromMenu:(id)sender
{
	// todo: this may not work with really long commands
	NSAssert( [sender title] != nil, @"Command is nil" );
	
	NSString *command = [sender title];
	[self _launchCommand:command];
}

@end

@implementation DSHController (Private)

- (void)_tableViewDoubleClick:(id)sender;
{
	if ( [sender selectedRow] == -1 )
		return;
	
	NSString *command = [history objectAtIndex:[historyTableView selectedRow]];
	[self _launchCommand:command];
}

- (void)_positionWindows;
{
	/*	I'm running into problems setting the shadow when the windows are not
	open, so make sure they're on screen. */
	
	[commandWindow makeKeyAndOrderFront:self];
	[historyWindow makeKeyAndOrderFront:self];
	[showHistoryWindowButton setState:NSOnState];
	
	NSString *position = [[NSUserDefaults standardUserDefaults] objectForKey:@"windowPosition"];
	
	if ( [position isEqualToString:@"top"] )
	{
		[commandWindow setLevel: NSStatusWindowLevel];
		[commandWindow setHasShadow: YES];
		[historyWindow setLevel: NSStatusWindowLevel];
		[historyWindow setHasShadow: YES];
	}
	else if ( [position isEqualToString:@"floating"] ) 
	{
		[commandWindow setLevel: NSNormalWindowLevel];
		[commandWindow setHasShadow: YES];
		[historyWindow setLevel: NSNormalWindowLevel];
		[historyWindow setHasShadow: YES];
	}
	else
	{
		[commandWindow setLevel: kCGDesktopIconWindowLevel];
		[commandWindow setHasShadow: NO];
		[historyWindow setLevel: kCGDesktopIconWindowLevel];
		[historyWindow setHasShadow: NO];
	}
}

- (void)_launchCommand:(NSString *)command;
{
	if ( ![command isEqualToString:@""] ) 
	{
		[history insertObject:command atIndex:0];
		[historyMenu insertItemWithTitle:command action:@selector(launchCommandFromMenu:) keyEquivalent:@"" atIndex:0]; 
		
		if ( [history count] > 50 )
		{
			[history removeLastObject];
			[historyMenu removeItemAtIndex:( [historyMenu numberOfItems] - 1 )];
		}
		
		[historyTableView reloadData];
		[history writeToFile:[HISTORY_PATH stringByExpandingTildeInPath] atomically:YES];
	}
	
	// Escape quotation marks or they will break things:
	
	NSMutableString *mutableCommand = [command mutableCopy];
	if ( [mutableCommand length] > 0 )
	{
		NSRange range = [mutableCommand rangeOfString:mutableCommand];
		[mutableCommand replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSLiteralSearch range:range];
	}

	NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:@"terminalApp"];
	NSString *resourceName = [key isEqualToString: @"iTerm"] ? @"iterm" : @"terminal";

	NSBundle *appBundle = [NSBundle mainBundle];
	NSMutableString *source = [NSMutableString stringWithContentsOfFile:[appBundle pathForResource:resourceName ofType:@"applescript"]];

	[source replaceOccurrencesOfString:@"COMMAND" withString:command options:NSBackwardsSearch range: NSMakeRange(0, [source length])];

	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
	NSDictionary *errorInfo = nil;

	if ( ![script executeAndReturnError:&errorInfo] && errorInfo != nil )
	{
		NSString *title = NSLocalizedString( @"Terminalicious encountered an error while communicating with Terminal.", @"" );
		NSAlert *alert = [NSAlert alertWithMessageText:title defaultButton:@"" alternateButton:@"" otherButton:@"" informativeTextWithFormat:@""];
		[alert runModal];
	}

	// todo: applescript works, but could probably use a bit of improvement

	BOOL close = ![[[NSUserDefaults standardUserDefaults] objectForKey:@"keepOpen"] boolValue];
	if ( close && [commandWindow isVisible] )
	{
		[self toggleCommandWindow:self];
	}
	else
	{
		[historyTableView selectRow:0 byExtendingSelection:NO];
		[commandTextField setObjectValue:nil];
	}

	[script release];
	[mutableCommand release];
}

@end
