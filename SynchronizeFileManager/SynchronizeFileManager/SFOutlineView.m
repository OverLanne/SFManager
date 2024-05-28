//
//  SFOutlineView.m
//  SynchronizeFileManager
//
//  Created by Евгений on 13.08.23.
//  Copyright © 2023 OverLanne. All rights reserved.
//

#import "SFOutlineView.h"

@implementation SFOutlineView

//- (id) makeViewWithIdentifier : (NSString *) identifier owner : (id) owner {
//    id btn = [super makeViewWithIdentifier: identifier owner: owner];
//    
//    if ([identifier isEqualToString: NSOutlineViewDisclosureButtonKey]) {
//        // Do your customization
//        NSLog(@"self :: %@", self);
//        NSLog(@"view :: %@", btn);
//    }
//    
//    return btn;
//}
//Для списков источников используйте NSOutlineViewShowHideButtonKey.


- (NSRect) frameOfOutlineCellAtRow : (NSInteger) row {
    NSRect superFrame = [super frameOfOutlineCellAtRow:row];
    return NSMakeRect(superFrame.origin.x + 20, superFrame.origin.y, superFrame.size.width, superFrame.size.height);
    //return superFrame;
}

// set need display  -  и ответная ей, где там перехватывать и что-то делать +- did...
/////////////
// чекбокс
// view for table column - НЕ ЗДЕСЬ, а там где ... ROW и поместить чекбокс на строку, а отслеживать через протоколы
// для таблицы сдвиг по-больше с учетом галочки

/* Optional - OutlineCell (disclosure triangle button cell)
 Implement this method to customize the "outline cell" used for the disclosure triangle button. customization of the "outline cell" used for the disclosure triangle button. For instance, you can cause the button cell to always use a "dark" triangle by changing the cell's backgroundStyle with: [cell setBackgroundStyle:NSBackgroundStyleLight]
 */
//- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item {
//    NSLog(@"111");
//}



//-------------------------------

/* Optional - Controlling expanding/collapsing of items.
 Called when the outlineView is about to expand 'item'. Implementations of this method should be fast. This method may be called multiple times if a given 'item' has children that are also being expanded. If NO is returned, 'item' will not be expanded, nor will its children (even if -[outlineView expandItem:item expandChildren:YES] is called).
 */
//- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item;
/* Optional - Controlling expanding/collapsing of items.
 Called when the outlineView is about to collapse 'item'. Implementations of this method should be fast. If NO is returned, 'item' will not be collapsed, nor will its children (even if -[outlineView collapseItem:item collapseChildren:YES] is called).
 */
//- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item;



//-------------------------------

//- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
//{
//    
//    //[cell setImage:[NSImage imageNamed: @"Navigation right 16x16 vWhite_tx"]];
//    //[cell setAlternateImage:[NSImage imageNamed: @"Navigation down 16x16 vWhite_tx"]];
//}

//
//- (void) highlightSelectionInClipRect : (NSRect) theClipRect {
//    NSRange visibleRowIndexes      = [self rowsInRect: theClipRect];
//    NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
//    NSUInteger endRow = visibleRowIndexes.location + visibleRowIndexes.length;
//    NSUInteger row;
//    
//    for (row = visibleRowIndexes.location; row < endRow; row++) {
//        if ([selectedRowIndexes containsIndex: row]) {
//            NSRect rowRect = NSInsetRect([self rectOfRow: row], 3, 4);
//            NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect: rowRect
//                                                                 xRadius: 5.0
//                                                                 yRadius: 5.0];
//            [[NSColor colorWithCalibratedRed: 0.474
//                                       green: 0.588
//                                        blue: 0.743
//                                       alpha:1] set];
//            [path fill];
//        }
//    }
//}
//
//- (void)drawRow:(NSInteger)row clipRect:(NSRect)clipRect
//{
//    NSColor* bgColor = Nil;
//    
//    if (self == [[self window] firstResponder] && [[self window] isMainWindow] && [[self window] isKeyWindow])
//    {
//        bgColor = [NSColor colorWithCalibratedWhite:0.300 alpha:1.000];
//    }
//    else
//    {
//        bgColor = [NSColor colorWithCalibratedWhite:0.800 alpha:1.000];
//    }
//    
//    NSIndexSet* selectedRowIndexes = [self selectedRowIndexes];
//    if ([selectedRowIndexes containsIndex:row])
//    {
//        [bgColor setFill];
//        NSRectFill([self rectOfRow:row]);
//    }
//    [super drawRow:row clipRect:clipRect];
//}
//
//-(void)tableViewSelectionDidChange:(NSNotification *)notification{
//    NSInteger selectedRow = [self selectedRow];
//    NSTableRowView *row = [self rowViewAtRow:selectedRow makeIfNecessary:NO];
//    row.layer.backgroundColor = [NSColor redColor].CGColor;
//    NSLog(@"selected");
//}

//- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
//{
//    // check if it is a textfield cell
//    if ([aCell isKindOfClass:[NSTextFieldCell class]])
//    {
//        NSTextFieldCell* tCell = (NSTextFieldCell*)aCell;
//        // check if it is selected
//        if ([[aTableView selectedRowIndexes] containsIndex:rowIndex])
//        {
//            tCell.textColor = [NSColor whiteColor];
//        }
//        else
//        {
//            tCell.textColor = [NSColor blackColor];
//        }
//    }
//}


@end
