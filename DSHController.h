//
//  DSHController.h
//  Terminalicious
//
//  Created by Marc Charbonneau on 3/13/05.
//  Copyright 2005 Downtown Software House. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DSHCustomSelectionColorTextView;

@interface DSHController : NSObject
{
	NSMutableArray *history;
	NSString *prevCommandText;
	NSStatusItem *statusBarItem;
	DSHCustomSelectionColorTextView *fieldEditor;
	NSMenu *historyMenu;
	
	IBOutlet id commandTextField;
	IBOutlet id historyWindow;
	IBOutlet id historyTableView;
	IBOutlet id commandWindow;
	IBOutlet id showHistoryWindowButton;
	IBOutlet id statusItemMenu;
	IBOutlet id historySubMenu;
}

- (void)windowMoved:(id)sender;
- (void)escPressed:(id)sender;

- (int)numberOfRowsInTableView: (NSTableView *)table;
- (id)tableView: (NSTableView *)table objectValueForTableColumn: (NSTableColumn *)column row: (int)row;

- (IBAction)toggleHistoryWindow:(id)sender;
- (IBAction)toggleCommandWindow:(id)sender;
- (IBAction)showAboutPanel:(id)sender;
- (IBAction)showPrefsPanel:(id)sender;
- (IBAction)clearHistory:(id)sender;
- (IBAction)openWebsite:(id)sender;
- (IBAction)launchCommandFromMenu:(id)sender;

@end
