//
//  SFOutlineViewController.m
//  SynchronizeFileManager
//
//  Created by Евгений on 10.08.23.
//  Copyright © 2023 OverLanne. All rights reserved.
//

#import "SFOutlineViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonCrypto.h>

//#import "SFTableCellViewFile.h"
//@import AppKit;


// Standard library
#include <stdint.h>
#include <stdio.h>
// Core Foundation
#include <CoreFoundation/CoreFoundation.h>
// Cryptography
#include <CommonCrypto/CommonDigest.h>
// In bytes
#define FileHashDefaultChunkSizeForReadingData 4096


@implementation SFOutlineViewController


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark viewDidLoad
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//1. Жизненный цикл - иниты, переопределения, сеттеры
//2. Селекторы, принимающие уведомления
//3. Селекторы кнопок, тулбаров, меню
//4. Приватные методы
//5. Делегатные методы (отдельно по каждому протоколу)


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _isAccumulationMode = NO;
    
    ////////////////////////////////////////////////////////////
    // Массив с иконками для infoState
    ////////////////////////////////////////////////////////////
    
    _icons = @[[NSImage imageNamed: @"Add_Object@2x"],
               [NSImage imageNamed: @"Del_Object@2x"],
               [NSImage imageNamed: @"Upd_Object@2x"]];
    
    _imgDetail = [NSImage imageNamed: @"FullMode@2x.png"];
    _imgNoDetail = [NSImage imageNamed: @"Mode@2x.png"];
    
    
    ////////////////////////////////////////////////////////////
    // Стартовая настройка Bindings
    ////////////////////////////////////////////////////////////
    
    [self setValue:@(YES) forKey: @"isToolButtonEnabled"];
    [self setValue:@(NO)  forKey: @"isSynchronizePossible"];
    [self setValue:@(NO)  forKey: @"isDetail"];
    
    
    ////////////////////////////////////////////////////////////
    // Стартовая настройка ПрогрессБара
    ////////////////////////////////////////////////////////////
    
    [self.ProgressComparison setHidden:     NO];
    [self.ProgressComparison setAlphaValue: 0.0];
    
    
    ////////////////////////////////////////////////////////////
    // Настройка стартовых значений массива и УРЛов
    ////////////////////////////////////////////////////////////
    
    //_arrayFilesSynchronization = [NSMutableArray new];
    _filesArray = [NSMutableArray new];
    _URLSource   = nil;
    _URLReceiver = nil;
    
    
    ////////////////////////////////////////////////////////////
    // Установка dataSource и delegate
    ////////////////////////////////////////////////////////////
    
    [self.SFMainOutlineView setDelegate:   self];
    [self.SFMainOutlineView setDataSource: self];
    
    
    ////////////////////////////////////////////////////////////
    // Визуальная настройка окон и вьюшек
    ////////////////////////////////////////////////////////////
    
    [self.SFScrollView.layer setCornerRadius:   15.0];
    [self.SFScrollView.layer setMasksToBounds:  YES];
    
    [self.SFLoadingView.layer setCornerRadius:  15.0];
    [self.SFLoadingView.layer setMasksToBounds: YES];
    
    [self.SFTextFonView1.layer setBackgroundColor: [[NSColor whiteColor] CGColor]];
    [self.SFTextFonView1.layer setCornerRadius:    5.0];
    [self.SFTextFonView1.layer setMasksToBounds:   YES];
    [self.SFTextFonView2.layer setBackgroundColor: [[NSColor whiteColor] CGColor]];
    [self.SFTextFonView2.layer setCornerRadius:    5.0];
    [self.SFTextFonView2.layer setMasksToBounds:   YES];
    
    
    ////////////////////////////////////////////////////////////
    // Востановление последнего значения URL'a из настроек
    ////////////////////////////////////////////////////////////
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSURL * restoredSourceUrl = [defaults URLForKey:@"SourceURL"];
    if (restoredSourceUrl) {
        [_SFTextLable1 setStringValue: [restoredSourceUrl path]];
        _URLSource = restoredSourceUrl;
    }
    NSURL * restoredSReceiverURL = [defaults URLForKey:@"ReceiverURL"];
    if (restoredSReceiverURL) {
        [_SFTextLable2 setStringValue: [restoredSReceiverURL path]];
        _URLReceiver = restoredSReceiverURL;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark OutlineView Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Количество Children в элементе
- (NSInteger) outlineView : (NSOutlineView *) outlineView numberOfChildrenOfItem : (nullable id) item
{
    return (!item) ? ([self.filesArray count]) : ([[item childrensArray] count]);
}

// Возвращает дочерний элемент по указанному индексу для данного элемента.
- (id) outlineView : (NSOutlineView *) outlineView child : (NSInteger) index ofItem : (nullable id) item
{
    return (!item) ? ([self.filesArray objectAtIndex: index]) : ([[item childrensArray] objectAtIndex: index]);
}

// Возвращает значение, определяющее, является ли указанный элемент представления структуры расширяемым (папка) или нет
- (BOOL) outlineView : (NSOutlineView *) outlineView isItemExpandable : (id) item
{
    return ([item isFolder]);
}

// Формирует итоговое представление
- (NSView *) outlineView : (NSOutlineView *) outlineView viewForTableColumn : (nullable NSTableColumn *) tableColumn item : (SFFile *) item
{
    ////////////////////////////////////////////////////////////
    // Настройка ячейки
    ////////////////////////////////////////////////////////////
    
    SFTableCellViewFile * myCell = [outlineView makeViewWithIdentifier: tableColumn.identifier owner: self];

    
    ////////////////////////////////////////////////////////////
    // Проход по столбцам для 1 половины
    ////////////////////////////////////////////////////////////
    
    if ([tableColumn.identifier isEqualToString:@"COLUMN_1"])
    {
        [myCell.imageView setImage:       [item sourceIcon]];
        [myCell.textField setTextColor:   [item sourceColor]];
        [myCell.textField setStringValue: [item sourceName]];
    }
    else if ([tableColumn.identifier isEqualToString:@"COLUMN_2"])
    {
        [myCell.textField setTextColor:   [item sourceColor]];
        [myCell.textField setStringValue: [item stringSourceDate]];
    }
    else if ([tableColumn.identifier isEqualToString:@"COLUMN_3"])
    {
        [myCell.textField setTextColor:   [item sourceColor]];
        [myCell.textField setStringValue: [item stringSourceSize]];
    }
    else if ([tableColumn.identifier isEqualToString:@"COLUMN_4"])
    {
        
        [myCell setDelegate: self];
        [myCell.imageView setImage: [item receiverIcon]];
        
        // ---------- Установка значения названия/имени и его цвета ----------//
        [myCell.textField setTextColor:   [item receiverColor]];
        [myCell.textField setStringValue: [item receiverName]];
        
        // ---------- Считывание фрейма для установки смещения внутри папки ----------//
        NSInteger startOffSet = [outlineView levelForItem: item] * [outlineView indentationPerLevel];
        NSRect frameTriangl   = [myCell.trianglBtn frame];
        frameTriangl.origin.x = 21 + startOffSet;
        [myCell.trianglBtn setFrame: frameTriangl];
        
        NSRect frameImage     = [myCell.imageView frame];
        frameImage.origin.x   = 36 + startOffSet;
        [myCell.imageView setFrame: frameImage];
        
        NSRect frameText      = [myCell.textField frame];
        frameText.origin.x    = 58 + startOffSet;
        [myCell.textField setFrame: frameText];
        
        // ---------- Установка информационного статуса ----------//
//        BOOL isImgHidden = NO;
//        if ([item checkboxState] && item.infoState == 1) {
//            [myCell.infoImage setImage: imgDel];
//        }
//        else if ([item checkboxState] && item.infoState == 2) {
//            [myCell.infoImage setImage: imgUpd];
//        }
//        else if (![item checkboxState]) {
//            isImgHidden = YES;
//        }
//        else {
//            [myCell.infoImage setImage: imgAdd];
//        }
//        [myCell.infoImage setHidden: isImgHidden];
        
        if (item.checkboxState == SFCheckboxMixedState && item.infoState != SFFileStateUpdate)
        {
            [myCell.infoImage setImage: _icons[2]];
        }
        else
        {
            [myCell.infoImage setImage: _icons[item.infoState]];
        }
        //[myCell.infoImage setImage: _icons[item.infoState]];
        [myCell.infoImage setHidden: ([item checkboxState] == SFCheckboxOffState)];
       
        // ---------- Настройка Кнопки (треугольничка) раскрытия для ПРИЕМНИКА ----------//
        [myCell.trianglBtn setHidden: !item.isFolder];
        [myCell.trianglBtn setState:  [outlineView isItemExpanded: item]];
        
    }
    else if ([tableColumn.identifier isEqualToString:@"COLUMN_5"])
    {
        [myCell.textField setTextColor:   [item receiverColor]];
        [myCell.textField setStringValue: [item stringReceiverDate]];
    }
    else if ([tableColumn.identifier isEqualToString:@"COLUMN_6"])
    {
        [myCell.textField setTextColor:   [item receiverColor]];
        [myCell.textField setStringValue: [item stringReceiverSize]];
    }
    return myCell;
}

// Установка строки и все сопутствующее к ней
- (NSTableRowView *) outlineView : (NSOutlineView *) outlineView rowViewForItem : (SFFile *) item
{
    SFTableRowView * rowTable = [[SFTableRowView alloc] init];
    [rowTable setDelegate: self];
    
    if ([item isFolder]) {
        [rowTable.checkBox setAllowsMixedState: YES];
    }
    [rowTable.checkBox setState: item.checkboxState];
    
    return rowTable;
}

- (void) outlineViewItemDidExpand : (NSNotification *) notification
{
    [self changeTriangularButtonStateOnNotification: notification];
}


- (void) outlineViewItemDidCollapse : (NSNotification *) notification
{
    [self changeTriangularButtonStateOnNotification: notification];
}

- (void) changeTriangularButtonStateOnNotification : (NSNotification *) notification
{
    
    SFFile * curFile = (SFFile *)[notification.userInfo objectForKey: @"NSObject"];
    NSInteger row    = [self.SFMainOutlineView rowForItem: curFile];
    NSInteger column = [self.SFMainOutlineView columnWithIdentifier:  @"COLUMN_4"];
    
    SFTableCellViewFile * curCell = (SFTableCellViewFile *)[self.SFMainOutlineView viewAtColumn: column row: row makeIfNecessary: NO];
    [curCell.trianglBtn setState: [self.SFMainOutlineView  isItemExpanded: curFile]];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SFTableCellViewFileDelegate
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) triangleButtonClicked : (BOOL) selected atRow : (NSInteger) row
{
    SFFile * curFile = [_SFMainOutlineView itemAtRow: row];
    if (selected) {
        [self.SFMainOutlineView.animator expandItem: curFile];
    }
    else {
        [self.SFMainOutlineView.animator collapseItem: curFile];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SFTableRowViewDelegate
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Обработка нажатия на чекбокс
- (void) checkBoxButtonClickedAtRow : (NSInteger) row andState : (NSInteger) state
{

    SFFile * curFile  = [_SFMainOutlineView itemAtRow: row];
////    curFile.isChecked = (state != -1) ? (state) : (1); //[sender state];
//    [curFile setCheckboxState: (state != SFCheckboxMixedState) ? (state) : (SFCheckboxOnState)];
//    if (curFile.isFolder)
//    {
//        [self updateStateAllItemsCurFolder: curFile];
//    }
//    [self updateStateAllParentFolders: curFile];
    
    [self updateCheckBoxAtFile: curFile andState: state];
    
    [_SFMainOutlineView reloadData];
}

- (void) updateCheckBoxAtFile : (SFFile *) curFile andState : (NSInteger) state
{
    [curFile setCheckboxState: (state != SFCheckboxMixedState) ? (state) : (SFCheckboxOnState)];
    if (curFile.isFolder)
    {
        [self updateStateAllItemsCurFolder: curFile];
    }
    [self updateStateAllParentFolders: curFile];
}

// Одновременная установка одинаковых галочек у элементов папки
- (void) updateStateAllItemsCurFolder : (SFFile *) item
{
    
    if ([item childrensArray]) {
        for (int i = 0; i < [item childrensArray].count; i++)
        {
            SFFile * childFile  = item.childrensArray[i];
//            childFile.isChecked = [item isChecked];
            [childFile setCheckboxState: item.checkboxState];
            
            if (childFile.isFolder) {
                [self updateStateAllItemsCurFolder: childFile];
            }
        }
    }
}

// Установка значения галочки у папки выбранного элемента при одинаковом значении остальных элементов
//          (т.е если все подъэлементы папки имеют одинаковое значение isChecked - установить тоже у папки)
- (void) updateStateAllParentFolders : (SFFile *) curItem
{
    
    SFFile * section = (SFFile *)[self.SFMainOutlineView parentForItem: curItem];
    BOOL trig        = [self allElementsHaveStateEqualStateCurItem: curItem];
    if (section) {
//        section.isChecked = (trig) ? (curItem.isChecked) : (-1);
        //[section setCheckboxState: (trig) ? (curItem.checkboxState) : (SFCheckboxMixedState)];
        if (trig) {
            [section setCheckboxState: curItem.checkboxState];
//            [section setInfoState:     section.oldState];
//            [section setOldState:      SFFileStateBuffer]; // возврат неопределенного значения
        }
        else {
            [section setCheckboxState: SFCheckboxMixedState];
//            [section setOldState:      section.infoState]; // запоминание тек. знач
//            [section setInfoState:     SFFileStateUpdate];
        }
        [self updateStateAllParentFolders: section];
    }
}

// Проверка на одинаковое значение текущего итема и всех остальных папок в этой секции (папке)
- (BOOL) allElementsHaveStateEqualStateCurItem : (SFFile *) curItem {
    SFFile * section = (SFFile *)[self.SFMainOutlineView parentForItem: curItem];
    BOOL trig = YES;
    if (section) {
        for (int i = 0; i < [section childrensArray].count; i++) {
            SFFile * childItem = section.childrensArray[i];
            if (curItem.checkboxState != childItem.checkboxState) {
                trig = NO;
                break;
            }
        }
    }
    return trig;
}

// Здесь происходит обработка изменения цвета:
// идея такая - при добавлении элемента (из источника в приемник), (если у элементов папки изменилось isChecked) - ничего не делать
//              при удалении   элемента (из приемника),            (если у элементов папки изменилось isChecked) - менять section.infoState на 2
//                                                                 (иначе                                      ) - возвращать 1
//- (void) updateVisualityAllChildrenFolders : (SFFile *) curItem {
//    // Если тек элемент является папкой - то в нем могут быть элементы, с состояниями цвета (!), которые нужно сбросить
//    if (curItem.isFolder && [curItem childrensArray].count) {
////        for (int i = 0; i < [curItem childrensArray].count; i++) {
////            SFFile * childFile = curItem.childrensArray[i];
////            [self updateVisualityAllChildrenFolders: childFile];
////        }
//        SFFile * childFile = curItem.childrensArray[0];
//        [self updateVisualityAllChildrenFolders: childFile];
//    }
//    
//    // Само изменения состояний цвета (!)
//    SFFile * section = (SFFile *)[self.SFMainOutlineView parentForItem: curItem];
//    
//    NSLog(@"ret :: %d", (section.infoState == SFFileStateDelete || section.oldState == SFFileStateDelete));
//    if ((section.infoState == SFFileStateDelete || section.oldState == SFFileStateDelete)) {
//        if ([self allElementsHaveStateEqualStateCurItem: curItem]) {
//            [section setInfoState: section.oldState];
//            [section setOldState:  SFFileStateBuffer];
//        }
//        else {
//            [section setOldState:  section.infoState];
//            [section setInfoState: SFFileStateUpdate];
//        }
//    }
//}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Actions & Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction) openSynchronizeFile : (NSButton *) sender {
    
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:          NO];  // Есть ли возможность выбора ФАЙЛОВ
    [panel setCanChooseDirectories:   YES];  // Есть ли возможность выбора КАТАЛОГОВ
    [panel setAllowsMultipleSelection: NO];  // Выбор нескольких каталогов
    
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        
        if ([sender.identifier isEqualToString: @"OPEN_BUTTON_1"]) {
            
            _URLSource = [panel URL];
            [_SFTextLable1 setStringValue: [[panel URL] path]];
            [defaults setURL: [panel URL] forKey:@"SourceURL"];
            [defaults synchronize];
        }
        else if ([sender.identifier isEqualToString: @"OPEN_BUTTON_2"]) {
            
            _URLReceiver = [panel URL];
            [_SFTextLable2 setStringValue: [[panel URL] path]];
            [defaults setURL: [panel URL] forKey:@"ReceiverURL"];
            [defaults synchronize];
        }
        // Сбрасываю все то, что есть в таблице
        if (_filesArray != [NSMutableArray new]) {
            _filesArray = [NSMutableArray new];
            [self setValue: @(NO) forKey: @"isSynchronizePossible"];
            [_SFMainOutlineView reloadData];
        }
    }
}

