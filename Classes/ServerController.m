#import "PreferencesKeys.h"
#import "ServerController.h"
#import "StartAtLoginUtilities.h"

@implementation ServerController

+ (void)quitWithConfirmation {
  NSAlert* alert = [NSAlert new];
  alert.messageText = @"Confirmation";
  alert.informativeText = @"Are you sure you want to quit ShowyEdge?";
  [alert addButtonWithTitle:@"Quit"];
  [alert addButtonWithTitle:@"Cancel"];
  if ([alert runModal] != NSAlertFirstButtonReturn) {
    return;
  }

  [ServerController updateStartAtLogin:NO];
  [NSApp terminate:nil];
}

+ (void)updateStartAtLogin:(BOOL)preferredValue {
  if (!preferredValue) {
    [StartAtLoginUtilities setStartAtLogin:NO];

  } else {
    // Do not register to StartAtLogin if kResumeAtLogin is NO.
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kResumeAtLogin]) {
      [StartAtLoginUtilities setStartAtLogin:NO];
    } else {
      [StartAtLoginUtilities setStartAtLogin:YES];
    }
  }
}

@end
