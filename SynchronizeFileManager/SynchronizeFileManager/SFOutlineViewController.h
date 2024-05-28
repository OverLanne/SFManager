//
//  SFOutlineViewController.h
//  SynchronizeFileManager
//
//  Created by Евгений on 10.08.23.
//  Copyright © 2023 OverLanne. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFFile.h"
#import "SFOutlineView.h"
#import "SFTableRowView.h"
#import "SFLoadingView.h"
#import "SFTableCellViewFile.h"
#import "SFLoadingWindowsController.h"
//#import "SFLoadingWindowsViewController.h"
#import "SFWindow.h"

@interface SFOutlineViewController : NSViewController <NSOutlineViewDataSource, NSOutlineViewDelegate, SFTableRowViewDelegate, SFTableCellViewFileDelegate> { //NSToolbarItemValidation
    NSURL * _URLSource,
          * _URLReceiver;
//    NSImage * imgAdd,
//            * imgDel,
//            * imgUpd;
    NSArray * _icons;
    NSImage * _imgDetail,
            * _imgNoDetail;
    BOOL _isAccumulationMode;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties

@property (nonatomic, strong) SFLoadingWindowsController * loadingWinController;

@property (nonatomic) BOOL isToolButtonEnabled;            // Для Сопоставления
@property (nonatomic) BOOL isSynchronizePossible;          // Для Синхронизации
@property (nonatomic) BOOL isDetail;                       // Для детального Сопоставления

@property (nonatomic, strong) NSMutableArray * filesArray;                // Массив файлов
//@property (nonatomic, strong) NSMutableArray * arrayFilesSynchronization; // Массив на синхронизацию // убрать из проперти и сделать просто

@property (nonatomic, assign) IBOutlet SFOutlineView       * SFMainOutlineView;  // Основная таблица
@property (nonatomic, assign) IBOutlet NSScrollView        * SFScrollView;       //
//@property (assign) IBOutlet NSClipView          * SBClipView;         //
@property (nonatomic, assign) IBOutlet NSTextField         * SFTextLable1;       // Отображение пути к файлу ИСТОЧНИКА
@property (nonatomic, assign) IBOutlet NSTextField         * SFTextLable2;       // Отображение пути к файлу ПРИЁМНИКА
@property (nonatomic, assign) IBOutlet SFLoadingView       * SFLoadingView;      //
@property (nonatomic, assign) IBOutlet NSView              * SFTextFonView1;     //
@property (nonatomic, assign) IBOutlet NSView              * SFTextFonView2;     //
@property (nonatomic, assign) IBOutlet NSProgressIndicator * ProgressComparison; //


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SFTableCellViewFileDelegate

- (void) triangleButtonClicked : (BOOL) selected atRow : (NSInteger) row;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SFTableRowViewDelegate

- (void) checkBoxButtonClickedAtRow            : (NSInteger) row andState : (NSInteger) state;
- (void) updateStateAllItemsCurFolder          : (SFFile *) item;
- (void) updateStateAllParentFolders           : (SFFile *) curItem;
- (BOOL) allElementsHaveStateEqualStateCurItem : (SFFile *) curItem;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Actions & Methods

- (IBAction) openSynchronizeFile   : (NSButton *) sender;
- (IBAction) matchStartComparison  : (NSToolbarItem *) sender;
- (IBAction) matchStartSynchronize : (NSToolbarItem *) sender;
- (IBAction) reverseButtonOnClick  : (NSButton *) sender;

- (IBAction) detailMode : (NSToolbarItem *) sender;
- (IBAction) checkAllItem : (NSToolbarItem *) sender;
- (IBAction) unCheckAllItem : (NSToolbarItem *) sender;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Comparison

- (NSInteger) calculateCountItems;
- (BOOL) comparisonTwoPathsWithURLSourceFile : (NSURL *) curSourceURL andURLReceiverFile : (NSURL *) curReceiverURL withFillArray : (NSMutableArray **) fillArray;
- (NSMutableArray *) formingSortedArrayByURL : (NSURL *) curURL;


//- (void) fillArrayByURL: (NSURL *) URL usingIDArray: (int) IDArray;

@end
