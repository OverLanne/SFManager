//
//  SFLoadingView.m
//  SynchronizeFileManager
//
//  Created by Евгений on 14.08.23.
//  Copyright © 2023 OverLanne. All rights reserved.
//

#import "SFLoadingView.h"

@implementation SFLoadingView


- (void) drawRect : (NSRect) dirtyRect {
    NSRect selectionRect = NSInsetRect(self.bounds, 0, 0);
    //[[NSColor colorWithRed:.25 green:.25 blue:.25 alpha:1.0] setStroke];
    [[NSColor colorWithRed:.255 green:.255 blue:.255 alpha:.15] setFill];
    NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect: selectionRect
                                                                  xRadius: 15
                                                                  yRadius: 15];
    
    //[selectionPath stroke];
    [selectionPath fill];
}

@end