// Обработка нажатия на кнопку замены мест УРЛов ИСТОЧНИКА и ПРИЁМНИКА
- (IBAction) reverseButtonOnClick : (NSButton *) sender {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    // Инверсия мест
    NSURL * transitionalURL = _URLReceiver;
    _URLReceiver = _URLSource;
    _URLSource   = transitionalURL;
    
    // Обновление SFTextLable
    [_SFTextLable1 setStringValue: [_URLSource path]];
    [_SFTextLable2 setStringValue: [_URLReceiver path]];
    [defaults setURL: _URLSource   forKey: @"SourceURL"];
    [defaults setURL: _URLReceiver forKey: @"ReceiverURL"];
    [defaults synchronize];
    
    // Сброс содержимого таблицы
    _filesArray = [NSMutableArray new];
    [self setValue: @(NO) forKey: @"isSynchronizePossible"];
    [_SFMainOutlineView reloadData];
}


// Кнопка Режим детального Сопоставления в Тулбаре
- (IBAction) detailMode : (NSToolbarItem *) sender {
    //_isAccumulationMode
    [self setValue: @(!_isDetail) forKey: @"isDetail"];
    if (_isDetail) {
        [sender setImage: _imgDetail];
    } else {
        [sender setImage: _imgNoDetail];
    }
}

// Кнопка "Начала Сличения" в Тулбаре
- (IBAction) matchStartComparison : (NSToolbarItem *) sender {
    [self _startComparison];
}

// Кнопка "Выделить все" в Тулбаре
- (IBAction) checkAllItem : (NSToolbarItem *) sender {
//    NSLog(@"checkAllItem %ld", (long)[_SFMainOutlineView numberOfRows]);
    for (NSInteger row = 0; row < [_SFMainOutlineView numberOfRows]; row++) {
        
        SFFile * curFile  = [_SFMainOutlineView itemAtRow: row];
        
        [self updateCheckBoxAtFile: curFile andState: SFCheckboxOnState];
    }
    
    [_SFMainOutlineView reloadData];
}

// Кнопка "Снять все" в Тулбаре
- (IBAction) unCheckAllItem : (NSToolbarItem *) sender {
//    NSLog(@"unCheckAllItem %ld", (long)[_SFMainOutlineView numberOfRows]);
    for (NSInteger row = 0; row < [_SFMainOutlineView numberOfRows]; row++) {
        
        SFFile * curFile  = [_SFMainOutlineView itemAtRow: row];
        
        [self updateCheckBoxAtFile: curFile andState: SFCheckboxOffState];
    }
    
    [_SFMainOutlineView reloadData];
}

// Начало синхронизации
- (void) _startComparison {
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSDate *start = [NSDate date];
    NSLog(@"start %f", [start timeIntervalSinceNow]);
    
    if (_URLReceiver && _URLSource && _URLReceiver != _URLSource &&
        [fileManager fileExistsAtPath: [_URLReceiver path]] &&
        [fileManager fileExistsAtPath: [_URLSource path]]) {        // Если оба УРЛа указаны и они есть в файловой системе и они не равны то...
        
        // Bindings значение состояния кнопки "Сопоставить"
        [self setValue: @(NO) forKey: @"isToolButtonEnabled"];
        // настройка ПрогрессБара
        [self fadeInView: self.ProgressComparison];
        [self.ProgressComparison setMinValue:    0.0];
        [self.ProgressComparison setDoubleValue: 0.0];
        
        if (_filesArray != [NSMutableArray new]) {
            _filesArray = [NSMutableArray new];
            [self setValue: @(NO) forKey: @"isSynchronizePossible"];
        }
        // организация многопоточности (2ого потока)
        __block NSInteger totalCount = 0;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            
            totalCount = [self calculateCountItems];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                // установка и обновление ПрогрессБара в main потоке
                [self.ProgressComparison setMaxValue: totalCount];
            });
            // вызов "сопоставления"
            NSMutableArray * array = _filesArray;
            [self comparisonTwoPathsWithURLSourceFile: _URLSource andURLReceiverFile: _URLReceiver withFillArray: &array];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                // итоговое взаимодействие с элементами интерфейса в main потоке
                [self setValue: @(YES) forKey: @"isToolButtonEnabled"];
                [self setValue: ([self.filesArray count] && _isToolButtonEnabled) ? (@(YES)) : (@(NO)) forKey: @"isSynchronizePossible"];
                
                [_SFMainOutlineView reloadData];
                [self fadeOutView: self.ProgressComparison];
                NSLog(@"end 2 %f", [start timeIntervalSinceNow]);
            });
        });
    }
    
    
