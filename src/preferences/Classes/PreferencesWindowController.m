#import "PreferencesWindowController.h"
#import "NotificationKeys.h"
#import "PreferencesModel.h"
#import "Relauncher.h"
#import "ServerClient.h"
#import "SharedKeys.h"
#import "SharedUtilities.h"

@interface PreferencesWindowController ()

@property(weak) IBOutlet NSTableView* inputSourcesTableView;
@property(weak) IBOutlet NSTextField* currentInputSourceID;
@property(weak) IBOutlet NSTextField* versionText;
@property(weak) IBOutlet PreferencesModel* preferencesModel;
@property(weak) IBOutlet ServerClient* client;

@end

@implementation PreferencesWindowController

- (void)observer_kShowyEdgeServerDidLaunchNotification:(NSNotification*)notification {
  dispatch_async(dispatch_get_main_queue(), ^{
    [Relauncher relaunch];
  });
}

- (void)observer_kShowyEdgePreferencesUpdatedNotification:(NSNotification*)notification {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[self.client proxy] loadPreferencesModel:self.preferencesModel];
  });
}

- (void)observer_kShowyEdgeCurrentInputSourceIDChangedNotification:(NSNotification*)notification {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSString* inputSourceID = [self.client proxy].currentInputSourceID;
    if ([inputSourceID length] > 0) {
      [self.currentInputSourceID setStringValue:inputSourceID];
    }
  });
}

- (void)setup {
  [Relauncher resetRelaunchedCount];

  // In Mac OS X 10.7, NSDistributedNotificationCenter is suspended after calling [NSAlert runModal].
  // So, we need to set suspendedDeliveryBehavior to NSNotificationSuspensionBehaviorDeliverImmediately.
  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(observer_kShowyEdgeServerDidLaunchNotification:)
                                                          name:kShowyEdgeServerDidLaunchNotification
                                                        object:nil
                                            suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];

  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(observer_kShowyEdgePreferencesUpdatedNotification:)
                                                          name:kShowyEdgePreferencesUpdatedNotification
                                                        object:nil
                                            suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];

  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(observer_kShowyEdgeCurrentInputSourceIDChangedNotification:)
                                                          name:kShowyEdgeCurrentInputSourceIDChangedNotification
                                                        object:nil
                                            suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];

  NSString* version = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
  [self.versionText setStringValue:version];

  [self observer_kShowyEdgeCurrentInputSourceIDChangedNotification:nil];

  [self.inputSourcesTableView reloadData];
}

- (void)dealloc {
  [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
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

  [self.preferencesModel addInputSourceID:inputSourceID];
  [[self.client proxy] savePreferencesModel:self.preferencesModel];
  [self.inputSourcesTableView reloadData];

  NSInteger rowIndex = [self.preferencesModel getIndexOfInputSourceID:inputSourceID];
  [self.inputSourcesTableView reloadData];
  if (rowIndex >= 0) {
    [self.inputSourcesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] byExtendingSelection:NO];
    [self.inputSourcesTableView scrollRowToVisible:rowIndex];
  }
}

- (IBAction)quitWithConfirmation:(id)sender {
  if ([SharedUtilities confirmQuit]) {
    @try {
      [[self.client proxy] terminateServerProcess];
    } @catch (NSException* exception) {
    }

    [NSApp terminate:nil];
  }
}

- (IBAction)checkForUpdatesStableOnly:(id)sender {
  [[self.client proxy] checkForUpdatesStableOnly];
}

- (IBAction)checkForUpdatesWithBetaVersion:(id)sender {
  [[self.client proxy] checkForUpdatesWithBetaVersion];
}

- (IBAction)preferencesChanged:(id)sender {
  [[self.client proxy] savePreferencesModel:self.preferencesModel];
}

- (IBAction)openURL:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[sender title]]];
}

@end
