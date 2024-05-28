//
//  SFLoadingWindowsController.m
//  SynchronizeFileManager
//
//  Created by Евгений on 14.10.23.
//  Copyright © 2023 OverLanne. All rights reserved.
//

#import "SFLoadingWindowsController.h"

@interface SFLoadingWindowsController ()

@end

@implementation SFLoadingWindowsController


- (void)windowDidLoad {
    [super windowDidLoad];
    // Do view setup here.
    
    _isBreak = NO;
    
    [self.SFSizeFiles    setStringValue: @"0 MB из 0 MB"];
    [self.SFAmountFiles  setStringValue: @"0 из 0"];
    [self.SFPercentLable setStringValue: @"0%"];
    [self.SFCurFileLable setStringValue: @"NoneFile"];
    [self.SFLoadingTime  setStringValue: @"0h. 0m. 0s."];
    
    [self _finalFileTransferWithArray];
}

- (IBAction) stopLoadingButtonOnClick  : (NSButton *) sender {
    
    // завести переменную - isBreak
    // когда запущу ассинхронные вызовы :
    //      на основном потоке - обновлять меню и триггерить кнопку (менять isBreak)
    //      на доп потоке - копировать файлы и в начале цикла проверять isBreak
    // когда нажита кнопка - менять isBreak и состояние прогресс бара . переводить название в "Подготовка к закрытию файла"
    
    //[self.window setIsVisible: NO];
    _isBreak = YES;
    
    [NSApp stopModalWithCode: 1];
    [(SFWindow *)self.window setController:NULL];
    [self close];
    
//    [self performSelector:@selector(_breakLoad) withObject:NULL afterDelay:2.0];
}

