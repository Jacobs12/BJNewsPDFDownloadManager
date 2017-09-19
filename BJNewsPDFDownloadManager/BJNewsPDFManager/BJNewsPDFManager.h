//
//  BJNewsPDFManager.h
//  BJNewsPDFDownloadManager
//
//  Created by wolffy on 2017/9/7.
//  Copyright © 2017年 派博在线（北京）科技有限责任公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BJNewsPDFManager : NSObject

/**
 是否允许后台下载
 */
@property (nonatomic,assign) BOOL isAllowBackgroundTask;

/**
 下载进度
 */
@property (nonatomic,copy) void (^ _Nullable progressBlock) (NSString * _Nullable process,NSString * _Nullable taskName);

/**
 创建单例对象

 @return PDF管理对象
 */
+ (BJNewsPDFManager *_Nullable)defaultManager;

/**
 是否允许后台下载

 @param isAllow 是否允许后台下载
 */
- (void)setBackgroundTask:(BOOL)isAllow;

/**
 添加多个请求任务
 
 @param urlArray 请求任务url数组
 */
- (void)addRequestWithArray:(NSArray *_Nullable)urlArray;

/**
 添加一个请求

 @param url 请求地址
 @param target 响应目标
 @param finished 成功回调
 @param failed 失败回调
 */
- (void)addRequestWithURL:(NSString *_Nullable)url target:(id _Nullable )target finished:(void (^_Nullable) (NSData * _Nullable responseData, NSURLResponse * _Nullable response))finished failed:(void (^_Nullable) (NSData * _Nullable responseData, NSURLResponse * _Nullable response))failed;

/**
 移除已经完成的下载
 
 @param url url
 */
- (void)removeRequestWithURL:(NSString *_Nullable)url;

/**
 暂停指定下载任务
 collection view cell end display 调用 suspend，来暂停下载任务,控制同时下载数量
 
 @param url 需要暂停的url
 */
- (void)suspendTaskWithUrl:(NSString *_Nullable)url;

@end
