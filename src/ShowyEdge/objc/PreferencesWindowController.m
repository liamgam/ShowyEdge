#import "PreferencesWindowController.h"
#import "MenuController.h"
#import "NotificationKeys.h"
#import "PreferencesManager.h"
#import "StartAtLoginUtilities.h"
#import "Updater.h"
#import "WorkSpaceData.h"

@interface PreferencesWindowController ()

@property(weak) IBOutlet MenuController* menuController;
@property(weak) IBOutlet NSButton* resumeAtLoginCheckbox;
@property(weak) IBOutlet NSTableView* inputSourcesTableView;
@property(weak) IBOutlet NSTextField* currentInputSourceID;
@property(weak) IBOutlet NSTextField* versionText;
@property(weak) IBOutlet Updater* updater;
@property(weak) IBOutlet WorkSpaceData* workspaceData;

@end

@implementation PreferencesWindowController

- (void)observer_kCurrentInputSourceIDChangedNotification:(NSNotification*)notification {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.currentInputSourceID setStringValue:self.workspaceData.currentInputSourceID];
  });
}

- (void)setup {
  [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];

  NSString* version = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
  [self.versionText setStringValue:version];
  if (StartAtLoginUtilities.isStartAtLogin) {
    self.resumeAtLoginCheckbox.state = NSControlStateValueOn;
  } else {
    self.resumeAtLoginCheckbox.state = NSControlStateValueOff;
  }

  [self.inputSourcesTableView reloadData];

  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(observer_kCurrentInputSourceIDChangedNotification:)
                                             name:kCurrentInputSourceIDChangedNotification
                                           object:nil];

  [self observer_kCurrentInputSourceIDChangedNotification:nil];
}

- (void)dealloc {
  [NSDistributedNotificationCenter.defaultCenter removeObserver:self];
}

- (void)show {
  [self.window makeKeyAndOrderFront:self];
  [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)addInputSourceID:(id)sender {
  NSString* inputSourceID = [self.currentInputSourceID stringValue];
  if ([inputSourceID length] == 0) {
    return;
  }

  [PreferencesManager addCustomizedLanguageColor:inputSourceID];
  [self.inputSourcesTableView reloadData];

  NSInteger rowIndex = [PreferencesManager getCustomizedLanguageColorIndexByInputSourceId:inputSourceID];
  if (rowIndex >= 0) {
    [self.inputSourcesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] byExtendingSelection:NO];
    [self.inputSourcesTableView scrollRowToVisible:rowIndex];
  }

  [NSNotificationCenter.defaultCenter postNotificationName:kIndicatorConfigurationChangedNotification object:nil];
}

- (IBAction)quit:(id)sender {
  [NSApp terminate:nil];
}

- (IBAction)checkForUpdatesStableOnly:(id)sender {
  [self.updater checkForUpdatesStableOnly];
}

- (IBAction)checkForUpdatesWithBetaVersion:(id)sender {
  [self.updater checkForUpdatesWithBetaVersion];
}

- (IBAction)indicatorConfigurationChanged:(id)sender {
  [NSNotificationCenter.defaultCenter postNotificationName:kIndicatorConfigurationChangedNotification object:nil];
}

- (IBAction)menubarIconConfigurationChanged:(id)sender {
  [self.menuController show];
}

- (IBAction)resumeAtLoginChanged:(id)sender {
  NSString* bundlePath = NSBundle.mainBundle.bundlePath;
  if ([bundlePath length] > 0) {
    if ([bundlePath hasSuffix:@"/Build/Products/Release/ShowyEdge.app"] /* from Xcode */ ||
        [bundlePath hasSuffix:@"/build/Release/ShowyEdge.app"] /* from command line */) {
      NSLog(@"%@ is debugging bundle", bundlePath);
      return;
    }
  }

  [StartAtLoginUtilities setStartAtLogin:(self.resumeAtLoginCheckbox.state == NSControlStateValueOn)];
}

- (IBAction)openOfficialWebsite:(id)sender {
  [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"https://showyedge.pqrs.org"]];
}

- (IBAction)openGitHub:(id)sender {
  [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"https://github.com/pqrs-org/ShowyEdge"]];
}

@end
