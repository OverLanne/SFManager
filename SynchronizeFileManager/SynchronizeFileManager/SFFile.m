//
//  SFFile.m
//  SynchronizeFileManager
//
//  Created by Евгений on 10.08.23.
//  Copyright © 2023 OverLanne. All rights reserved.
//

#import "SFFile.h"

//@interface SFFile ()
//
//@end

@implementation SFFile

@synthesize checkboxState = _checkboxState;
@synthesize infoState     = _infoState;
//@synthesize oldState      = _oldState;
@synthesize sourceName    = _sourceName;
@synthesize receiverName  = _receiverName;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark init
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id) initWithURLSourceFile : (NSURL *) curSourceURL andURLReceiverFile : (NSURL *) curReceiverURL {
    
    self = [super init];
    if (self) {
        // ---------- Установка дефолтного значения статуса ----------//
        [self setInfoState: SFFileStateAdd];
        //[self setOldState:  SFFileStateBuffer];
        
        // ---------- Установка дефолтного значения галочки ----------//
        [self setCheckboxState: SFCheckboxOnState];
        
        // ---------- Считывание isFolder файла ----------//
        BOOL isSourceFolder   = (curSourceURL)   ? ([curSourceURL   hasDirectoryPath]) : (NO);
        BOOL isReceiverFolder = (curReceiverURL) ? ([curReceiverURL hasDirectoryPath]) : (NO);
        
        [self setIsFolder: (isSourceFolder || isReceiverFolder)];
        if (self.isFolder) {
            [self setChildrensArray: [NSArray new]];
        }
        
        // ---------- Считывание Данных файла (Урл, Имя, Дата, Размер) ----------//
        if (curSourceURL) {
            NSDictionary * dataDictionary = [self _formationOfDataDictionaryByUrl: curSourceURL];
            [self setSourceURL:        dataDictionary[@"fileURL"]];
            [self setSourceName:       dataDictionary[@"fileName"]];
            [self setStringSourceDate: dataDictionary[@"fileDateString"]];
            [self setSourceDate:       dataDictionary[@"fileDate"]];
            [self setStringSourceSize: dataDictionary[@"fileSizeString"]];
            [self setSizeOfSourceFile: [dataDictionary[@"fileSize"] longLongValue]];
            _sizeOfSourceFile = [dataDictionary[@"fileSize"] longLongValue];
            _isSourceNameNil  = NO;
        }
        else {
            [self setSourceURL:        nil];
            [self setSourceName:       nil];
            [self setStringSourceDate: @""];
            [self setStringSourceSize: @""];
            [self setSizeOfSourceFile: 0];
            _sizeOfSourceFile = 0;
            _isSourceNameNil  = YES;
        }
        
        if (curReceiverURL) {
            NSDictionary * dataDictionary = [self _formationOfDataDictionaryByUrl: curReceiverURL];
            [self setReceiverURL:        dataDictionary[@"fileURL"]];
            [self setReceiverName:       dataDictionary[@"fileName"]];
            [self setStringReceiverDate: dataDictionary[@"fileDateString"]];
            [self setReceiverDate:       dataDictionary[@"fileDate"]];
            [self setStringReceiverSize: dataDictionary[@"fileSizeString"]];
            [self setSizeOfReceiverFile: [dataDictionary[@"fileSize"] longLongValue]];
            _sizeOfReceiverFile = [dataDictionary[@"fileSize"] longLongValue];
            _isReceiverNameNil  = NO;
        }
        else {
            [self setReceiverURL:        nil];
            [self setReceiverName:       nil];
            [self setStringReceiverDate: @""];
            [self setStringReceiverSize: @""];
            [self setSizeOfReceiverFile: 0];
            _sizeOfReceiverFile = 0;
            _isReceiverNameNil  = YES;
        }
        
        // ---------- Установка суммарного значения размера данного SFFile ----------//
        [self setSizeOfFile: (_sizeOfSourceFile + _sizeOfReceiverFile)];
        
        
        // ---------- Считывание иконки файла ----------//
        NSImage * sourceIconFileValue = nil;
        [curSourceURL getResourceValue: &sourceIconFileValue
                                forKey: NSURLEffectiveIconKey
                                 error: nil];
        NSImage * receiverIconFileValue = nil;
        [curReceiverURL getResourceValue: &receiverIconFileValue
                                  forKey: NSURLEffectiveIconKey
                                   error: nil];
        [self setSourceIcon:   (sourceIconFileValue)   ? (sourceIconFileValue)   : (receiverIconFileValue)];
        [self setReceiverIcon: (receiverIconFileValue) ? (receiverIconFileValue) : (sourceIconFileValue)];
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setters & Getters
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// checkboxState
- (SFCheckboxState)checkboxState {
    return _checkboxState;
}

- (void) setCheckboxState : (SFCheckboxState) checkboxState {
    _checkboxState = checkboxState;
    [self _updateColor];
    [self _updateSourceName];
    [self _updateReceiverName];
}

// infoState
- (SFFileState) infoState {
    return _infoState;
}

- (void) setInfoState : (SFFileState) infoState {
    _infoState = infoState;
    [self _updateColor];
    [self _updateSourceName];
    [self _updateReceiverName];
}

//// oldState
//- (SFFileState) oldState {
//    return _oldState;
//}
//
//- (void) setOldState : (SFFileState) oldState {
//    [self _updateSourceName];
//    _oldState = oldState;
//}

// sourceName
- (NSString *) sourceName {
    return _sourceName;
}

- (void) setSourceName : (NSString *) sourceName {
    _sourceName = sourceName;
    [self _updateSourceName];
}

// receiverName
- (NSString *) receiverName {
    return _receiverName;
}

- (void) setReceiverName : (NSString *) receiverName {
    _receiverName = receiverName;
    [self _updateReceiverName];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *) _formationOfDataDictionaryByUrl : (NSURL *) curURL {
    // ---------- Считывание имени файла ----------//
    NSString * fileStringValue = nil;
    [curURL getResourceValue: &fileStringValue
                      forKey: NSURLNameKey
                       error: nil];

    // ---------- Считывание размера файла ----------//
    NSNumber * fileSizeValue = nil;
    [curURL getResourceValue: &fileSizeValue
                      forKey: NSURLFileSizeKey
                       error: nil];
    
    // ---------- Считывание даты файла ----------//
    NSDate          * fileDateValue = nil;
    NSDateFormatter * dateformate   = [NSDateFormatter new];
    [dateformate setDateFormat: @"dd-MM-yyyy HH:mm:ss"];
    
    [curURL getResourceValue: &fileDateValue
                      forKey: NSURLContentModificationDateKey
                       error: nil];
    
    return @{@"fileURL"        : curURL,
             @"fileName"       : fileStringValue,
             @"fileSize"       : (fileSizeValue) ? (fileSizeValue) : (@(0)),
             @"fileSizeString" : (fileSizeValue) ? ([NSByteCountFormatter stringFromByteCount: [fileSizeValue longLongValue] countStyle: NSByteCountFormatterCountStyleFile]) : (@""),
             @"fileDateString" : (fileDateValue) ? ([dateformate stringFromDate: fileDateValue]) : (@""),
             @"fileDate"       : (fileDateValue) ? (fileDateValue) : (@(0)),
             };
}

// Обновление цвета
- (void) _updateColor {
    if (self.checkboxState == SFCheckboxOnState && self.infoState == SFFileStateAdd) {
        [self setSourceColor:   [NSColor blackColor]];
        [self setReceiverColor: [NSColor colorWithRed: 0.1686
                                                green: 0.7843
                                                 blue: 0.2745 alpha: 1.0]];
    }
    else if (self.checkboxState == SFCheckboxOnState && self.infoState == SFFileStateDelete) {
        [self setSourceColor:   [NSColor redColor]];
        [self setReceiverColor: [NSColor redColor]];
    }
    else if ((self.checkboxState != SFCheckboxOffState   && self.infoState == SFFileStateUpdate) ||
             (self.checkboxState == SFCheckboxMixedState && self.infoState != SFFileStateUpdate)) {
        [self setSourceColor:   [NSColor blueColor]];
        [self setReceiverColor: [NSColor blueColor]];
    }
    else if (self.checkboxState == SFCheckboxOffState) {
        [self setSourceColor:   [NSColor grayColor]];
        [self setReceiverColor: [NSColor grayColor]];
    }
    else { //заглушка
        [self setSourceColor:   [NSColor blackColor]];
        [self setReceiverColor: [NSColor blackColor]];
    }
}

// Обновление имени источника
- (void) _updateSourceName {
    if (_isSourceNameNil && self.checkboxState == SFCheckboxOffState) { //!self.checkboxState && !self.sourceName
        _sourceName = @"<_БЕЗ_ИЗМЕНЕНИЙ_>";
    }
    else if (_isSourceNameNil && self.infoState == SFFileStateDelete) {
        _sourceName = @"<_БУДЕТ_УДАЛЁН_>";
    }
    
    
//    else if (self.checkboxState == SFCheckboxMixedState && self.infoState != SFFileStateUpdate) {
//        _sourceName = @"<_БУДЕТ_ИЗМЕНЁН_>";
//    }
    
//    
//    NSLog(@"------------------------------");
//    NSLog(@"Name ::: %@ - %@", self.sourceName, self.receiverName);
//    NSLog(@"infoState :: ");
//    if ([self infoState] == SFFileStateDelete) { NSLog(@"1"); }
//    else if ([self infoState] == SFFileStateUpdate) { NSLog(@"2"); }
//    else { NSLog(@"0"); }
//    NSLog(@"oldState :: ");
//    if ([self oldState] == SFFileStateDelete) { NSLog(@"1"); }
//    else if ([self oldState] == SFFileStateUpdate) { NSLog(@"2"); }
//    else if ([self oldState] == SFFileStateBuffer) { NSLog(@"3"); }
//    else { NSLog(@"0"); }
//    NSLog(@"------------------------------");
}

// Обновление имени приёмника
- (void) _updateReceiverName {
    if (_isReceiverNameNil && self.checkboxState == SFCheckboxOffState) { //!self.checkboxState && !self.receiverName
        _receiverName = @"<_БЕЗ_ИЗМЕНЕНИЙ_>";
    }
    else if (_isReceiverNameNil && self.infoState == SFFileStateAdd) {
        _receiverName = @"<_БУДЕТ_ДОБАВЛЕН_>";
    }
}






//- (id) initWithURLSourceFile : (NSURL *) curSourceURL andURLReceiverFile : (NSURL *) curReceiverURL {
//
//    self = [super init];
//    if (self) {
//
//        // ---------- Установка УРЛа ----------//
//        [self setSourceURL:   curSourceURL];
//        [self setReceiverURL: curReceiverURL];
//
//        // ---------- Установка дефолтного значения статуса ----------//
//        [self setInfoState: SFFileStateAdd];
//        [self setOldState:  SFFileStateUpdate];
//
//        // ---------- Установка дефолтного значения галочки ----------//
//        [self setCheckboxState: 1];
//
//        // ---------- Считывание имени файла ----------//
//        NSString * fileStringValue = nil;
//        [curSourceURL getResourceValue: &fileStringValue
//                                forKey: NSURLNameKey
//                                 error: nil];
//        [self setSourceName: fileStringValue];
//
//        [curReceiverURL getResourceValue: &fileStringValue
//                                  forKey: NSURLNameKey
//                                   error: nil];
//        [self setReceiverName: fileStringValue];
//
//        // ---------- Считывание isFolder файла ----------//
//        BOOL isSourceFolder   = (curSourceURL)   ? ([curSourceURL   hasDirectoryPath]) : (NO);
//        BOOL isReceiverFolder = (curReceiverURL) ? ([curReceiverURL hasDirectoryPath]) : (NO);
//
//         // ---------- Итоговая установка значение isFolder файла ----------//
//        [self setIsFolder: (isSourceFolder || isReceiverFolder)];
//        if (self.isFolder) {
//            [self setChildrensArray:[NSMutableArray new]];
//        }
//
//       // ---------- Считывание размера файла ----------//
//        NSNumber * fileSizeValue = nil;
//        [curSourceURL getResourceValue: &fileSizeValue
//                                forKey: NSURLFileSizeKey
//                                 error: nil];
//        [self setSizeOfSourceFile: (fileSizeValue) ? ([NSByteCountFormatter stringFromByteCount: [fileSizeValue longLongValue] countStyle: NSByteCountFormatterCountStyleFile]) : (@"")];
//
//        [curReceiverURL getResourceValue: &fileSizeValue
//                                  forKey: NSURLFileSizeKey
//                                   error: nil];
//        [self setSizeOfReceiverFile: (fileSizeValue) ? ([NSByteCountFormatter stringFromByteCount: [fileSizeValue longLongValue] countStyle: NSByteCountFormatterCountStyleFile]) : (@"")];
//
//        // ---------- Считывание даты файла ----------//
//        NSDate          * fileDateValue = nil;
//        NSDateFormatter * dateformate   = [[NSDateFormatter alloc] init];
//        [dateformate setDateFormat: @"dd-MM-yyyy HH:mm:ss"];                        // Date formater
//
//        [curSourceURL getResourceValue: &fileDateValue
//                                forKey: NSURLContentModificationDateKey
//                                 error: nil];
//        [self setStringSourceDate: (fileDateValue) ? ([dateformate stringFromDate: fileDateValue]) : (@"")];
//
//        [curReceiverURL getResourceValue: &fileDateValue
//                                  forKey: NSURLContentModificationDateKey
//                                   error: nil];
//        [self setStringReceiverDate: (fileDateValue) ? ([dateformate stringFromDate: fileDateValue]) : (@"")];
//
//        // ---------- Считывание иконки файла ----------//
//        NSImage * sourceIconFileValue = nil;
//        [curSourceURL getResourceValue: &sourceIconFileValue
//                                forKey: NSURLEffectiveIconKey
//                                 error: nil];
//        NSImage * receiverIconFileValue = nil;
//        [curReceiverURL getResourceValue: &receiverIconFileValue
//                                forKey: NSURLEffectiveIconKey
//                                 error: nil];
//        [self setSourceIcon:   (sourceIconFileValue)   ? (sourceIconFileValue)   : (receiverIconFileValue)];
//        [self setReceiverIcon: (receiverIconFileValue) ? (receiverIconFileValue) : (sourceIconFileValue)];
//    }
//    return self;
//}

//- (id) init {
//    return [self initWithName:@"TestName" date: [NSDate date] andIsFolder: NO];
//}

//- (id) initWithName : (NSString *) name date: (NSDate *) date andIsFolder: (bool) isFolder {
//    self = [super init];
//    if (self) {
//        _name = [name copy];
//        _date = date;
//   
//        NSDateFormatter *dateformate = [[NSDateFormatter alloc] init];
//        [dateformate setDateFormat: @"dd-MM-yyyy HH:mm:ss"];            // Date formater
//        _stringDate = [dateformate stringFromDate: date];               // Convert date to string
//        
//        _isFolder = isFolder;
//        _statusOfFile = [[NSMutableDictionary alloc] init]; //@{@"parent" : self, @"children" : @[@""]};
//        if (isFolder) {
//            _childrensArray = [[NSMutableArray alloc] init];
//        }
//        else {
//            _childrensArray = nil;
//        }
//
//        [_statusOfFile setValue: @""  forKey: @"parent"];
//        [_statusOfFile setValue: self forKey: @"self"];
//        [_statusOfFile setValue: @""  forKey: @"children"];
//        
//    }
//    return self;
//}
//
//- (void) addChildren : (SFFile *) file {
//    if ([self isFolder]) {
//        
//        if ([self.statusOfFile valueForKey: @"parent"]) {
//            [file.statusOfFile setValue: self forKey: @"parent"];
//        }
//        else {
//            [file.statusOfFile setValue: @"" forKey: @"parent"];
//        }
//        
//        [_childrensArray addObject: file];
//        
//        [_statusOfFile setValue: _childrensArray forKey: @"children"];
//    }
//}
//
//    /////////////////////////////////////////////////
//    // curSourceURL
//    /////////////////////////////////////////////////
//    if (curSourceURL) {
//        // ---------- Считывание имени файла ----------//
//        NSString *fileStringValue = nil;
//        [curSourceURL getResourceValue: &fileStringValue
//                                forKey: NSURLNameKey
//                                 error: nil];
////        if (fileStringValue) {
////            self.sourceName = fileStringValue;
////        }
////        else {
////            self.sourceName = @"";
////        }
//        self.sourceName = (fileStringValue) ? (fileStringValue) : (@"<_БУДЕТ_УДАЛЁН_>");
//        
//        // ---------- Считывание isFolder файла ----------//
//        isSourceFolder = [curSourceURL hasDirectoryPath];
//
//        // ---------- Считывание размера файла ----------//
//        NSNumber *fileSizeValue = nil;
//        [curSourceURL getResourceValue: &fileSizeValue
//                                forKey: NSURLFileSizeKey
//                                 error: nil];
////        if (fileSizeValue) {
////            self.sizeOfSourceFile = [fileSizeValue longLongValue];
////        }
////        else {
////            // у папок размер уходит в err - считать с помощью суматорной глобальной переменной просто вовремя ее приравнивать
////            self.sizeOfSourceFile = 0;
////        }
//        self.sizeOfSourceFile = (fileSizeValue) ? ([fileSizeValue longLongValue]) : (0);
//        
//        // ---------- Считывание даты файла ----------//
//        NSDate  *fileDateValue = nil;
//        [curSourceURL getResourceValue: &fileDateValue
//                                forKey: NSURLContentModificationDateKey
//                                 error: nil];
//        if (fileDateValue) {
//            NSDateFormatter *dateformate = [[NSDateFormatter alloc] init];
//            [dateformate setDateFormat: @"dd-MM-yyyy HH:mm:ss"];            // Date formater
//            self.stringSourceDate = [dateformate stringFromDate: fileDateValue];  // Convert date to string
//        }
//        else {
//            self.stringSourceDate = @"";
//        }
//        
////        // ---------- Считывание детей ----------
////        NSFileManager *fileManager = [NSFileManager defaultManager];
////        NSArray *urls = [fileManager contentsOfDirectoryAtURL: curSourceURL
////                                   includingPropertiesForKeys: [NSArray arrayWithObjects: NSURLNameKey,
////                                                                NSURLIsDirectoryKey,
////                                                                NSURLContentModificationDateKey,
////                                                                NSURLTypeIdentifierKey,
////                                                                NSURLFileSizeKey,
////                                                                NSURLCustomIconKey,
////                                                                NSURLEffectiveIconKey, nil]
////                                                      options: NSDirectoryEnumerationSkipsHiddenFiles
////                                                        error: nil];
////        
////        NSLog(@"item :: %@", [curSourceURL path]);
////        
////        NSLog(@"isFolder :: %hhd", self.isFolder);
////        
////        NSLog(@"sourceName :: %@", self.sourceName);
////        NSLog(@"sizeOfSourceFile :: %lld", self.sizeOfSourceFile);
////        NSLog(@"stringSourceDate :: %@", self.stringSourceDate);
////        
////        if (urls && _isFolder) {
////            long long folderSize = 0;
////            
////            NSLog(@"urls ::: %@", urls);
////            for (int i = 0; i < urls.count; i++) {
////                
////                // ---------- Считывание размера файла ----------//
////                NSNumber *fileSizeValue = nil;
////                [urls[i] getResourceValue: &fileSizeValue
////                                   forKey: NSURLFileSizeKey
////                                    error: nil];
////                if (fileSizeValue) {
////                    folderSize += [fileSizeValue longLongValue];
////                }
////                else {
////                    // у папок размер уходит в err - считать с помощью суматорной глобальной переменной просто вовремя ее приравнивать
////                    folderSize += 0;
////                }
////                
////                SFFile * curChild = [[SFFile alloc] initWithURLSourceFile: urls[i]
////                                                       andURLReceiverFile: ]; //!!!!!!!!!
////                [_childrensArray addObject: curChild];
////            }
////            if (folderSize) {
////                self.sizeOfSourceFile = folderSize;
////            }
////        }
////        NSLog(@"childrensArray :: %@", _childrensArray);
//    }
//    
//    /////////////////////////////////////////////////
//    // curReceiverURL
//    /////////////////////////////////////////////////
//    if (curReceiverURL) {
//        // ---------- Считывание имени файла ----------//
//        NSString *fileStringValue = nil;
//        [curReceiverURL getResourceValue: &fileStringValue
//                                forKey: NSURLNameKey
//                                 error: nil];
////        if (fileStringValue) {
////            self.receiverName = fileStringValue;
////        }
////        else {
////            self.receiverName = @"";
////        }
//        self.receiverName = (fileStringValue) ? (fileStringValue) : (@"<_БУДЕТ_ДОБАВЛЕН_>");
//        
//        // ---------- Считывание isFolder файла ----------//
//        isReceiverFolder = [curReceiverURL hasDirectoryPath];
//        
//        // ---------- Считывание размера файла ----------//
//        NSNumber *fileSizeValue = nil;
//        [curReceiverURL getResourceValue: &fileSizeValue
//                                forKey: NSURLFileSizeKey
//                                 error: nil];
////        if (fileSizeValue) {
////            self.sizeOfReceiverFile = [fileSizeValue longLongValue];
////        }
////        else {
////            // у папок размер уходит в err - считать с помощью суматорной глобальной переменной просто вовремя ее приравнивать
////            self.sizeOfReceiverFile = 0;
////        }
//        self.sizeOfReceiverFile = (fileSizeValue) ? ([fileSizeValue longLongValue]) : (0);
//        
//        // ---------- Считывание даты файла ----------//
//        NSDate  *fileDateValue = nil;
//        [curReceiverURL getResourceValue: &fileDateValue
//                                forKey: NSURLContentModificationDateKey
//                                 error: nil];
//        if (fileDateValue) {
//            NSDateFormatter *dateformate = [[NSDateFormatter alloc] init];
//            [dateformate setDateFormat: @"dd-MM-yyyy HH:mm:ss"];            // Date formater
//            self.stringReceiverDate = [dateformate stringFromDate: fileDateValue];  // Convert date to string
//        }
//        else {
//            self.stringReceiverDate = @"";
//        }
//        
////        // ---------- Считывание детей ----------
////        NSFileManager *fileManager = [NSFileManager defaultManager];
////        NSArray *urls = [fileManager contentsOfDirectoryAtURL: curReceiverURL
////                                   includingPropertiesForKeys: [NSArray arrayWithObjects: NSURLNameKey,
////                                                                NSURLIsDirectoryKey,
////                                                                NSURLContentModificationDateKey,
////                                                                NSURLTypeIdentifierKey,
////                                                                NSURLFileSizeKey,
////                                                                NSURLCustomIconKey,
////                                                                NSURLEffectiveIconKey, nil]
////                                                      options: NSDirectoryEnumerationSkipsHiddenFiles
////                                                        error: nil];
////        if (urls && _isFolder) {
////            long long folderSize = 0;
////            for (int i = 0; i < urls.count; i++) {
////                
////                // ---------- Считывание размера файла ----------//
////                NSNumber *fileSizeValue = nil;
////                [urls[i] getResourceValue: &fileSizeValue
////                                   forKey: NSURLFileSizeKey
////                                    error: nil];
////                if (fileSizeValue) {
////                    folderSize += [fileSizeValue longLongValue];
////                }
////                else {
////                    // у папок размер уходит в err - считать с помощью суматорной глобальной переменной просто вовремя ее приравнивать
////                    folderSize += 0;
////                }
////                
////                //            SFFile * curChild = [[SFFile alloc] initWithURLSourceFile: urls[i]
////                //                                                   andURLReceiverFile: [self comparisonCurURL: urls[i] andSearchFolder: curReceiverURL]]; //!!!!!!!!!
////                //            [_childrensArray addObject: curChild];
////            }
////            if (folderSize) {
////                self.sizeOfReceiverFile = folderSize;
////            }
////        }
//    }
//    
//    self.isFolder = (isSourceFolder || isReceiverFolder);
//    if (_isFolder) {
//        _childrensArray = [[NSMutableArray alloc] init];
//    }
//    else {
//        _childrensArray = nil;
//    }
    //    self.isFolder     = ( (curSourceURL) ? ([curSourceURL hasDirectoryPath])
    //                                         : ( (curReceiverURL) ? ([curReceiverURL hasDirectoryPath])
    //                                                              : (NO) ) );
    //    _childrensArray   = (_isFolder) ? ([[NSMutableArray alloc] init]) : (nil);

//}

//@property (strong) NSDate              * sourceDate;           // Дата файла ИСТОЧНИКА
//@property (strong) NSDate              * receiverDate;         // Дата файла ПРИЁМНИКА
//@property (strong) NSMutableDictionary * statusOfFile;      // Статус файла для наглядного отображения // readonly, copy

//- (id) initWithName : (NSString *) name date: (NSDate *) date andIsFolder: (bool) isFolder;
//- (void) addChildren : (SFFile *) file;
//- (id) initWithURLFile : (NSURL *) curURL;
// сопостовитель
//- (nullable NSURL *) comparisonCurURL : (NSURL *) curURL andSearchFolder : (NSURL *) folderURL {
//    
//    // ---------- Считывание имени файла ----------//
//    NSString *fileStringValue = nil;
//    [curURL getResourceValue: &fileStringValue
//                            forKey: NSURLNameKey
//                             error: nil];
//    if (fileStringValue) {
//        NSLog(@"curURL :: %@", curURL);
//    }
//    else {
//        NSLog(@"curURL :-: 000");
//    }
//    
//    // ---------- Считывание isFolder файла ----------//
//    NSLog(@"_isFolder :: %hhd", [curURL hasDirectoryPath]);
//    
//    // ---------- Считывание размера файла ----------//
//    NSNumber *fileSizeValue = nil;
//    [curURL getResourceValue: &fileSizeValue
//                            forKey: NSURLFileSizeKey
//                             error: nil];
//    if (fileSizeValue) {
//        NSLog(@"fileSizeValue :: %@", fileSizeValue);
//    }
//    else {
//        NSLog(@"curURL :-: 001");
//    }
//    
//    // ---------- Считывание даты файла ----------//
//    NSDate  *fileDateValue = nil;
//    [curURL getResourceValue: &fileDateValue
//                            forKey: NSURLContentModificationDateKey
//                             error: nil];
//    if (fileStringValue) {
//        NSDateFormatter *dateformate = [[NSDateFormatter alloc] init];
//        [dateformate setDateFormat: @"dd-MM-yyyy HH:mm:ss"];
//        NSLog(@"stringSourceDate :: %@", [dateformate stringFromDate: fileDateValue]);
//    }
//    else {
//        NSLog(@"curURL :-: 002");
//    }
//    
//    // ---------- Считывание детей ----------
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *urls = [fileManager contentsOfDirectoryAtURL: folderURL
//                               includingPropertiesForKeys: [NSArray arrayWithObjects: NSURLNameKey,
//                                                            NSURLIsDirectoryKey,
//                                                            NSURLContentModificationDateKey,
//                                                            NSURLTypeIdentifierKey,
//                                                            NSURLFileSizeKey,
//                                                            NSURLCustomIconKey,
//                                                            NSURLEffectiveIconKey, nil]
//                                                  options: NSDirectoryEnumerationSkipsHiddenFiles
//                                                    error: nil];
//    
//    NSLog(@"urls_folderURL :: %@", urls);
//    if (urls) {
//        for (int i = 0; i < urls.count; i++) {
//            
//            NSLog(@"------------------ %d ------------------", i);
//            NSString *fileStringValue = nil;
//            [urls[i] getResourceValue: &fileStringValue
//                              forKey: NSURLNameKey
//                               error: nil];
//            if (fileStringValue) {
//                NSLog(@"urls[i] :: %@", urls[i]);
//            }
//            else {
//                NSLog(@"urls[i] :-: 000");
//            }
//            
//            // ---------- Считывание isFolder файла ----------//
//            NSLog(@"urls[i]_isFolder :: %hhd", [urls[i] hasDirectoryPath]);
//            
//            // ---------- Считывание размера файла ----------//
//            NSNumber *fileSizeValue = nil;
//            [urls[i] getResourceValue: &fileSizeValue
//                              forKey: NSURLFileSizeKey
//                               error: nil];
//            if (fileSizeValue) {
//                NSLog(@"urls[i] :: %@", urls[i]);
//            }
//            else {
//                NSLog(@"urls[i] :-: 001");
//            }
//            
//            // ---------- Считывание даты файла ----------//
//            NSDate  *fileDateValue = nil;
//            [urls[i] getResourceValue: &fileDateValue
//                              forKey: NSURLContentModificationDateKey
//                               error: nil];
//            if (fileStringValue) {
//                NSDateFormatter *dateformate = [[NSDateFormatter alloc] init];
//                [dateformate setDateFormat: @"dd-MM-yyyy HH:mm:ss"];
//                NSLog(@"urls[i]-stringSourceDate :: %@", [dateformate stringFromDate: fileDateValue]);
//            }
//            else {
//                NSLog(@"urls[i] :-: 002");
//            }
//            
//            NSLog(@"------------------ - ------------------");
//
//        }
//    }
//    return nil;
//}
//


//    self.name     = [curURL lastPathComponent];
//            curChild.name = [urls[i] lastPathComponent];
//            curChild.isFolder = [urls[i] hasDirectoryPath];
//
//            NSLog(@"curChild name ::: %@",[urls[i] lastPathComponent]);
//            NSLog(@"curChild isDirectory ::: %hhd",[urls[i] hasDirectoryPath]);
//            //NSLog(@"typeIdentifier ::: %@",[urls[i] typeIdentifier]);
//            fileSizeValue = nil;
//            fileSizeError = nil;
//            [urls[i] getResourceValue: &fileSizeValue
//                                forKey: NSURLFileSizeKey
//                                error: &fileSizeError];
//            if (fileSizeValue) {
//                NSLog(@"value for %@ is %@", urls[i], fileSizeValue);
//                curChild.fileSize = fileSizeValue;
//            }
//            else {
//                NSLog(@"error getting size for url %@ error was %@", urls[i], fileSizeError); // у папок размер уходит в err - считать с помощью суматорной глобальной переменной просто вовремя ее приравнивать
//            }
//
//            if (curChild.isFolder) {
//                curChild
//            }

@end