//    
//    2024-04-21 18:39:17.356 SynchronizeFileManager[4030:1673786] start -0.000002
//    2024-04-21 18:39:17.357 SynchronizeFileManager[4030:1673786] end 1 -0.001383
//    2024-04-21 18:57:37.337 SynchronizeFileManager[4030:1673786] end 2 -1099.981348
    
//    2024-04-21 19:01:07.284 SynchronizeFileManager[4081:1686325] start -0.000001
//    2024-04-21 19:01:07.286 SynchronizeFileManager[4081:1686325] end 1 -0.001267
//    2024-04-21 19:01:08.264 SynchronizeFileManager[4081:1686325] end 2 -0.980024

//    2024-05-21 23:25:20.016 SynchronizeFileManager[6461:1963315] start -0.000001
//    2024-05-21 23:25:20.962 SynchronizeFileManager[6461:1963315] end 2 -0.945598
//    2024-05-21 23:25:43.024 SynchronizeFileManager[6461:1963315] start -0.000001
//    2024-05-21 23:34:05.957 SynchronizeFileManager[6461:1963315] end 2 -502.933764


}

// Начало "Синхронизации" - Здесь происходит формирование массива с данными, которые я кину в отдельное окно
- (IBAction) matchStartSynchronize : (NSToolbarItem *) sender {

    NSLog(@"[self.filesArray count] == %@", self.filesArray);
    if ([self.filesArray count] && self.isSynchronizePossible) {
        [self setValue: @(NO) forKey: @"isSynchronizePossible"];
        
        NSMutableArray * arrayFilesSynchronization = [NSMutableArray new];
        long long fullSize = 0;
        
        for (int i = 0; i < [self.filesArray count]; i++) {
            SFFile * curFile = self.filesArray[i];
            NSLog(@"[SFFile] sourceURL == %@", [curFile.sourceURL path]);
            NSLog(@"[SFFile] receiverURL == %@", [curFile.receiverURL path]);
            
            if (curFile.checkboxState != SFCheckboxOffState) {
                fullSize += [self _synchronizeFile: curFile toArray: &arrayFilesSynchronization];
            }
        }
        
        NSLog(@"[arrayFilesSynchronization] == %@", arrayFilesSynchronization);
//        NSLog(@"[arrayFilesSynchronization] == %@", [((SFFile *)arrayFilesSynchronization[0]).sourceURL path]);
//        NSLog(@"[arrayFilesSynchronization] == %@", [((SFFile *)arrayFilesSynchronization[0]).receiverURL path]);
        
        //
        // В NSFileManager найти 3 функции, отвечающие за копирование/удаление
        // Подсчитывать общий размер
//        NSLog(@"fullSize :: %lld", fullSize);
//        NSLog(@"fullSize str :: %@", [NSByteCountFormatter stringFromByteCount: fullSize countStyle: NSByteCountFormatterCountStyleFile]);
//        for (int i = 0; i < [arrayFilesSynchronization count]; i++) {
//            SFFile * childFile = arrayFilesSynchronization[i];
//            NSLog(@"array item :: %@ - %@", [childFile sourceName], [childFile receiverName]);
//            NSLog(@"array item :: %@ - %@ - %lld", [childFile stringSourceSize], [childFile stringReceiverSize], [childFile sizeOfFile]);
//        }
        
        NSError * error = nil;
        NSDictionary * fileAttr = [[NSFileManager defaultManager] attributesOfFileSystemForPath:_URLReceiver.path error:&error];
        unsigned long long freeSpace = [[fileAttr objectForKey: NSFileSystemFreeSize] longLongValue];
//        NSLog(@"freeSpace==== %lld - %lld", fullSize, freeSpace);
        
        if (fullSize >= freeSpace) {
//            NSLog(@"fullSize - freeSpace :: %lld  >=  %lld", fullSize, freeSpace);
            
//            NSAlert *alert = [NSAlert alertWithMessageText:@"Delete the record?"
//                                             defaultButton:@"OK" alternateButton:@"Cancel"
//                                               otherButton:nil informativeTextWithFormat:
//                              @"Deleted records cannot be restored."];
            
            NSAlert *alert = [[NSAlert alloc] init];
            
            [alert addButtonWithTitle:@"Continue"];
            [alert addButtonWithTitle:@"Cancel"];
            [alert setMessageText:@"Недостаточно места на диске-приемнике."];
            [alert setInformativeText:@"Вы уверены, что хотите продолжить и перенести только чать файлов?"];
            [alert setIcon:_icons[SFFileStateDelete]];
            
            [alert setAlertStyle:NSWarningAlertStyle];
            
            if ([alert runModal] == NSAlertFirstButtonReturn) {
                [self _startLoadingWinControllerWithArr: arrayFilesSynchronization andFileSize: fullSize];
            }
            else {
                [self setValue: @(YES) forKey: @"isSynchronizePossible"];
            }
            
//            [alert release];
        }
        else if ([arrayFilesSynchronization count] > 0) {
            [self _startLoadingWinControllerWithArr: arrayFilesSynchronization andFileSize: fullSize];
        }
        else {
            [self setValue: @(YES) forKey: @"isSynchronizePossible"];
        }
    }
}

- (void) _startLoadingWinControllerWithArr : (NSMutableArray *) arrayFilesSynchronization andFileSize : (long long) fullSize {
    
    
    // Вызов другого контроллера
//    _loadingWinController = [[SFLoadingWindowsController alloc] initWithWindowNibName: @"SFLoadingWindowsController"];
    
//    if (_loadingWinController == nil) {
//        _loadingWinController = [[SFLoadingWindowsController alloc] initWithWindowNibName: @"SFLoadingWindowsController"];
//    }
    
    _loadingWinController = [[SFLoadingWindowsController alloc] initWithWindowNibName: @"SFLoadingWindowsController"];
    _loadingWinController.curSize             = fullSize;
    _loadingWinController.URLReceiver         = _URLReceiver;
    _loadingWinController.URLSource           = _URLSource;
    _loadingWinController.curArraySynchronize = [arrayFilesSynchronization copy];
    [((SFWindow *)(_loadingWinController.window)) setController: _loadingWinController];
    
    [_loadingWinController.window makeKeyAndOrderFront: self];
    [_loadingWinController.window center];
    [NSApp runModalForWindow: _loadingWinController.window];
    
    [self performSelector:@selector(_startComparison) withObject:NULL afterDelay:0.5];
    //        [self _startComparison];
    
    //        //- (void)beginSheet:(NSWindow *)sheetWindow completionHandler:(void (^ __nullable)(NSModalResponse returnCode))handler NS_AVAILABLE_MAC(10_9);
    //        [NSApp beginSheet: _loadingWinController.window completionHandler:^(NSModalResponse returnCode) {
    //            switch (returnCode) {
    //
    //                case NSModalResponseCancel:
    //                    NSLog(@"%@", @"NSModalResponseCancel");
    //                    break;
    //
    //                case NSModalResponseOK:
    //                    NSLog(@"%@", @"NSModalResponseOK");
    //                    break;
    //
    //                default:
    //                    break;
    //            }
    //        }];
    //[self _finalFileTransferWithArray: arrayFilesSynchronization andSize: fullSize];
}

// Добавление в массив (с файлами для синхронизации) текущего файла, возврат его размера
- (long long) _synchronizeFile : (SFFile *) curFile toArray : (NSMutableArray **) curArray {
    // Здесь должно быть формирование массива с данными, которые я кину в отдельное окно
    long long curSize = 0;
    
    if (curFile.checkboxState == SFCheckboxOnState) {
        [*curArray addObject: curFile];
        curSize = curFile.sizeOfFile;
    }
    else if (curFile.isFolder && [curFile.childrensArray count] && curFile.checkboxState != SFCheckboxOffState) {
        for (int i = 0; i < [curFile.childrensArray count]; i++) {
            SFFile * childFile = curFile.childrensArray[i];
            
            if (childFile.checkboxState != SFCheckboxOffState) {
                curSize += [self _synchronizeFile: childFile toArray: curArray];
            }
        }
    }
    
    NSLog(@"[SFFile0] sourceURL == %@", [curFile.sourceURL path]);
    NSLog(@"[SFFile0] receiverURL == %@", [curFile.receiverURL path]);
    return curSize;
}


///////////////////////////////////////!!!!!!!!!

// Function
CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath, size_t chunkSizeForReadingData) {
    
//    // Declare needed variables
    CFStringRef result = NULL;
//    CFReadStreamRef readStream = NULL;
    
//    NSLog(@"filePath - %@ &&& size_t - %zu", filePath, chunkSizeForReadingData);
    
    // Get the file URL
//    CFURLRef fileURL =
//    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
//                                  (CFStringRef)filePath,
//                                  kCFURLPOSIXPathStyle,
//                                  (Boolean)false);
//    if (!fileURL) goto done;
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                                     (CFStringRef)filePath,
                                                     kCFURLPOSIXPathStyle,
                                                     (Boolean)false);
    CFReadStreamRef readStream = fileURL ? CFReadStreamCreateWithFile(kCFAllocatorDefault, fileURL) : NULL;
    BOOL didSucceed = readStream ? (BOOL)CFReadStreamOpen(readStream) : NO;
    
    if (didSucceed) {
    
//    // Create and open the read stream
//    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
//                                            (CFURLRef)fileURL);
//    if (!readStream) goto done;
//    bool didSucceed = (bool)CFReadStreamOpen(readStream);
//    if (!didSucceed) goto done;
    
        // Initialize the hash object
        CC_MD5_CTX hashObject;
        CC_MD5_Init(&hashObject);
    
        // Make sure chunkSizeForReadingData is valid
        if (!chunkSizeForReadingData) {
            chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
        }
    
        // Feed the data to the hash object
        bool hasMoreData = true;
        while (hasMoreData) {
            uint8_t buffer[chunkSizeForReadingData];
        
//            NSLog(@"buffer - %s &&& readStream - %@", buffer, readStream);
        
            CFIndex readBytesCount = CFReadStreamRead(readStream, (UInt8 *)buffer, (CFIndex)sizeof(buffer));
            if (readBytesCount == -1) {
                break;
            } else if (readBytesCount == 0) {
                hasMoreData = false;
                continue;
            }
            
            CC_MD5_Update(&hashObject, (const void *)buffer, (CC_LONG)readBytesCount);
        }
    
        // Check if the read operation succeeded
        didSucceed = !hasMoreData;
    
        // Compute the hash digest
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5_Final(digest, &hashObject);
    
        // Abort if the read operation failed
//    if (!didSucceed) goto done;
    
        // Compute the string result
        char hash[2 * sizeof(digest) + 1];
        for (size_t i = 0; i < sizeof(digest); ++i) {
            snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
        }
        result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
    
//done:
    }
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}

