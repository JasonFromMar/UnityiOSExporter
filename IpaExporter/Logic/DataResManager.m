//
//  DataControlBase.m
//  IpaExporter
//
//  Created by 何遵祖 on 2016/10/9.
//  Copyright © 2016年 何遵祖. All rights reserved.
//

#import "DataResManager.h"
#import "BaseDataCSCodeEdit.h"

@interface DataResManager()
{
    BOOL _isStarting;
    NSString* _srcPath;
    NSString* _dstPath;
    
    NSFileManager* _fileManager;
}
@end

@implementation DataResManager

- (id)init
{
    if (self = [super init])
    {
        _isStarting = NO;
        _fileManager = [NSFileManager defaultManager];
        _srcPath = [[[NSBundle mainBundle] resourcePath]stringByAppendingString:DATA_PATH];
    }
    
    return self;
}

- (void)start:(ExportInfo*)info
{
    _dstPath = [NSString stringWithFormat:@"%s/Assets/Editor", info->unityProjPath];
    [self copyResSrcPath:_srcPath toDst:_dstPath];
}

- (void)end
{
    [self removeResFromDstPath:_dstPath];
}

- (void)copyFolder:(NSString*) path
{
    BOOL isDir = NO;
    BOOL existed = [_fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDir && existed))
    {
        NSError* error;
        [_fileManager createDirectoryAtPath:path
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:&error];
        if(error != nil)
        {
            NSLog(@"*拷贝文件夹失败 原因:%@", error);
            NSLog(@"%@", [error userInfo]);
        }
    }
}

- (void)copyFile:(NSString*)src toDst:(NSString*)dst
{
    NSError* error = nil;
    [_fileManager copyItemAtPath:src toPath:dst error:&error];
    if(error != nil)
    {
        showError("*拷贝文件失败 原因:%@", error);
        NSLog(@"%@", [error userInfo]);
    }
}

- (void)copyResSrcPath:(NSString*)src toDst:(NSString*)dst
{
    //文件夹存在就删除
    [self removeResFromDstPath:_dstPath];
    
    //判断路径是否为文件夹
    NSString* pType = [src pathExtension];
    NSString* dstType = [dst pathExtension];
    if([pType isEqualTo:@""] && [dstType isEqualToString:@""])
    {
        NSDirectoryEnumerator* direnum;
        direnum = [_fileManager enumeratorAtPath:src];
        
        NSString* root = [dst stringByAppendingString:DATA_PATH];
        [self copyFolder:root];

        NSString* path;
        while (path = [direnum nextObject])
        {
            if(![path isEqualToString:@".DS_Store"])
            {
                NSString* pType = [path pathExtension];
                if([pType isEqualTo:@""])
                {
                    NSString* dirPath = [NSString stringWithFormat:@"%@/%@", root, path];
                    [self copyFolder:dirPath];
                }
                else
                {
                    NSString* f = [NSString stringWithFormat:@"%@/%@", src, path];
                    NSString* d = [NSString stringWithFormat:@"%@/%@", root, path];
                    [self copyFile:f toDst:d];
                }
            }
        }
    }
    else if(![pType isEqualTo:@""] && ![dstType isEqualToString:@""])
    {
        [self copyFile:src toDst:dst];
    }
    else
    {
        NSLog(@"*[DataResManager]:错误的参数类型");
        NSLog(@"%@", src);
        NSLog(@"%@", dst);
    }
}

- (void)removeResFromDstPath:(NSString*)dst
{
    NSString* root = [dst stringByAppendingString:DATA_PATH];
    NSError* error = nil;
//    NSString* metaPath = [NSString stringWithFormat:@"%@.meta", root];
    
    BOOL isDir;
    BOOL isDirExit = [_fileManager fileExistsAtPath:dst isDirectory:&isDir];
    
    if(isDirExit && isDir){
        [_fileManager removeItemAtPath:root error:&error];
    }
    
//    if([_fileManager fileExistsAtPath:metaPath]){
//        [_fileManager removeItemAtPath:metaPath error:&error];
//    }
    
    if(error != nil)
    {
        NSLog(@"*[DataResManager]:移除目标路径文件失败:%@ 错误原因:%@", dst, error);
        NSLog(@"*[DataResManager]:%@", [error userInfo]);
    }
}

@end
