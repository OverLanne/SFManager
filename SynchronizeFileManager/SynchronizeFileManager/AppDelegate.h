//
//  AppDelegate.h
//  SynchronizeFileManager
//
//  Created by Евгений on 10.08.23.
//  Copyright © 2023 OverLanne. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFOutlineViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    //NSProgressIndicator * loadingSpinner;
}

@property (weak) IBOutlet NSWindow * mainWindow;
@property (weak) IBOutlet NSWindow * loadingWindow;
@property (weak) IBOutlet NSView   * loadingMainView;
@property (weak) IBOutlet SFOutlineViewController * outlineViewController;

@end

