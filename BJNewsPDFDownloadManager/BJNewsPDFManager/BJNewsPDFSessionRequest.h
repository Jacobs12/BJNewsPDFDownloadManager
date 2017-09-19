//
//  BJNewsPDFSessionRequest.h
//  BJNewsPDFDownloadManager
//
//  Created by wolffy on 2017/9/7.
//  Copyright © 2017年 派博在线（北京）科技有限责任公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BJNewsPDFSessionRequest : NSObject

/**
 url
 */
@property (nonatomic,copy) NSString * _Nullable url;

/**
 记录接收数据的对象
 */
@property (weak) id _Nullable target;

/**
 dataTask
 */
@property (nonatomic,strong) NSURLSessionDataTask * _Nullable dataTask;

/**
 成功回调
 */
@property (nonatomic,copy) void (^ _Nullable finishBlock) (NSData * _Nullable responseData, NSURLResponse * _Nullable response);

/**
 失败回调
 */
@property (nonatomic,copy) void (^ _Nullable failedBlock) (NSData * _Nullable responseData, NSURLResponse * _Nullable response);

/**
 开始下载任务
 */
- (void)startRequest;

/**
 暂停下载
 */
- (void)suspendDataTask;

/**
 恢复下载
 */
- (void)resumeDataTask;

/**
 移除下载
 */
- (void)cancelDataTask;


@end