//+ (NSData *)sha256:(NSData *)data {
//    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
//    if (CC_SHA256([data bytes], [data length], hash)) {
//        NSData * sha256 = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
//        return sha256;
//    }
//    return nil;
//}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Comparison
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Подсчет количество ВСЕХ элементов папки (вкл. подпапки и их содержимое)
- (NSInteger) calculateCountItems {
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator * totalSubpaths1 = [fileManager enumeratorAtURL: _URLSource   includingPropertiesForKeys: nil options: NSDirectoryEnumerationSkipsHiddenFiles errorHandler: nil];
    NSDirectoryEnumerator * totalSubpaths2 = [fileManager enumeratorAtURL: _URLReceiver includingPropertiesForKeys: nil options: NSDirectoryEnumerationSkipsHiddenFiles errorHandler: nil];
    
    return [[totalSubpaths1 allObjects] count] + [[totalSubpaths2 allObjects] count];
}

// Основная процедура СОПОСТАВЛЕНИЯ
- (BOOL) comparisonTwoPathsWithURLSourceFile : (NSURL *) curSourceURL andURLReceiverFile : (NSURL *) curReceiverURL withFillArray : (NSMutableArray **) fillArray { // работа с указателем, обращаться через *
    
    ////////////////////////////////////////////////////////////
    // Получение отсортированных массивов для сличения
    ////////////////////////////////////////////////////////////
//    NSMutableArray * sourceFilesArray   = [self formingSortedArrayByURL: curSourceURL];     // Массив словарей ИСТОЧНИКОВ
//    NSMutableArray * receiverFilesArray = [self formingSortedArrayByURL: curReceiverURL];   // Массив словарей ПРИЁМНИКОВ
    
    NSArray * sourceURLsArray = [self formingArrayByURL: curSourceURL];
    NSArray * receiverURLsArray = [self formingArrayByURL: curReceiverURL];
    
    NSMutableArray * sourceFilesArray = [NSMutableArray new];     // Массив словарей ИСТОЧНИКОВ
    NSMutableArray * receiverFilesArray = [NSMutableArray new];   // Массив словарей ПРИЁМНИКОВ
    
    if (_isDetail) {
        sourceFilesArray   = [self formingSortedArrayByURLOrderDate: sourceURLsArray];
        receiverFilesArray = [self formingSortedArrayByURLOrderDate: receiverURLsArray];
    }
    else {
        sourceFilesArray   = [self formingSortedArrayByURLOrderName: sourceURLsArray];
        receiverFilesArray = [self formingSortedArrayByURLOrderName: receiverURLsArray];
    }
    
    ////////////////////////////////////////////////////////////
    // Если в sourceFilesArray есть элементы
    ////////////////////////////////////////////////////////////
    
    BOOL isModifiedFolder = NO;
//    NSFileManager  * fileManager = [NSFileManager defaultManager];
    
    while (sourceFilesArray.count) {
        
        // ---------- Получение имени ----------//
        NSString * sourceName  = [[sourceFilesArray objectAtIndex: 0] objectForKey: @"name"];
        NSString * receiveName = (receiverFilesArray.count) ? ([[receiverFilesArray objectAtIndex: 0] objectForKey: @"name"]) : (nil);
        
        
//        NSLog(@"count - %lu", (unsigned long)sourceFilesArray.count);
//        NSLog(@"sourceName - %@", sourceName);
//        NSLog(@"receiveName - %@", receiveName);
//        
        NSURL * sourceURL  = [[sourceFilesArray objectAtIndex: 0] objectForKey: @"url"];
        NSURL * receiveURL = (receiverFilesArray.count) ? ([[receiverFilesArray objectAtIndex: 0] objectForKey: @"url"]) : (nil);
        
//        BOOL isFileHere = [fileManager contentsEqualAtPath:sourceURL.path andPath:receiveURL.path];
        double incrVal = 1.0;
        BOOL isFindFile = NO;
        
        
        ////////////////////////////////////////////////////////////
//        хэш
//        
//        for (int i = 0; i < receiverFilesArray.count; i++) {
//            
//            NSURL * newReceiveURL = [[receiverFilesArray objectAtIndex: i] objectForKey: @"url"];
//            if (_isDetail) {
//                BOOL isCurFileHere = [fileManager contentsEqualAtPath:sourceURL.path andPath:newReceiveURL.path];
//                
//                if (isCurFileHere) {
//                    isFindFile = YES;
//                    
//                    isModifiedFolder = [self processingURLSourceFile: sourceURL andURLReceiverFile: newReceiveURL withFillArray: fillArray];
//                    
//                    [sourceFilesArray   removeObjectAtIndex: 0];
//                    [receiverFilesArray removeObjectAtIndex: i];
//                    incrVal = 2.0;
//                    
//                    break;
//                }
//            } else {
//                
//                NSData * oldData = [NSData dataWithContentsOfFile:sourceURL.path];
//                NSData * newData = [NSData dataWithContentsOfFile:newReceiveURL.path];
//                
//                unsigned char result[CC_MD5_DIGEST_LENGTH];
//                CC_MD5([oldData bytes], (CC_LONG)[oldData length], result);
//                
//                NSString * s1 = [NSString stringWithFormat:
//                      @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
//                      result[0], result[1], result[2], result[3],
//                      result[4], result[5], result[6], result[7],
//                      result[8], result[9], result[10], result[11],
//                      result[12], result[13], result[14], result[15]
//                      ];
//                
//                CC_MD5([newData bytes], (CC_LONG)[newData length], result);
//                NSString * s2 = [NSString stringWithFormat:
//                      @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
//                      result[0], result[1], result[2], result[3],
//                      result[4], result[5], result[6], result[7],
//                      result[8], result[9], result[10], result[11],
//                      result[12], result[13], result[14], result[15]
//                      ];
//                
//                if ([s1 isEqualToString: s2] && s1 != nil) {
//                    // ХЭШИ - совпали
//                    
//                    isFindFile = YES;
//                    
//                    isModifiedFolder = [self processingURLSourceFile: sourceURL andURLReceiverFile: newReceiveURL withFillArray: fillArray];
//                    
//                    [sourceFilesArray   removeObjectAtIndex: 0];
//                    [receiverFilesArray removeObjectAtIndex: 0];
//                    incrVal = 2.0;
//                    
//                    break;
//                }
//            }
//        }


        ////////////////////////////////////////////////////////////
        
        NSDate * sourceDate  = [[sourceFilesArray objectAtIndex: 0] objectForKey: @"date"];
        
//        NSLog(@"sourceURL.path - %@", sourceURL.path);
//        NSDate * receiveDate = (receiverFilesArray.count) ? ([[receiverFilesArray objectAtIndex: 0] objectForKey: @"date"]) : (nil);
        
        // Проверка того, есть ли файл - update
        if (_isDetail) {
            for (int i = 0; i < receiverFilesArray.count; i++) {
                NSDate * newReceiveDate = [[receiverFilesArray objectAtIndex: i] objectForKey: @"date"];
                
                if ([sourceDate compare:newReceiveDate] == NSOrderedDescending) {
                    break;
                }
                
                NSURL * newReceiveURL = [[receiverFilesArray objectAtIndex: i] objectForKey: @"url"];
//                BOOL isCurFileHere = [fileManager contentsEqualAtPath:sourceURL.path andPath:newReceiveURL.path];
                
                
//                NSLog(@"newReceiveURL.path - %@", newReceiveURL.path);
                
                
                NSData * oldData = [NSData dataWithContentsOfFile:sourceURL.path];
                NSData * newData = [NSData dataWithContentsOfFile:newReceiveURL.path];
                
                unsigned char result[CC_MD5_DIGEST_LENGTH];
                CC_MD5([oldData bytes], (CC_LONG)[oldData length], result);
                
                NSString * s1 = [NSString stringWithFormat:
                        @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        result[0], result[1], result[2], result[3],
                        result[4], result[5], result[6], result[7],
                        result[8], result[9], result[10], result[11],
                        result[12], result[13], result[14], result[15]
                    ];
                
                CC_MD5([newData bytes], (CC_LONG)[newData length], result);
                NSString * s2 = [NSString stringWithFormat:
                        @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        result[0], result[1], result[2], result[3],
                        result[4], result[5], result[6], result[7],
                        result[8], result[9], result[10], result[11],
                        result[12], result[13], result[14], result[15]
                    ];
                
                if ([s1 isEqualToString: s2] && s1 != nil) {
                    // ХЭШИ - совпали
                    
                    isFindFile = YES;
                    
                    isModifiedFolder = isModifiedFolder || [self processingURLSourceFile: sourceURL andURLReceiverFile: newReceiveURL withFillArray: fillArray];
                                    
                    [sourceFilesArray   removeObjectAtIndex: 0];
                    [receiverFilesArray removeObjectAtIndex: i];
                    incrVal = 2.0;
                                    
                    break;
                }
                
//                if (isCurFileHere) {
//                    // если файл найден - то обновить (.infoState = 2)
//                    isFindFile = YES;
//                    
//                    isModifiedFolder = [self processingURLSourceFile: sourceURL andURLReceiverFile: newReceiveURL withFillArray: fillArray];
//                    
//                    //                // ---------- Считывание размера файла ----------//
//                    //                NSNumber * sourceSizeValue  = nil;
//                    //                NSNumber * receiveSizeValue = nil;
//                    //                [sourceURL getResourceValue: &sourceSizeValue
//                    //                                     forKey: NSURLFileSizeKey
//                    //                                      error: nil];
//                    //                [newReceiveURL getResourceValue: &receiveSizeValue
//                    //                                      forKey: NSURLFileSizeKey
//                    //                                       error: nil];
//                    //
//                    //                // ---------- Считывание даты файла ----------//
//                    //                NSDate * sourceDateValue  = nil;
//                    //                NSDate * receiveDateValue = nil;
//                    //                [sourceURL getResourceValue: &sourceDateValue
//                    //                                     forKey: NSURLContentModificationDateKey
//                    //                                      error: nil];
//                    //                [newReceiveURL getResourceValue: &receiveDateValue
//                    //                                      forKey: NSURLContentModificationDateKey
//                    //                                       error: nil];
//                    //
//                    //                // Если это папка - проверяем ее элементы
//                    //                if ([sourceURL hasDirectoryPath] || [newReceiveURL hasDirectoryPath]) {        // Если это папка - проверяем ее элементы
//                    //                    SFFile * mainFile  = [[SFFile alloc] initWithURLSourceFile: sourceURL
//                    //                                                            andURLReceiverFile: newReceiveURL];
//                    //                    [mainFile setInfoState: SFFileStateUpdate];
//                    //
//                    //                    NSMutableArray * array = [NSMutableArray new]; //mainFile.childrensArray;
//                    //                    isModifiedFolder = [self comparisonTwoPathsWithURLSourceFile: sourceURL andURLReceiverFile: newReceiveURL withFillArray: &array];
//                    //                    [mainFile setChildrensArray: [array copy]];
//                    //
//                    //                    if (isModifiedFolder) {
//                    //                        [*fillArray addObject: mainFile];
//                    //                        //isModifiedFolder = YES;
//                    //                    }
//                    //                }
//                    //                else if (sourceSizeValue != receiveSizeValue ||
//                    //                         ![[sourceURL lastPathComponent] isEqualToString: [newReceiveURL lastPathComponent]] ||
//                    //                         [sourceDateValue compare: receiveDateValue] != NSOrderedSame) {    // Если это НЕ папка (файл) - проверяем различия
//                    //                    
//                    //                    SFFile * mainFile  = [[SFFile alloc] initWithURLSourceFile: sourceURL andURLReceiverFile: newReceiveURL];
//                    //                    [mainFile setInfoState: SFFileStateUpdate];
//                    //                    
//                    //                    [*fillArray addObject: mainFile];
//                    //                    isModifiedFolder = YES;
//                    //                }
//                    
//                    [sourceFilesArray   removeObjectAtIndex: 0];
//                    [receiverFilesArray removeObjectAtIndex: i];
//                    incrVal = 2.0;
//                    
//                    break;
//                }
            }
        }
        
        
        ////////////////////////////////////////////////////////////
        
        if (!isFindFile && _isDetail) {
            
//            NSLog(@"SFFileStateAdd ** sourceURL.path - %@", [sourceURL.path lastPathComponent]);
//            NSLog(@"SFFileStateAdd ** receiveURL.path - %@", [receiveURL.path lastPathComponent]);
            
            
            SFFile * mainFile  = [[SFFile alloc] initWithURLSourceFile: sourceURL andURLReceiverFile: nil];
            [mainFile setInfoState: SFFileStateAdd];
            if (mainFile.isFolder) {
                //                NSMutableArray * array = mainFile.childrensArray;
                //                [self comparisonTwoPathsWithURLSourceFile: sourceURL andURLReceiverFile: nil withFillArray: &array];
                NSMutableArray * array = [NSMutableArray new]; //mainFile.childrensArray;
                [self comparisonTwoPathsWithURLSourceFile: sourceURL andURLReceiverFile: nil withFillArray: &array];
                [mainFile setChildrensArray: [array copy]];
                
                [mainFile setSizeOfFile:[self _calculateSizeOfFileByArr:array]];
                [mainFile setSizeOfSourceFile:[self _calculateSourceSizeOfFileByArr:array]];
                [mainFile setStringSourceSize:[NSByteCountFormatter stringFromByteCount: mainFile.sizeOfSourceFile countStyle: NSByteCountFormatterCountStyleFile]];
            }
            [*fillArray addObject: mainFile];
            isModifiedFolder = YES;
            [sourceFilesArray removeObjectAtIndex: 0];
            
        } else if (!_isDetail) {
            
            ////////////////////////////////////////////////////////////
            // Проверка порядка:
            //      Если строка из _sourceFilesArray > строки из _receiverFilesArray - значит (1) - в приемнике нет подходящего файла для тек в источнике - убрать файл в источнике (.infoState = 0)
            //      Если строка из _sourceFilesArray < строки из _receiverFilesArray - значит (2) - в источнике нет подходящего файла для тек в приемнике - убрать файл в приемнике (.infoState = 1)
            //      Если строка из _sourceFilesArray = строки из _receiverFilesArray - значит (3) - оба файла есть - углубленно проверить на различие других свойств                (.infoState = 2 или = 0)
            ////////////////////////////////////////////////////////////
            
            if (receiveName == nil || [sourceName caseInsensitiveCompare: receiveName] == NSOrderedAscending) {     // (1)
                
                SFFile * mainFile  = [[SFFile alloc] initWithURLSourceFile: sourceURL andURLReceiverFile: nil];
                [mainFile setInfoState: SFFileStateAdd];
                if (mainFile.isFolder) {
                    //                NSMutableArray * array = mainFile.childrensArray;
                    //                [self comparisonTwoPathsWithURLSourceFile: sourceURL andURLReceiverFile: nil withFillArray: &array];
                    NSMutableArray * array = [NSMutableArray new]; //mainFile.childrensArray;
                    [self comparisonTwoPathsWithURLSourceFile: sourceURL andURLReceiverFile: nil withFillArray: &array];
                    [mainFile setChildrensArray: [array copy]];
                    
                    [mainFile setSizeOfFile:[self _calculateSizeOfFileByArr:array]];
                    [mainFile setSizeOfSourceFile:[self _calculateSourceSizeOfFileByArr:array]];
                    [mainFile setStringSourceSize:[NSByteCountFormatter stringFromByteCount: mainFile.sizeOfSourceFile countStyle: NSByteCountFormatterCountStyleFile]];
                }
                [*fillArray addObject: mainFile];
                isModifiedFolder = YES;
                [sourceFilesArray removeObjectAtIndex: 0];
            }
            else if ([sourceName caseInsensitiveCompare: receiveName] == NSOrderedDescending) {               // (2)
                
                SFFile * mainFile  = [[SFFile alloc] initWithURLSourceFile: nil andURLReceiverFile: receiveURL];
                [mainFile setInfoState: SFFileStateDelete];
                if (mainFile.isFolder) {
                    //                NSMutableArray * array = mainFile.childrensArray;
                    //                [self comparisonTwoPathsWithURLSourceFile: nil andURLReceiverFile: receiveURL withFillArray: &array];
                    NSMutableArray * array = [NSMutableArray new]; //mainFile.childrensArray;
                    [self comparisonTwoPathsWithURLSourceFile: nil andURLReceiverFile: receiveURL withFillArray: &array];
                    [mainFile setChildrensArray: [array copy]];
                    
                    [mainFile setSizeOfFile:[self _calculateSizeOfFileByArr:array]];
                    [mainFile setSizeOfReceiverFile:[self _calculateReceiverSizeOfFileByArr:array]];
                    [mainFile setStringReceiverSize:[NSByteCountFormatter stringFromByteCount: mainFile.sizeOfReceiverFile countStyle: NSByteCountFormatterCountStyleFile]];
                }
                [*fillArray addObject: mainFile];
                isModifiedFolder = YES;
                [receiverFilesArray removeObjectAtIndex: 0];
            }
            else {                                                                                                  // (3)
                isModifiedFolder = [self processingURLSourceFile: sourceURL andURLReceiverFile: receiveURL withFillArray: fillArray] || isModifiedFolder;
                
                [sourceFilesArray   removeObjectAtIndex: 0];
                [receiverFilesArray removeObjectAtIndex: 0];
                incrVal = 2.0;
            }

        }
//    
//        ////////////////////////////////////////////////////////////
//        // Проверка порядка:
//        //      Если строка из _sourceFilesArray > строки из _receiverFilesArray - значит (1) - в приемнике нет подходящего файла для тек в источнике - убрать файл в источнике (.infoState = 0)
//        //      Если строка из _sourceFilesArray < строки из _receiverFilesArray - значит (2) - в источнике нет подходящего файла для тек в приемнике - убрать файл в приемнике (.infoState = 1)
//        //      Если строка из _sourceFilesArray = строки из _receiverFilesArray - значит (3) - оба файла есть - углубленно проверить на различие других свойств                (.infoState = 2 или = 0)
//        ////////////////////////////////////////////////////////////
//        
//        if (!_isDetail && (receiveName == nil || [sourceName caseInsensitiveCompare: receiveName] == NSOrderedAscending)) {     // (1)
//            
//            // перед тем как убирать - проверить хэши
//            
//            SFFile * mainFile  = [[SFFile alloc] initWithURLSourceFile: sourceURL andURLReceiverFile: nil];
//            [mainFile setInfoState: SFFileStateAdd];
//            if (mainFile.isFolder) {
////                NSMutableArray * array = mainFile.childrensArray;
////                [self comparisonTwoPathsWithURLSourceFile: sourceURL andURLReceiverFile: nil withFillArray: &array];
//                NSMutableArray * array = [NSMutableArray new]; //mainFile.childrensArray;
//                [self comparisonTwoPathsWithURLSourceFile: sourceURL andURLReceiverFile: nil withFillArray: &array];
//                [mainFile setChildrensArray: [array copy]];
//            }
//            [*fillArray addObject: mainFile];
//            isModifiedFolder = YES;
//            [sourceFilesArray removeObjectAtIndex: 0];
//        }
//        else if (!_isDetail && ((long)[sourceName caseInsensitiveCompare: receiveName] == NSOrderedDescending)) {               // (2)
//            
//            SFFile * mainFile  = [[SFFile alloc] initWithURLSourceFile: nil andURLReceiverFile: receiveURL];
//            [mainFile setInfoState: SFFileStateDelete];
//            if (mainFile.isFolder) {
////                NSMutableArray * array = mainFile.childrensArray;
////                [self comparisonTwoPathsWithURLSourceFile: nil andURLReceiverFile: receiveURL withFillArray: &array];
//                NSMutableArray * array = [NSMutableArray new]; //mainFile.childrensArray;
//                [self comparisonTwoPathsWithURLSourceFile: nil andURLReceiverFile: receiveURL withFillArray: &array];
//                [mainFile setChildrensArray: [array copy]];
//            }
//            [*fillArray addObject: mainFile];
//            isModifiedFolder = YES;
//            [receiverFilesArray removeObjectAtIndex: 0];
//        }
//        else if (!_isDetail) {                                                                                                  // (3)
//
////            // ---------- Считывание размера файла ----------//
////            NSNumber * sourceSizeValue  = nil;
////            NSNumber * receiveSizeValue = nil;
////            [sourceURL getResourceValue: &sourceSizeValue
////                                 forKey: NSURLFileSizeKey
////                                  error: nil];
////            [receiveURL getResourceValue: &receiveSizeValue
////                                  forKey: NSURLFileSizeKey
////                                   error: nil];
////            
////            // ---------- Считывание даты файла ----------//
////            NSDate * sourceDateValue  = nil;
////            NSDate * receiveDateValue = nil;
////            [sourceURL getResourceValue: &sourceDateValue
////                                 forKey: NSURLContentModificationDateKey
////                                  error: nil];
////            [receiveURL getResourceValue: &receiveDateValue
////                                  forKey: NSURLContentModificationDateKey
////                                   error: nil];
//////
//////            // ---------- Итоговое сравнение ----------//
////////            if ([sourceURL hasDirectoryPath] != [receiveURL hasDirectoryPath]) {
////////                SFFile * mainFile  = [[SFFile alloc] initWithURLSourceFile: ([sourceURL  hasDirectoryPath]) ? (nil) : (sourceURL)        // потому что легче удалить НЕ рекурсию (т.е файл)
////////                                                        andURLReceiverFile: ([receiveURL hasDirectoryPath]) ? (nil) : (receiveURL)];
////////                mainFile.infoState = ([sourceURL hasDirectoryPath]) ? (SFFileStateDelete) : (SFFileStateAdd);
////////                //[mainFile setInfoState: [sourceURL hasDirectoryPath]]; //??
////////                [*fillArray addObject: mainFile];
////////                ([sourceURL hasDirectoryPath]) ? ([receiverFilesArray removeObjectAtIndex: 0])
////////                                               : ([sourceFilesArray   removeObjectAtIndex: 0]);
////////            }
////////            else {
//////            
////////            NSLog(@"is = Size -- %d ", (sourceSizeValue != receiveSizeValue));
////////            NSLog(@"is = URL -- %d", (![[sourceURL lastPathComponent] isEqualToString: [receiveURL lastPathComponent]]));
////////            NSLog(@"date -- %d", ([sourceDateValue compare: receiveDateValue] != NSOrderedSame));
//////            
////            // Если это папка - проверяем ее элементы
////            if ([sourceURL hasDirectoryPath] || [receiveURL hasDirectoryPath]) {        // Если это папка - проверяем ее элементы
////                SFFile * mainFile  = [[SFFile alloc] initWithURLSourceFile: sourceURL
////                                                        andURLReceiverFile: receiveURL];
////                [mainFile setInfoState: SFFileStateUpdate];
////                
////                NSMutableArray * array = [NSMutableArray new]; //mainFile.childrensArray;
////                isModifiedFolder = [self comparisonTwoPathsWithURLSourceFile: sourceURL andURLReceiverFile: receiveURL withFillArray: &array];
////                [mainFile setChildrensArray: [array copy]];
////                
////                if (isModifiedFolder) {
////                    [*fillArray addObject: mainFile];
////                    //isModifiedFolder = YES;
////                }
////            }
////            else if (sourceSizeValue != receiveSizeValue ||
////                     ![[sourceURL lastPathComponent] isEqualToString: [receiveURL lastPathComponent]] ||
////                     [sourceDateValue compare: receiveDateValue] != NSOrderedSame) {    // Если это НЕ папка (файл) - проверяем различия
////                
////                SFFile * mainFile  = [[SFFile alloc] initWithURLSourceFile: sourceURL andURLReceiverFile: receiveURL];
////                [mainFile setInfoState: SFFileStateUpdate];
////                
////                [*fillArray addObject: mainFile];
////                isModifiedFolder = YES;
////            }
//////            else {                                                                      // Если это НЕ папка (файл) и у него нет различий
//////                isModifiedFolder = NO;
//////            }
//            
//            isModifiedFolder = [self processingURLSourceFile: sourceURL andURLReceiverFile: receiveURL withFillArray: fillArray];
//            
//            [sourceFilesArray   removeObjectAtIndex: 0];
//            [receiverFilesArray removeObjectAtIndex: 0];
//            incrVal = 2.0;
//        }
        // Обновление ПрогрессБара на main потоке
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.ProgressComparison incrementBy: incrVal];
        });
    }
    
    
    ////////////////////////////////////////////////////////////
    // Если в receiverFilesArray остались элементы
    ////////////////////////////////////////////////////////////
    
    while (receiverFilesArray.count != 0) {                                             // (2)
        
        NSURL  * curURL    = [[receiverFilesArray objectAtIndex: 0] valueForKey: @"url"];
        SFFile * mainFile  = [[SFFile alloc] initWithURLSourceFile: nil andURLReceiverFile: curURL];
        [mainFile setInfoState: SFFileStateDelete];
        
        if (mainFile.isFolder) {
//            NSMutableArray * array = mainFile.childrensArray;
//            [self comparisonTwoPathsWithURLSourceFile: nil andURLReceiverFile: curURL withFillArray: &array];
            NSMutableArray * array = [NSMutableArray new]; //mainFile.childrensArray;
            [self comparisonTwoPathsWithURLSourceFile: nil andURLReceiverFile: curURL withFillArray: &array];
            [mainFile setChildrensArray: [array copy]];
            
            [mainFile setSizeOfFile:[self _calculateSizeOfFileByArr:array]];
            [mainFile setSizeOfReceiverFile:[self _calculateReceiverSizeOfFileByArr:array]];
            [mainFile setStringReceiverSize:[NSByteCountFormatter stringFromByteCount: mainFile.sizeOfReceiverFile countStyle: NSByteCountFormatterCountStyleFile]];
        }
        [*fillArray addObject: mainFile];
        isModifiedFolder = YES;
        [receiverFilesArray removeObjectAtIndex: 0];
        
        // Обновление ПрогрессБара на main потоке
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.ProgressComparison incrementBy: 1.0];
        });
    }
    
    return isModifiedFolder;
}

