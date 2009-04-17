/* DSHPrefsController */

#import <Cocoa/Cocoa.h>

@interface DSHPrefsController : NSWindowController
{
	IBOutlet NSPopUpButton *windowPosition;
	IBOutlet NSMatrix *terminalApp;
}

+ (id)sharedPrefsController;

- (void)setTerminalApp:(id)sender;
- (void)setPosition:(id)sender;
- (void)toggleKeepWindowOpen:(id)sender;

@end
