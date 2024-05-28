//
//  SFLoadingWindowsController.h
//  SynchronizeFileManager
//
//  Created by Евгений on 14.10.23.
//  Copyright © 2023 OverLanne. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFFile.h"
#import "SFWindow.h"

@interface SFLoadingWindowsController : NSWindowController {
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties

@property (nonatomic) BOOL isBreak;                             // Для Прерывания копирования

@property (nonatomic, strong) NSURL   * URLReceiver;            // Путь к приемнику
@property (nonatomic, strong) NSURL   * URLSource;              // Путь к источнику
@property (nonatomic, strong) NSArray * curArraySynchronize;    // Массив всех файлов
@property (nonatomic) long long curSize;                        // Суммарный размер файла

@property (nonatomic, assign) IBOutlet NSTextField * SFCurFileLable;    // Lable текущего копируемого файла
@property (nonatomic, assign) IBOutlet NSTextField * SFPercentLable;    // Lable процента загрузки

@property (nonatomic, assign) IBOutlet NSTextField * SFAmountFiles;     // Lable количества файлов
@property (nonatomic, assign) IBOutlet NSTextField * SFSizeFiles;       // Lable размера файлов
@property (nonatomic, assign) IBOutlet NSTextField * SFLoadingTime;     // Lable оставшегося времени

@property (nonatomic, assign) IBOutlet NSProgressIndicator * ProgressComparison;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Stop Loading

- (IBAction) stopLoadingButtonOnClick  : (NSButton *) sender;

@end