- (void) _finalFileTransferWithArray { // : (NSMutableArray *) curArraySynchronize andSize : (long long) curSize
    // Эта должна быть в отдельном окне
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    //__block NSInteger totalCount = 0;
    [self.ProgressComparison setMaxValue: _curArraySynchronize.count];
    
////    NSLog(@"_curArraySynchronize %@", _curArraySynchronize);
//    for (int i = 0; i < _curArraySynchronize.count; i++) {
//        SFFile * nf = _curArraySynchronize[i];
////        NSLog(@"name - %@ - %@", nf.sourceURL, nf.receiverURL);
//    }
//    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        //totalCount = [self calculateCountItems];
//        dispatch_async(dispatch_get_main_queue(), ^(void){
//            // установка и обновление ПрогрессБара в main потоке
//            [self.ProgressComparison setMaxValue: totalCount];
//        });
        // вызов "сопоставления"
//        NSMutableArray * array = _filesArray;
//        [self comparisonTwoPathsWithURLSourceFile: _URLSource andURLReceiverFile: _URLReceiver withFillArray: &array];
        
        for (int i = 0; i < [_curArraySynchronize count]; i++) {
            
            if (_isBreak) {
                break;
            }
            
            SFFile  * childFile = _curArraySynchronize[i];
            NSError * error     = nil;
            
            if (childFile.receiverURL) {
//                NSLog(@"receiverURL - %@", childFile.receiverURL);
                BOOL result = [fileManager removeItemAtURL: childFile.receiverURL
                                                     error: &error];
                if (!result || error) {
                    NSLog(@"error DEL  ::: %@", error.localizedDescription);
                    error = nil;
                    continue;
                }
            }
            
//            NSLog(@"childFile.sourceURL = %@", childFile.sourceURL);
//            NSLog(@"_URLReceiver = %@", _URLReceiver);
            if (childFile.sourceURL && _URLReceiver) {  // Если существует файл из источника и путь к папки приемника, то...
                
                NSString * newFilePath2 = [[childFile.sourceURL path] substringWithRange:NSMakeRange([[_URLSource path] length], [[childFile.sourceURL path] length] - [[_URLSource path] length])];
                NSString * newFilePath = [NSString stringWithFormat: @"%@%@", [_URLReceiver path], newFilePath2];
                
                [self _checkCorrectFilePath:newFilePath withFileManager:fileManager andSourceFilePath:[childFile.sourceURL path]];
//                if ([[childFile.sourceURL path] length] > [[_URLSource path] length]) {
//                    NSString * newFilePath2 = [[childFile.sourceURL path] substringWithRange:NSMakeRange([[_URLSource path] length], [[childFile.sourceURL path] length] - [[_URLSource path] length])];
//                    
//                    NSLog(@"newFilePath - ||%@||", newFilePath2);
//                    
//                    // Создаем путь в папке-приемнике с включеным в него тек файлом
//                    NSString * newFilePath = [NSString stringWithFormat: @"%@%@", [_URLReceiver path], newFilePath2];
////                    NSString * path = [childFile.sourceURL path];
////                    
////                    NSString * fileName = [path lastPathComponent];
////                    path = [path stringByDeletingLastPathComponent];
////                    NSString * folder = [path lastPathComponent];
//                    
////                    NSString * newFilePath = [[_URLReceiver path] stringByAppendingPathComponent:folder];
////                    newFilePath = [newFilePath stringByAppendingPathComponent:fileName];
////                    NSString * newFilePath3 = [NSString stringWithFormat: @"%@/%@", [_URLReceiver path], [childFile.sourceURL lastPathComponent]];
//                    
//                    
//                    if ([fileManager fileExistsAtPath:newFilePath]) {
//                        BOOL result = [fileManager removeItemAtURL: [NSURL fileURLWithPath: newFilePath]
//                                                             error: &error];
//                        if (!result || error) {
//                            NSLog(@"error DEL 2  ::: %@", error.localizedDescription);
//                            error = nil;
//                            continue;
//                        }
//                    }
//                    NSLog(@"--------------------");
//                    NSLog(@"newFilePath - %@", newFilePath);
////                    NSLog(@"newFilePath3 - %@", newFilePath3);
//                    NSLog(@"sourceURL - %@", [childFile.sourceURL path]);
//                    NSLog(@"[NSURL fileURLWithPath: newFilePath] - %@", [NSURL fileURLWithPath: newFilePath]);
//                    NSLog(@"[sourceURL] - %@", childFile.sourceURL);
//                    if ([fileManager fileExistsAtPath:[childFile.sourceURL path]]) {
//                        //BOOL result = [fileManager copyItemAtURL: childFile.sourceURL toURL: [NSURL fileURLWithPath: newFilePath] error: &error];
//                        BOOL result = [fileManager copyItemAtPath:[childFile.sourceURL path] toPath:newFilePath error:&error];
//                        if (!result || error) {
//                            NSLog(@"error COPY  ::: %@", error.localizedDescription);
//                            error = nil;
//                            continue;
//                        }
//                    }
//                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                // итоговое взаимодействие с элементами интерфейса в main потоке
                [self.ProgressComparison incrementBy: 1.0];
                double maxValue = self.ProgressComparison.maxValue;
                double doubleValue = self.ProgressComparison.doubleValue;
                [self.SFPercentLable setStringValue: [NSString stringWithFormat:@"%.0f%%", round(100.0f / (maxValue / doubleValue))]];
                [self.SFCurFileLable setStringValue: [NSString stringWithFormat:@"%@/%@", [_URLReceiver path], [childFile.sourceURL lastPathComponent]]];
                [self.SFAmountFiles  setStringValue: [NSString stringWithFormat:@"%.0f из %.0f", doubleValue, maxValue]];
                [self.SFSizeFiles    setStringValue: [NSString stringWithFormat:@"%@ из %@", [NSByteCountFormatter stringFromByteCount: childFile.sizeOfSourceFile countStyle: NSByteCountFormatterCountStyleFile], [NSByteCountFormatter stringFromByteCount: _curSize countStyle: NSByteCountFormatterCountStyleFile]]];
//                NSLog(@"1");
            });
    
        }

    });

    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 1.8 * NSEC_PER_SEC);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
        [self.ProgressComparison incrementBy: 1.0];
        [NSApp stopModalWithCode: 0];
        [(SFWindow *)self.window setController:NULL];
        [self close];
    });
    
}

