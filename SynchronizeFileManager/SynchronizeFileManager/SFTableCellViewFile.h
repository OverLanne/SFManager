//
//  SFTableCellViewFile.h
//  SynchronizeFileManager
//
//  Created by Евгений on 13.08.23.
//  Copyright © 2023 OverLanne. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol SFTableCellViewFileDelegate
@optional
- (void) triangleButtonClicked: (BOOL) selected atRow: (NSInteger) row;

@end

@interface SFTableCellViewFile : NSTableCellView {
//    id delegate;
}

@property (strong) NSImageView       * infoImage;          // Инфо статус для ячейки
@property (strong) IBOutlet NSButton * trianglBtn;         //

@property (assign) id <SFTableCellViewFileDelegate> delegate;

//- (void) triangleOnClick : (NSButton *) sender;
//- (void) setDelegate : (id) newDelegate;
- (IBAction) triangleButtonClicked : (NSButton *) sender;

@end