- (long long) _calculateSizeOfFileByArr : (NSMutableArray *) array {
    long long sizeFolder = 0;
    for (int i = 0; i < array.count; i++) {
        SFFile * childFile = array[i];
        sizeFolder += childFile.sizeOfFile;
    }
    return sizeFolder;
}
- (long long) _calculateReceiverSizeOfFileByArr : (NSMutableArray *) array {
    long long sizeFolder = 0;
    for (int i = 0; i < array.count; i++) {
        SFFile * childFile = array[i];
        sizeFolder += childFile.sizeOfReceiverFile;
    }
    return sizeFolder;
}
- (long long) _calculateSourceSizeOfFileByArr : (NSMutableArray *) array {
    long long sizeFolder = 0;
    for (int i = 0; i < array.count; i++) {
        SFFile * childFile = array[i];
        sizeFolder += childFile.sizeOfSourceFile;
    }
    return sizeFolder;
}

- (BOOL) processingURLSourceFile : (NSURL *) sourceURL andURLReceiverFile : (NSURL *) receiveURL withFillArray : (NSMutableArray **) fillArray {
    BOOL isModifiedFolder = NO;
    
    
    // ---------- Считывание размера файла ----------//
    NSNumber * sourceSizeValue  = nil;
    NSNumber * receiveSizeValue = nil;
    [sourceURL getResourceValue: &sourceSizeValue
                         forKey: NSURLFileSizeKey
                          error: nil];
    [receiveURL getResourceValue: &receiveSizeValue
                          forKey: NSURLFileSizeKey
                           error: nil];
    
    // ---------- Считывание даты файла ----------//
    NSDate * sourceDateValue  = nil;
    NSDate * receiveDateValue = nil;
    [sourceURL getResourceValue: &sourceDateValue
                         forKey: NSURLContentModificationDateKey
                          error: nil];
    [receiveURL getResourceValue: &receiveDateValue
                          forKey: NSURLContentModificationDateKey
                           error: nil];
    
//    NSLog(@"name source - %@", [sourceURL path]);
//    NSLog(@"sourceDateValue - %@", sourceDateValue);
//    NSLog(@"name receive - %@", [receiveURL path]);
//    NSLog(@"receiveDateValue - %@", receiveDateValue);
    //
    //            // ---------- Итоговое сравнение ----------//
    ////            if ([sourceURL hasDirectoryPath] != [receiveURL hasDirectoryPath]) {
    ////                SFFile * mainFile  = [[SFFile alloc] initWithURLSourceFile: ([sourceURL  hasDirectoryPath]) ? (nil) : (sourceURL)        // потому что легче удалить НЕ рекурсию (т.е файл)
    ////                                                        andURLReceiverFile: ([receiveURL hasDirectoryPath]) ? (nil) : (receiveURL)];
    ////                mainFile.infoState = ([sourceURL hasDirectoryPath]) ? (SFFileStateDelete) : (SFFileStateAdd);
    ////                //[mainFile setInfoState: [sourceURL hasDirectoryPath]]; //??
    ////                [*fillArray addObject: mainFile];
    ////                ([sourceURL hasDirectoryPath]) ? ([receiverFilesArray removeObjectAtIndex: 0])
    ////                                               : ([sourceFilesArray   removeObjectAtIndex: 0]);
    ////            }
    ////            else {
    //
    ////            NSLog(@"is = Size -- %d ", (sourceSizeValue != receiveSizeValue));
    ////            NSLog(@"is = URL -- %d", (![[sourceURL lastPathComponent] isEqualToString: [receiveURL lastPathComponent]]));
    ////            NSLog(@"date -- %d", ([sourceDateValue compare: receiveDateValue] != NSOrderedSame));
    //
    // Если это папка - проверяем ее элементы
    if ([sourceURL hasDirectoryPath] || [receiveURL hasDirectoryPath]) {        // Если это папка - проверяем ее элементы
        SFFile * mainFile  = [[SFFile alloc] initWithURLSourceFile: sourceURL
                                                andURLReceiverFile: receiveURL];
        [mainFile setInfoState: SFFileStateUpdate];
        
        NSMutableArray * array = [NSMutableArray new]; //mainFile.childrensArray;
        isModifiedFolder = [self comparisonTwoPathsWithURLSourceFile: sourceURL andURLReceiverFile: receiveURL withFillArray: &array];
        [mainFile setChildrensArray: [array copy]];
        
        long long sizeS = [self _calculateSourceSizeOfFileByArr:array];
        long long sizeR = [self _calculateReceiverSizeOfFileByArr:array];
        [mainFile setSizeOfFile:(sizeS > sizeR)?(sizeS):(sizeR)];
        [mainFile setSizeOfSourceFile:sizeS];
        [mainFile setStringSourceSize:[NSByteCountFormatter stringFromByteCount: mainFile.sizeOfSourceFile countStyle: NSByteCountFormatterCountStyleFile]];
        [mainFile setSizeOfReceiverFile:sizeR];
        [mainFile setStringReceiverSize:[NSByteCountFormatter stringFromByteCount: mainFile.sizeOfReceiverFile countStyle: NSByteCountFormatterCountStyleFile]];

        
        if (isModifiedFolder) {
            [*fillArray addObject: mainFile];
            //isModifiedFolder = YES;
        }
    }
    else if (sourceSizeValue != receiveSizeValue ||
             ![[sourceURL lastPathComponent] isEqualToString: [receiveURL lastPathComponent]] ||
             [sourceDateValue compare: receiveDateValue] != NSOrderedSame) {    // Если это НЕ папка (файл) - проверяем различия
        
        SFFile * mainFile  = [[SFFile alloc] initWithURLSourceFile: sourceURL andURLReceiverFile: receiveURL];
        [mainFile setInfoState: SFFileStateUpdate];
        
        [*fillArray addObject: mainFile];
        isModifiedFolder = YES;
    }
    //            else {                                                                      // Если это НЕ папка (файл) и у него нет различий
    //                isModifiedFolder = NO;
    //            }
    
    
    return isModifiedFolder;
}