- (void) _checkCorrectFilePath : (NSString *) curPath withFileManager : (NSFileManager *) fileManager andSourceFilePath : (NSString *) sourcePath  {
    
    NSString * folderPath = [curPath stringByDeletingLastPathComponent];
//    NSString * sourceFolderPath = [sourcePath stringByDeletingLastPathComponent];
    NSLog(@"folderPath - ||%@||", folderPath);
    NSLog(@"fileExistsAtPath - ||%hhd||", [fileManager fileExistsAtPath:folderPath]);
    
    NSError * error = nil;
    if (![fileManager fileExistsAtPath:folderPath]) {
        BOOL result = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!result || error) {
            NSLog(@"error COPY  ::: %@", error.localizedDescription);
            error = nil;
            return;
        }
    }
    
    NSLog(@"--------------------");
    NSLog(@"curPath - %@", curPath);
    NSLog(@"sourcePath - %@", sourcePath);
    BOOL result = [fileManager copyItemAtPath:sourcePath toPath:curPath error:&error];
    if (!result || error) {
        NSLog(@"error COPY  ::: %@", error.localizedDescription);
        error = nil;
        return;
    }
    
//    if (![fileManager fileExistsAtPath:folderPath]) {
//        [self _checkCorrectFilePath:folderPath withFileManager:fileManager andSourceFilePath:sourceFolderPath wihtTrig:NO];
//    }
//    if ([curPath length] > [[_URLSource path] length]) {
//        NSError * error     = nil;
////        NSString * newFilePath2 = [curPath substringWithRange:NSMakeRange([[_URLSource path] length], [curPath length] - [[_URLSource path] length])];
//        
////        NSLog(@"newFilePath - ||%@||", newFilePath2);
//        
//        // Создаем путь в папке-приемнике с включеным в него тек файлом
////        NSString * newFilePath = [NSString stringWithFormat: @"%@%@", [_URLReceiver path], newFilePath2];
//        
//        if ([fileManager fileExistsAtPath:curPath]) {
//            BOOL result = [fileManager removeItemAtURL: [NSURL fileURLWithPath: curPath]
//                                                 error: &error];
//            if (!result || error) {
//                NSLog(@"error DEL 2  ::: %@", error.localizedDescription);
//                error = nil;
//                return;
//            }
//        }
//        NSLog(@"--------------------");
//        NSLog(@"curPath - %@", curPath);
//        NSLog(@"sourcePath - %@", sourcePath);
//        //BOOL result = [fileManager copyItemAtURL: childFile.sourceURL toURL: [NSURL fileURLWithPath: newFilePath] error: &error];
//        if (isFirstFolder) {
//            BOOL result = [fileManager copyItemAtPath:sourcePath toPath:curPath error:&error];
//            if (!result || error) {
//                NSLog(@"error COPY  ::: %@", error.localizedDescription);
//                error = nil;
//                return;
//            }
//        }
//        else if ([[NSURL fileURLWithPath:curPath] hasDirectoryPath] && !isFirstFolder) {
//            // если это папка и НЕ первое вхождение
//            
//            BOOL result = [fileManager createDirectoryAtPath:curPath withIntermediateDirectories:<#(BOOL)#> attributes:<#(nullable NSDictionary<NSString *,id> *)#> error:<#(NSError * _Nullable __autoreleasing * _Nullable)#>];
//            if (!result || error) {
//                NSLog(@"error COPY  ::: %@", error.localizedDescription);
//                error = nil;
//                return;
//            }
//        }
//    }
}

@end
