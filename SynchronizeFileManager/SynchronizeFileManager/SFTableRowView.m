//
//  SFTableRowView.m
//  SynchronizeFileManager
//
//  Created by Евгений on 13.08.23.
//  Copyright © 2023 OverLanne. All rights reserved.
//

#import "SFTableRowView.h"

@implementation SFTableRowView

- (id) init
{
    self = [super init];
    if (self) {
        //
        //SFOutlineViewCheckBox * checkBox = [[SFOutlineViewCheckBox alloc] init];
        _checkBox = [[NSButton alloc] initWithFrame: NSMakeRect(4, 5, 18, 18)]; // установить проперти свойства чекбокса
        [_checkBox setButtonType: NSSwitchButton];
        [_checkBox setAllowsMixedState: NO];
        [_checkBox setState:  NSOnState];
        [_checkBox setTarget: self];
        [_checkBox setAction: @selector(checkboxOnClick:)];
        [self addSubview: _checkBox];
        
        //_isChecked = Yes;
    }
    return self;
}

- (void) drawSelectionInRect : (NSRect) dirtyRect
{
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone)
    {
        NSRect selectionRect = NSInsetRect(self.bounds, 2.5, 2.5);
        //[[NSColor colorWithCalibratedWhite: .39 alpha: 1.0] setStroke];   // 65
        //[[NSColor colorWithCalibratedWhite: .52 alpha: 1.0] setFill];     // 82
        //[[NSColor colorWithCalibratedWhite: .72 alpha: 1.0] setStroke];
        //[[NSColor colorWithCalibratedWhite: .87 alpha: 1.0] setFill];
        

//        [[NSColor colorWithRed: 0.1686
//                         green: 0.1216
//                          blue: 0.1176
//                         alpha: 0.05] setFill];
        [[NSColor colorWithRed: 0.1686
                         green: 0.1216
                          blue: 0.1176
                         alpha: 0.4] setFill];
        [[NSColor colorWithRed: 0.0
                         green: 0.3843
                          blue: 0.8745
                         alpha: 1.0] setStroke];
        NSBezierPath * selectionPath = [NSBezierPath bezierPathWithRoundedRect: selectionRect
                                                                       xRadius: 5
                                                                       yRadius: 5];
        [selectionPath fill];
        [selectionPath stroke];
    }
}

- (void) checkboxOnClick : (NSButton *) button
{
    NSOutlineView * outlineView = (NSOutlineView *)[self superview];
//    NSPoint pointOutlineView = [button convertPoint: CGPointZero toView: outlineView];
//    NSInteger indexRow = (NSInteger)[outlineView rowAtPoint: pointOutlineView];
    NSInteger indexRow = (NSInteger)[outlineView rowForView: self];
    
    
    if (_delegate && [(NSObject *)_delegate respondsToSelector: @selector(checkBoxButtonClickedAtRow:andState:)]) {
        [_delegate checkBoxButtonClickedAtRow: indexRow andState: [button state]];
    }
    //[_delegate clickHandlingOnCheckBox: sender];
}

//- (void) setDelegate : (id) newDelegate {
//    delegate = newDelegate;
//}











//- (void) drawRect : (NSRect) dirtyRect {
//    [super drawRect:dirtyRect];
//
//    //NSLog(@"x :::%f@", self.frame.origin.x);
//    NSRect selectionRect = NSMakeRect(self.bounds.origin.x+self.bounds.size.width/2-1, self.bounds.origin.y, 1, self.bounds.size.height);
//    [[NSColor colorWithRed: 0.69
//                     green: 0.69
//                      blue: 0.69
//                     alpha: 1.0] setFill];     // 82
//    NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect: selectionRect
//                                                                  xRadius: 0
//                                                                  yRadius: 0];
//    [selectionPath fill];
//}

@end
