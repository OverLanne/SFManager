//
//  SFTableRowView.h
//  SynchronizeFileManager
//
//  Created by Евгений on 13.08.23.
//  Copyright © 2023 OverLanne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SFTableRowViewDelegate
- (void) checkBoxButtonClickedAtRow : (NSInteger) row andState: (NSInteger) state; // использовать супервью

@end

@interface SFTableRowView : NSTableRowView {
    //id delegate;
}

@property (strong) NSButton * checkBox;

- (void) checkboxOnClick : (NSButton *) sender;
@property (assign) id <SFTableRowViewDelegate> delegate;
//- (void) setDelegate : (id) newDelegate;

@end