//
//// Формирование отсортированного Массива Словарей по урлу
//- (NSMutableArray *) formingSortedArrayByURL : (NSURL *) curURL {
//    if (curURL) {
//        NSMutableArray * curArray    = [[NSMutableArray alloc] init];
//        NSFileManager  * fileManager = [NSFileManager defaultManager];
//        NSArray * urls = [fileManager contentsOfDirectoryAtURL: curURL
//                                    includingPropertiesForKeys: [NSArray arrayWithObjects: NSURLNameKey,
//                                                                 NSURLIsDirectoryKey,
//                                                                 NSURLContentModificationDateKey,
//                                                                 NSURLTypeIdentifierKey,
//                                                                 NSURLFileSizeKey,
//                                                                 NSURLEffectiveIconKey, nil]
//                                                       options: NSDirectoryEnumerationSkipsHiddenFiles
//                                                         error: nil];
//        if (urls && urls.count) {
//            for (int i = 0; i < urls.count; i++) {
//                NSString * fileStringValue = nil;
//                NSURL    * url = urls[i];
//                [url getResourceValue: &fileStringValue
//                               forKey: NSURLNameKey
//                                error: nil];
//                
//                if (!fileStringValue) { fileStringValue = @""; }
//                NSDictionary * dict = @{@"url"  : url,
//                                        @"name" : fileStringValue};
//                [curArray addObject: dict];
//            }
//            
//            // сортировка
//            [curArray sortUsingComparator:
//             ^NSComparisonResult(NSDictionary * el1, NSDictionary * el2) {
//                 NSString * string1 = el1[@"name"];
//                 NSString * string2 = el2[@"name"];
//                 return [string1 caseInsensitiveCompare: string2];
//             }
//             ];
//            return curArray;
//        }
//    }
//    return nil;
//}

