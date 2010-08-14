//
//  DrasticInputSourceStatusAppDelegate.m
//  DrasticInputSourceStatus
//
//  Created by Takayama Fumihiko on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "DrasticInputSourceStatusAppDelegate.h"
#import "MenuBarOverlayView.h"

@implementation DrasticInputSourceStatusAppDelegate

@synthesize window;

- (void) observer_kTISNotifySelectedKeyboardInputSourceChanged:(NSNotification*)notification
{
  TISInputSourceRef ref = TISCopyCurrentKeyboardInputSource();
  if (! ref) return;

  MenuBarOverlayView* view = [window contentView];
  if (! view) return;

  NSString* inputmodeid = TISGetInputSourceProperty(ref, kTISPropertyInputModeID);

  if (inputmodeid) {
    /*  */ if ([inputmodeid isEqual:@"com.apple.inputmethod.Japanese.Katakana"]) {
      [view setColor:[NSColor whiteColor] c1:[NSColor greenColor] c2:[NSColor whiteColor]];

    } else if ([inputmodeid isEqual:@"com.apple.inputmethod.Japanese.HalfWidthKana"]) {
      [view setColor:[NSColor whiteColor] c1:[NSColor purpleColor] c2:[NSColor whiteColor]];

    } else if ([inputmodeid isEqual:@"com.apple.inputmethod.Japanese.FullWidthRoman"]) {
      [view setColor:[NSColor whiteColor] c1:[NSColor yellowColor] c2:[NSColor whiteColor]];

    } else if ([inputmodeid hasPrefix:@"com.apple.inputmethod.Japanese"]) {
      [view setColor:[NSColor whiteColor] c1:[NSColor redColor] c2:[NSColor whiteColor]];

    } else if ([inputmodeid hasPrefix:@"com.apple.inputmethod.TCIM"]) { // TradChinese
      [view setColor:[NSColor redColor] c1:[NSColor redColor] c2:[NSColor redColor]];

    } else if ([inputmodeid hasPrefix:@"com.apple.inputmethod.SCIM"]) { // SimpChinese
      [view setColor:[NSColor redColor] c1:[NSColor redColor] c2:[NSColor redColor]];

    } else if ([inputmodeid hasPrefix:@"com.apple.inputmethod.Korean"]) {
      [view setColor:[NSColor redColor] c1:[NSColor blueColor] c2:[NSColor whiteColor]];

    } else {
      [view setColor:[NSColor blackColor] c1:[NSColor blackColor] c2:[NSColor blackColor]];
    }
  } else {
    [view setColor:[NSColor clearColor] c1:[NSColor clearColor] c2:[NSColor clearColor]];
  }
}

- (void) applicationDidFinishLaunching:(NSNotification*)aNotification {
  NSWindowCollectionBehavior behavior = NSWindowCollectionBehaviorCanJoinAllSpaces |
                                        NSWindowCollectionBehaviorStationary |
                                        NSWindowCollectionBehaviorIgnoresCycle;

  [window setAlphaValue:0.5];
  [window setBackgroundColor:[NSColor clearColor]];
  [window setOpaque:NO];
  [window setStyleMask:NSBorderlessWindowMask];
  [window setLevel:NSStatusWindowLevel];
  [window setIgnoresMouseEvents:YES];
  [window setCollectionBehavior:behavior];

  NSRect rect = [[NSScreen mainScreen] frame];
  CGFloat width = rect.size.width / 2;
  CGFloat height = 22;
  [window setFrame:NSMakeRect(0, rect.size.height - height, width, rect.size.height) display:NO];
  [[window contentView] initializeFrame];
  [[window contentView] setColor:[NSColor clearColor] c1:[NSColor clearColor] c2:[NSColor clearColor]];
  [window orderFront:nil];

  // ------------------------------------------------------------
  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(observer_kTISNotifySelectedKeyboardInputSourceChanged:)
                                                          name:(NSString*)(kTISNotifySelectedKeyboardInputSourceChanged)
                                                        object:nil];
  [self observer_kTISNotifySelectedKeyboardInputSourceChanged:nil];
}

@end
