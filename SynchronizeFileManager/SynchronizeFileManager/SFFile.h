//
//  SFFile.h
//  SynchronizeFileManager
//
//  Created by Евгений on 10.08.23.
//  Copyright © 2023 OverLanne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

typedef enum : NSInteger {
    SFCheckboxOnState    = NSOnState,    // 1
    SFCheckboxOffState   = NSOffState,   // 0
    SFCheckboxMixedState = NSMixedState  // -1
} SFCheckboxState;

typedef enum : NSUInteger {
    SFFileStateAdd,     // 0
    SFFileStateDelete,  // 1
    SFFileStateUpdate  // 2 SFFileStateBuffer   // для oldState
} SFFileState;


@interface SFFile : NSObject {
    long long _sizeOfSourceFile;    // Размер файла ИСТОЧНИКА (в цифровом виде)
    long long _sizeOfReceiverFile;  // Размер файла ПРИЁМНИКА (в цифровом виде)
    
    BOOL _isSourceNameNil;          // Для определения является ли источник Nil
    BOOL _isReceiverNameNil;        // Для определения является ли приемник Nil
}

@property (nonatomic, strong) NSURL    * sourceURL;             // Урл ИСТОЧНИКА
@property (nonatomic, strong) NSURL    * receiverURL;           // Урл ПРИЁМНИКА
@property (nonatomic, strong) NSString * sourceName;            // Имя файла ИСТОЧНИКА
@property (nonatomic, strong) NSString * receiverName;          // Имя файла ПРИЁМНИКА
@property (nonatomic, strong) NSString * stringSourceDate;      // Строка-Дата файла ИСТОЧНИКА
@property (nonatomic, strong) NSString * stringReceiverDate;    // Строка-Дата файла ПРИЁМНИКА
@property (nonatomic, strong) NSDate   * sourceDate;            // Дата файла ИСТОЧНИКА
@property (nonatomic, strong) NSDate   * receiverDate;          // Дата файла ПРИЁМНИКА
@property (nonatomic, strong) NSString * stringSourceSize;      // Размер файла ИСТОЧНИКА (в строковом виде)
@property (nonatomic, strong) NSString * stringReceiverSize;    // Размер файла ПРИЁМНИКА (в строковом виде)
@property (nonatomic) long long          sizeOfSourceFile;      // Размер файла ИСТОЧНИКА (в цифровом виде)
@property (nonatomic) long long          sizeOfReceiverFile;    // Размер файла ПРИЁМНИКА (в цифровом виде)
@property (nonatomic) long long          sizeOfFile;            // Размер SF файла (в цифровом виде)
@property (nonatomic, strong) NSImage  * sourceIcon;            // Иконка файла ИСТОЧНИКА
@property (nonatomic, strong) NSImage  * receiverIcon;          // Иконка файла ПРИЁМНИКА
@property (nonatomic, strong) NSArray  * childrensArray;        // Массив с подфайлами папки        // переделать в просто NSArray - с помощью передачи анмутабл копи

@property (nonatomic) NSColor          * sourceColor;           // Цвет ИСТОЧНИКА (первой половины)
@property (nonatomic) NSColor          * receiverColor;         // Цвет ПРИЁМНИКА (второй половины)
@property (nonatomic) BOOL               isFolder;              // Это папка
@property (nonatomic) SFCheckboxState    checkboxState;         // Состояние чекбокса (0 - off,      1 - on,     -1 - mixed)
@property (nonatomic) SFFileState        infoState;             // Индекс статуса     (0 - добавить, 1 - удалить, 2 - обновить/заместить)
//@property (nonatomic) SFFileState        oldState;              // буфер для infoState


- (id) initWithURLSourceFile : (NSURL *) curSourceURL andURLReceiverFile : (NSURL *) curReceiverURL;

@end