// Формирование отсортированного Массива Словарей по урлу
- (NSArray *) formingArrayByURL : (NSURL *) curURL {
    if (curURL) {
        NSFileManager  * fileManager = [NSFileManager defaultManager];
        NSArray * urls = [fileManager contentsOfDirectoryAtURL: curURL
                                    includingPropertiesForKeys: [NSArray arrayWithObjects: NSURLNameKey,
                                                                 NSURLIsDirectoryKey,
                                                                 NSURLContentModificationDateKey,
                                                                 NSURLTypeIdentifierKey,
                                                                 NSURLFileSizeKey,
                                                                 NSURLEffectiveIconKey, nil]
                                                       options: NSDirectoryEnumerationSkipsHiddenFiles
                                                         error: nil];
        if (urls && urls.count) {
            return urls;
        }
    }
    return nil;
}


- (NSMutableArray *) formingSortedArrayByURLOrderName : (NSArray *) urls {
    NSMutableArray * curArray    = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < urls.count; i++) {
        NSString * fileStringValue = nil;
        NSDate * fileDate = nil;
        NSURL    * url = urls[i];
        [url getResourceValue: &fileStringValue
                       forKey: NSURLNameKey
                        error: nil];
        
        [url getResourceValue: &fileDate
                       forKey: NSURLCreationDateKey
                        error: nil];
        
        if (!fileStringValue) { fileStringValue = @""; }
        NSDictionary * dict = @{@"url"  : url,
                                @"name" : fileStringValue,
                                @"date" : fileDate};
        [curArray addObject: dict];
    }
    
    // сортировка
    [curArray sortUsingComparator:
     ^NSComparisonResult(NSDictionary * el1, NSDictionary * el2) {
         NSString * string1 = el1[@"name"];
         NSString * string2 = el2[@"name"];
         return [string1 caseInsensitiveCompare: string2];
     }
     ];
    return curArray;
}

// Формирование отсортированного Массива Словарей по урлу (с сортировкой по дате)
- (NSMutableArray *) formingSortedArrayByURLOrderDate : (NSArray *) urls {
    NSMutableArray * curArray    = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < urls.count; i++) {
        NSString * fileStringValue = nil;
        NSDate * fileDate = nil;
        NSURL    * url = urls[i];
        [url getResourceValue: &fileStringValue
                       forKey: NSURLNameKey
                        error: nil];
        
        [url getResourceValue: &fileDate
                       forKey: NSURLCreationDateKey
                        error: nil];
        
        if (!fileStringValue) { fileStringValue = @""; }
        NSDictionary * dict = @{@"url"  : url,
                                @"name" : fileStringValue,
                                @"date" : fileDate};
        [curArray addObject: dict];
    }
    
    // сортировка
    [curArray sortUsingComparator:
     ^NSComparisonResult(NSDictionary * el1, NSDictionary * el2) {
         //                 NSString * string1 = el1[@"name"];
         //                 NSString * string2 = el2[@"name"];
         NSDate * date1 = el1[@"date"];
         NSDate * date2 = el2[@"date"];
         return [date1 compare: date2];
     }
     ];
    return curArray;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Animation
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Анимация Исчезания
- (void) fadeOutView : (NSView *) sender {
    float alpha = 1.0;
    [sender setAlphaValue: alpha];
    //[sender :self];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.2f];
    [[sender animator] setAlphaValue: 0.f];
    [NSAnimationContext endGrouping];
}

// Анимация Появления
- (void) fadeInView  : (NSView *) sender {
    float alpha = 0.0;
    [sender setAlphaValue:alpha];
    //[sender makeKeyAndOrderFront:self];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.2f];
    [[sender animator] setAlphaValue:1.f];
    [NSAnimationContext endGrouping];
}







