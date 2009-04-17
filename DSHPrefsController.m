#import "DSHPrefsController.h"

@implementation DSHPrefsController

#pragma mark API

+ (id)sharedPrefsController;
{
	id sharedController = nil;
	
	if ( sharedController == nil )
		sharedController = [[self alloc] initWithWindowNibName:@"Prefs"];
	
	return sharedController;
}

- (void)setTerminalApp:(id)sender;
{
	NSString *appName = ( [sender selectedRow] == 0 ) ? @"Terminal" : @"iTerm";
	[[NSUserDefaults standardUserDefaults] setObject:appName forKey:@"terminalApp"];
}

- (void)setPosition:(id)sender;
{
	NSString *level;
	
	switch ( [sender indexOfSelectedItem] )
	{
		case 0:
			level = @"top";
			break;
		case 1:
			level = @"floating";
			break;
		case 2:
			level = @"desktop";
			break;
		default:
			return;
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:level forKey:@"windowPosition"];
}

- (void)toggleKeepWindowOpen:(id)sender;
{
	NSNumber *keepOpen = [NSNumber numberWithInt:[sender state]];
	[[NSUserDefaults standardUserDefaults] setObject:keepOpen forKey:@"keepOpen"];
}

#pragma mark NSWindowController Overrides

- (void)windowDidLoad;
{
	NSString *app = [[NSUserDefaults standardUserDefaults] objectForKey:@"terminalApp"];
	NSString *level = [[NSUserDefaults standardUserDefaults] objectForKey:@"windowPosition"];
	int levelIndex, appIndex;
	
	if ( [level isEqualToString:@"top"] )
	{
		levelIndex = 0;
	}
	else if ( [level isEqualToString:@"top"] )
	{
		levelIndex = 1;
	}
	else
	{
		levelIndex = 2;
	}
	
	appIndex = ( [app isEqualToString:@"Terminal"] ) ? 0 : 1;
	
	[windowPosition selectItemAtIndex:levelIndex];
	[terminalApp selectCellAtRow:appIndex column:0];
}

- (IBAction)showWindow:(id)sender;
{
	[NSApp activateIgnoringOtherApps:YES];
	[[self window] center];
	[super showWindow:sender];
}

@end
