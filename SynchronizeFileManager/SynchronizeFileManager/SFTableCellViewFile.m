//
//  SFTableCellViewFile.m
//  SynchronizeFileManager
//
//  Created by Евгений on 13.08.23.
//  Copyright © 2023 OverLanne. All rights reserved.
//

#import "SFTableCellViewFile.h"

@implementation SFTableCellViewFile

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    
    SFTableCellViewFile  *cellView = [super initWithCoder: coder];

    _infoImage = [[NSImageView alloc] initWithFrame: NSMakeRect(1, 4, 16, 16)];
    [_infoImage setHidden: NO];
    [cellView addSubview: _infoImage];
    
    _trianglBtn = [[NSButton alloc] initWithFrame: NSMakeRect(21, 6, 13, 13)];
    [_trianglBtn setBezelStyle: NSDisclosureBezelStyle];
    [_trianglBtn setButtonType: NSPushOnPushOffButton];
    [_trianglBtn setTitle:  @""];
    [_trianglBtn highlight: NO];
    [_trianglBtn setHidden: YES];
    
    return cellView;
}

//- (void) triangleOnClick : (NSButton *) sender {
//    //[delegate clickHandlingOnCheckBox: sender];
//}
//- (void) setDelegate : (id) newDelegate {
//    delegate = newDelegate;
//}

- (IBAction) triangleButtonClicked : (NSButton *) button {
    NSOutlineView * outlineView      = (NSOutlineView *)[[self superview] superview];
    NSPoint         pointOutlineView = [button convertPoint: CGPointZero toView: outlineView];
    NSInteger       indexRow         = (NSInteger)[outlineView rowAtPoint: pointOutlineView];
    
    if (_delegate && [(NSObject *)_delegate respondsToSelector: @selector(triangleButtonClicked:atRow:)]) {
        [_delegate triangleButtonClicked: [button state] atRow: indexRow];
    }
}

@end