//    //Показывать
//    [self.ProgressComparison setAlphaValue: 0];
//    [self.ProgressComparison setHidden: NO];
//    [NSView transitionWithView:searchbox
//                      duration:0.3
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^{
//                        searchbox.alpha = 1.0
//                    }completion:NULL];
//    //Прятаться
//    searchbox.alpha = 1.0;
//    searchbox.isHidden = NO;
//    [UIView transitionWithView:searchbox
//                      duration:0.3
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^{
//                        searchbox.alpha = 0
//                    }completion:^(isComplete){
//                        if (isComplete) {
//                            searchbox.isHidden = YES
//                        }}];

//[self.ProgressComparison setHidden: NO];
//[self fadeOutView: self.ProgressComparison];

//NSImage *icon = [[NSWorkspace sharedWorkspace]
//                 iconForFileType: NSFileTypeForHFSTypeCode(kComputerIcon)];
//[NSImage imageNamed: NSImageNameComputer]

// NSFileManager - работа с файловой системы (урлы) - крлы получаются через ...file url with path... - существует даже есль папки нет, он нужен для свойств файла
//

/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
//- (void) fillArrayByURL: (NSURL *) URL usingIDArray: (int) IDArray {
//    // здесь функция преобразования массива urls - в массив словарей типа MUTABLE - это рекурсивная функция
//    //
//    // смысл - читаю файл с помощью менеджера
//    //          потом определяю по расширению тип файла
//    //          если просто файл - переношу / добавляю к детям
//    //          если папка - проваливаюсь в рекурсию? а после ее выхода добавляю к детям
//    //
//    _sourceFilesArray = [self algorithmConvertingArrayFilesToURLs: URL];
//    // не в отдельной функции а здесь ИЛИ ПЕРЕНЕСТИ ФАЙЛ МЕНЕДЖЕР В ОТДЕЛЬНУЮ
//    
//    // 0 - _sourceFilesArray; 1 - _receiverFilesArray
//    if (IDArray == 0) {
//        //NSLog(@"_sourceFilesArray ::: %@",urls);
//        
//    }
//    else if (IDArray == 1) {
//        //NSLog(@"_receiverFilesArray ::: %@",urls);
//        
//    }
//    
////    NSURL *directoryURL = [fileManager URLForDirectory: NSDocumentDirectory
////                                              inDomain: NSUserDomainMask
////                                     appropriateForURL: nil
////                                                create: NO
////                                                 error: nil];
//}
//        for (int i = 0; i < [curItem childrensArray].count; i++) {
//
//            SFFile * childFile = curItem.childrensArray[0];
//            NSLog(@"childFile ::: %@ - %@", [childFile sourceName], [childFile receiverName]);
//            NSLog(@"State     ::: %d - %d", [childFile infoState], [childFile oldState]);
//
//            [self updateVisualityAllChildrenFolders: childFile];
//            break;
//        }
//- (NSMutableArray *) algorithmConvertingArrayFilesToURLs: (NSURL *) URL {
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *urls = [fileManager contentsOfDirectoryAtURL: URL
//                               includingPropertiesForKeys: [NSArray arrayWithObjects: NSURLNameKey,
//                                                                                      NSURLIsDirectoryKey,
//                                                                                      NSURLContentModificationDateKey,
//                                                                                      NSURLTypeIdentifierKey,
//                                                                                      NSURLFileSizeKey,
//                                                                                      NSURLCustomIconKey,
//                                                                                      NSURLEffectiveIconKey, nil]
//                                                  options: NSDirectoryEnumerationSkipsHiddenFiles
//                                                    error: nil];
//    
//    NSLog(@"urls ::: %@", urls);
//    for (int i = 0; i < urls.count; i++) {
//        NSLog(@"name ::: %@",[urls[i] lastPathComponent]);
//        NSLog(@"isDirectory ::: %hhd",[urls[i] hasDirectoryPath]);
//        //NSLog(@"typeIdentifier ::: %@",[urls[i] typeIdentifier]);
//        NSNumber *fileSizeValue = nil;
//        NSError *fileSizeError = nil;
//        [urls[i] getResourceValue:&fileSizeValue
//                           forKey:NSURLFileSizeKey
//                            error:&fileSizeError];
//        if (fileSizeValue) {
//            NSLog(@"value for %@ is %@", urls[i], fileSizeValue);
//        }
//        else {
//            NSLog(@"error getting size for url %@ error was %@", urls[i], fileSizeError); // у папок размер уходит в err - считать с помощью суматорной глобальной переменной просто вовремя ее приравнивать
//        }
//    }
//    
//    NSMutableArray * rr;
//    return rr;
//}

//    _SFScrollView.layer.cornerRadius = 15;
//    _SFScrollView.layer.masksToBounds = YES;

//    [_SBClipView.layer setCornerRadius: 15.0];
//    [_SBClipView.layer setMasksToBounds: YES];
//    _SBClipView.layer.cornerRadius = 15;
//    _SBClipView.layer.masksToBounds = YES;

//    [_SFMainOutlineView.layer setCornerRadius: 15.0];
//    [_SFMainOutlineView.layer setMasksToBounds: YES];
//    _SFMainOutlineView.layer.cornerRadius = 15;
//    _SFMainOutlineView.layer.masksToBounds = YES;
//_SFMainOutlineView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
//_SFMainOutlineView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;


/* View Based TableView: The delegate can optionally implement this method to return a custom NSTableRowView for a particular 'row'. The reuse queue can be used in the same way as documented in tableView:viewForTableColumn:row:. The returned view will have attributes properly set to it before it is added to the tableView. Returning nil is acceptable. If nil is returned, or this method isn't implemented, a regular NSTableRowView will be created and used.
 
 TableView на основе представления: делегат может дополнительно реализовать этот метод для возврата пользовательского NSTableRowView для конкретной «строки». Очередь повторного использования можно использовать так же, как описано в tableView:viewForTableColumn:row:. Возвращаемое представление будет иметь правильно установленные атрибуты, прежде чем оно будет добавлено в tableView. Возврат нуля допустим. Если возвращается nil или этот метод не реализован, будет создан и использован обычный NSTableRowView.
 */
//- (nullable NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
//    SFTableRowView * rowTable = [[SFTableRowView alloc] init];
//
//    return rowTable;
//}


//- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item {
////    NSString *theImageName;
////    NSInteger theCellValue = [cell integerValue];
////    if (theCellValue==1) {
////        theImageName = @"PMOutlineCellOn";
////    } else if (theCellValue==0) {
////        theImageName = @"PMOutlineCellOff";
////    } else {
////        theImageName = @"PMOutlineCellMixed";
////    }
////
////    NSImage *theImage = [NSImage imageNamed: theImageName];
////    NSRect theFrame = [outlineView frameOfOutlineCellAtRow:[outlineView rowForItem: item]];
////    theFrame.origin.y = theFrame.origin.y +17;
////    // adjust theFrame here to position your image
////    [theImage compositeToPoint: theFrame.origin operation:NSCompositeSourceOver];
////    [cell setImagePosition: NSNoImage];
//    NSLog(@"111");
//}

//// Обработка нажатия на чекбокс
//- (void) clickHandlingOnCheckBox: (NSButton *) sender {
////    long indexRow = (long)[self.SFMainOutlineView rowAtPoint: [sender convertPoint:CGPointZero toView: self.SFMainOutlineView]];
////
////    SFFile *curFile = [_SFMainOutlineView itemAtRow: indexRow];
////    curFile.isChecked = ([sender state] != -1) ? ([sender state]) : (1); //[sender state];
////
////    if (curFile.isFolder) {
////        [self updateStateAllItemsCurFolder: curFile];
////    }
////    [self updateStateAllParentFolders: indexRow];
////
////    [_SFMainOutlineView reloadData];
//}
// htrehcbz рекурсия
////////////////////////////////////
// ---------- Считывание детей ----------
//                NSFileManager *fileManager = [NSFileManager defaultManager];
//                NSArray *urls = [fileManager contentsOfDirectoryAtURL: curSourceURL
//                                           includingPropertiesForKeys: [NSArray arrayWithObjects: NSURLNameKey,
//                                                                        NSURLIsDirectoryKey,
//                                                                        NSURLContentModificationDateKey,
//                                                                        NSURLTypeIdentifierKey,
//                                                                        NSURLFileSizeKey,
//                                                                        NSURLCustomIconKey,
//                                                                        NSURLEffectiveIconKey, nil]
//                                                              options: NSDirectoryEnumerationSkipsHiddenFiles
//                                                                error: nil];
//
//                if (urls) {
//                    //long long folderSize = 0;
//
//                    NSLog(@"urls ::: %@", urls);
//                    for (int i = 0; i < urls.count; i++) {
//
//                        // ---------- Считывание размера файла ----------//
////                        NSNumber *fileSizeValue = nil;
////                        [urls[i] getResourceValue: &fileSizeValue
////                                           forKey: NSURLFileSizeKey
////                                            error: nil];
////                        if (fileSizeValue) {
////                            folderSize += [fileSizeValue longLongValue];
////                        }
////                        else {
////                            // у папок размер уходит в err - считать с помощью суматорной глобальной переменной просто вовремя ее приравнивать
////                            folderSize += 0;
////                        }
//
////                        SFFile * curChild = [[SFFile alloc] initWithURLSourceFile: urls[i]
////                                                               andURLReceiverFile: ]; //!!!!!!!!!
////                        [_childrensArray addObject: curChild];
//                    }
////                    if (folderSize) {
////                        self.sizeOfSourceFile = folderSize;
////                    }
//                }

//
//- (void)incrementProgressBar// : (NSToolbarItem *) sender
//{
//    //DELAY(2000);
//    if ([self.ProgressComparison doubleValue] >= 100.0) {
//        [self fadeOutView: self.ProgressComparison];
//        //[sender setEnabled: YES];
//    }
//    else {
//
//        // Increment the progress bar value by 1
//        [self.ProgressComparison incrementBy: 1.0];
//
//        // If the progress bar hasn't reached 100 yet, then wait a second and call again
//        //if([self.ProgressComparison doubleValue] < 100.0)
//        //[self performSelector:@selector(incrementProgressBar) withObject:nil afterDelay:0.5];
//
//        [self performSelector:@selector(incrementProgressBar) withObject:nil afterDelay:0.1];
//    }
//}
//                    if ((long)[string1 caseInsensitiveCompare: string2] == 1) {
//                        return (NSComparisonResult)NSOrderedDescending;
//                    }
//                    else if ((long)[string1 caseInsensitiveCompare: string2] == -1) {
//                        return (NSComparisonResult)NSOrderedAscending;
//                    }
//                    else {
//                        return (NSComparisonResult)NSOrderedSame;
//                    }

//                NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys: urls[i], @"url",
//                                                                          fileStringValue, @"name",
//                                                            @([urls[i] hasDirectoryPath]), @"isFileFolder", nil]; //

//- (BOOL) validateToolbarItem : (NSToolbarItem *) toolbarItem {
//
////    BOOL enable = YES;
////    NSLog(@"toolbarItem :: %@", toolbarItem.label);
////    if ([[toolbarItem itemIdentifier] isEqualToString: @"NSToolbarComparisonItem"]) {
////
////        // We will return YES (enable the save item)
////        // only when the document is dirty and needs saving
////        //enable = [self isDocumentEdited];
////        //enable = NO;
////        NSLog(@"090");
////
////    } else if ([[toolbarItem itemIdentifier] isEqual: NSToolbarPrintItemIdentifier]) {
////
////        // always enable print for this window
////        //enable = YES;
////    }
//
//
//    // self.view.window.toolbar ... validateVisibleItems
//
//    // setValue
//    //[self.view.window.toolbar setValue:@(YES) forKey:@"isToolButtonEnabled"];
//
//    //////!!!!!
//    //завести переменную (приравнивать через бандиксы(посмотреть видео)? (set value fo key) соединить свойство для кнопок (энейблед)) - если так - то это не нужно
//    //в начале и в конце у тяжелой процедуре устанавливать значения
//
//    return YES;
//}
//    // ---------- Установка цвета для 2 половины (ПРИЕМНИКА) на добавление ----------//
//    if ([item isChecked] && item.infoState == 0) {
//        [myCell.textField setTextColor: [NSColor colorWithRed: 0.1686
//                                                        green: 0.7843
//                                                         blue: 0.2745 alpha: 1.0]];
//    }
//    else if ([item isChecked] && item.infoState == 1) {
//        [myCell.textField setTextColor: [NSColor redColor]];
//    }
//    else if ([item isChecked] && item.infoState == 2) {
//        [myCell.textField setTextColor: [NSColor blueColor]];
//    }
//    else if (![item isChecked]) {
//        [myCell.textField setTextColor: [NSColor grayColor]];
//    }
//    else {
//        [myCell.textField setTextColor: [NSColor blackColor]];
//    }


////////////////////////////////////////////////////////////
// Проход по столбцам для 2 половины
////////////////////////////////////////////////////////////

//
// ДОБАВИТЬ
//
// Установка значения размера для папок
// Правильный подсчет спорного файла (папка и нет)
// Добавить уведомление - если восстановилась несуществующая папка // требование обновления тблицу
//
// обработку ошибок
//      |
//      V
//
//- (void) _finalFileTransferWithArray : (NSMutableArray *) curArraySynchronize andSize : (long long) curSize {
//    // Эта должна быть в отдельном окне
//    NSFileManager * fileManager = [NSFileManager defaultManager];
//
//    for (int i = 0; i < [curArraySynchronize count]; i++) {
//        SFFile  * childFile = curArraySynchronize[i];
//        NSError * error     = nil;
//
//        if (childFile.receiverURL) {
//            BOOL result = [fileManager removeItemAtURL: childFile.receiverURL
//                                                 error: &error];
//
//            //NSLog(@"result1 ::: %d", result);
//            if (!result || error) {
//                NSLog(@"error1  ::: %@",  error.localizedDescription);
//                error = nil;
//            }
//        }
//
//        if (childFile.sourceURL && _URLReceiver) {  // Если существует файл из источника и путь к папки приемника, то...
//
//            // Создаем путь в папке-приемнике с включеным в него тек файлом
//            NSString * newFilePath = [NSString stringWithFormat: @"%@/%@", [_URLReceiver path], [childFile.sourceURL lastPathComponent]];
//
//            BOOL result = [fileManager copyItemAtURL: childFile.sourceURL
//                                               toURL: [NSURL fileURLWithPath: newFilePath]
//                                               error: &error];
//
//            //NSLog(@"result2 ::: %d", result);
//            if (!result || error) {
//                NSLog(@"error2  ::: %@",  error.localizedDescription);
//            }
//        }
//    }
//}


@end
