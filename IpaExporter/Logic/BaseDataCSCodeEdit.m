//
//  DataCSCodeEdit.m
//  IpaExporter
//
//  Created by 何遵祖 on 2016/10/11.
//  Copyright © 2016年 何遵祖. All rights reserved.
//

#import "BaseDataCSCodeEdit.h"
#import "BaseDataCSCodePrivate.h"
#import "ExportInfoManager.h"
#import "Common.h"

@implementation BaseDataCSCodeEdit

- (void)start:(NSString*)dstPath withPackInfo:(DetailsInfoData*)info
{    
}

- (BOOL)initWithPath:(NSString*)path
{
    _path = path;
        
    NSError* error;
    _content = [NSMutableString stringWithContentsOfFile:path
                                                encoding:NSUTF8StringEncoding
                                                   error:&error];
    if(error != nil)
    {
        showError("读取路径文件失败:%@", path);
        NSLog(@"%@", error);
        NSLog(@"%@", [error userInfo]);
        return NO;
    }
        
    _lines = [_content componentsSeparatedByString:@"\n"];
    
    return YES;
}

/*
 通过key来取和替换变量 以def文件中的为准
 */
- (void)replaceVarFromData:(DetailsInfoData*)data withKeyArr:(NSArray*)keyArr
{
    NSString *replaceFormat = @"\"%@\"";
    NSMutableString* result = [NSMutableString stringWithString:_content];
    for(int i = 0; i < [keyArr count]; i++)
    {
        NSString *key = [keyArr objectAtIndex:i];
        NSString *keyStr = [NSString stringWithFormat:@"//木有任何数据"];
        
        if([key isEqualToString:Export_Path])
        {
            ExportInfo* info = [ExportInfoManager instance].info;
            const char* path = info->exportFolderParh;
            keyStr = [NSString stringWithUTF8String:path];
        }
        else if([key isEqualToString:Pack_Scene])
        {
            NSMutableArray *scenes = [ExportInfoManager instance].sceneArray;
            keyStr = [self getReplaceStrFromArray:scenes];
        }
        else
        {
            keyStr = [data getValueForKey:key];
            //需要特殊处理的
            if([key isEqualToString:Debug_Profile_Name])
            {
                NSString *profileName = keyStr;
                NSString *teamName = [data getValueForKey:Debug_Develop_Team];
                i++;
                
                NSString *args = [NSString stringWithFormat:@"DevelopType.Debug, \"%@\",\"%@\"", teamName, profileName];
                keyStr = [self createCSClassStr:@"DevelopmentInfo" withArgsStr:args];
                key = @"developmentInfoDebug";
                replaceFormat = @"%@";
            }
            else if([key isEqualToString:Release_Profile_Name])
            {
                NSString *profileName = keyStr;
                NSString *teamName = [data getValueForKey:Release_Develop_Team];
                i++;
                
                NSString *args = [NSString stringWithFormat:@"DevelopType.Release, \"%@\",\"%@\"", teamName, profileName];
                keyStr = [self createCSClassStr:@"DevelopmentInfo" withArgsStr:args];
                key = @"developmentInfoRelease";
                replaceFormat = @"%@";
            }
            else if([key isEqualToString:Frameworks])
            {
                NSArray *names =  data.frameworkNames;
                NSArray *isWeaks = data.frameworkIsWeaks;
                NSMutableArray *classArr = [[NSMutableArray alloc] initWithCapacity:10];
                
                for (int i = 0; i < [names count]; i++)
                {
                    NSString *name = names[i];
                    NSString *isWeak = isWeaks[i];
                    
                    NSString *args = [NSString stringWithFormat:@"\"%@\",%@", name, isWeak];
                    NSString *classStr = [self createCSClassStr:@"FrameworkSet" withArgsStr:args];
                    [classArr addObject:classStr];
                }
                
                keyStr = [classArr componentsJoinedByString:@"\n"];
                replaceFormat = @"%@";
            }
            else if([key isEqualToString:Libs])
            {
                NSArray *names = data.libNames;
                keyStr = [self getReplaceStrFromArray:names];
                replaceFormat = @"\"%@\"";
            }
            else if([key isEqualToString:Linker_Flag])
            {
                NSArray *names = data.linkerFlag;
                keyStr = [self getReplaceStrFromArray:names];
                replaceFormat = @"\"%@\"";
            }
        }
        
        [result replaceOccurrencesOfString:[NSString stringWithFormat:@"${%@}", key]
                                  withString:[NSString stringWithFormat:replaceFormat, keyStr]
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [result length])];

    }
    
    [self replaceContent:result];
}

- (void)replaceContent:(NSString*) newContent
{
    NSError* error;
    [newContent writeToFile:_path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(error != nil)
    {
        showError("*替换内容失败:目标路径%@", _path);
        NSLog(@"%@", error);
        NSLog(@"%@", [error userInfo]);
    }
}

//多个选项转成字符串
- (NSString*)getReplaceStrFromArray:(NSArray<NSString*> *) array
{
    NSMutableArray *classArr = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i = 0; i < [array count]; i++)
    {
        NSString *name = array[i];
        [classArr addObject:name];
    }
    
    NSString *keyStr = [classArr componentsJoinedByString:@",\n"];
    return keyStr;
}

//argsStr: 格式 args1,args2
- (NSString*) createCSClassStr:(NSString*)className withArgsStr:(NSString*)argsStr
{
    NSArray<NSString*> *argsArr = [argsStr componentsSeparatedByString:@"|"];
    NSString *newStr = [[NSString alloc] init];
    
    for (int i = 0; i < [argsArr count]; i++)
    {
        NSString *str = argsArr[i];
        NSString *classStr = [NSString stringWithFormat:@"new %@(%@),", className, str];
        if(i == [argsArr count] - 1)
            newStr = [newStr stringByAppendingFormat:@"%@", classStr];
        else
            newStr = [newStr stringByAppendingFormat:@"%@,\n", classStr];
    }

    return newStr;
}

@end
