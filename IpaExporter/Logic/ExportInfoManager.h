//
//  ExportInfoManager.h
//  IpaExporter
//
//  Created by 何遵祖 on 2016/9/28.
//  Copyright © 2016年 何遵祖. All rights reserved.
//
//  唯一能与界面逻辑直接交互的逻辑类 用于读取和存储界面的数据
//

#import <Foundation/Foundation.h>
#import "DetailsInfoData.h"
#import "Common.h"
#import "Singletion.h"

#define SAVE_DETAIL_ARRARY_KEY @"detailArray"
#define SAVE_PROJECT_PATH_KEY  @"projectPath"
#define SAVE_EXPORT_PATH_KEY   @"exportPath"
#define SAVE_SCENE_ARRAY_KEY   @"scenePath"

NS_ASSUME_NONNULL_BEGIN
@interface ExportInfoManager : Singletion
{
    NSUserDefaults* _saveData;
    NSMutableDictionary<NSString*, NSMutableArray*> *_savedict;
}

@property(nonatomic, readwrite) ExportInfo *info;
@property(nonatomic, readonly) NSMutableArray *unityProjPathArr;
@property(nonatomic, readonly) NSMutableArray *exportPathArr;
@property(nonatomic, readonly, getter=getDetailArray) NSMutableArray *detailArray;
@property(nonatomic, readonly, getter=getSceneArray) NSMutableArray *sceneArray;

- (void)addNewUnityProjPath:(NSString*)path;
- (void)replaceUnityProjPath:(NSString*)path;
- (void)addNewExportProjPath:(NSString*)path;
- (void)replaceExportProjPath:(NSString*)path;

//路径配置
- (void)reloadPaths;

//包配置 信息表格数据部分
- (NSMutableArray*)reLoadDetails:(NSString*)saveKey;
- (void)addDetail:(id)data withKey:(NSString*)saveKey;
- (void)removeDetail:(NSUInteger)index withKey:(NSString*)saveKey;
- (void)updateDetail:(NSUInteger)index withObject:(id)object withKey:(NSString*)saveKey;
- (void)saveData;
- (ExportInfo*)getData;
NS_ASSUME_NONNULL_END

@end
