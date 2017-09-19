//
//  BJNewsPDFManager.m
//  BJNewsPDFDownloadManager
//
//  Created by wolffy on 2017/9/7.
//  Copyright © 2017年 派博在线（北京）科技有限责任公司. All rights reserved.
//

#import "BJNewsPDFManager.h"
#import "BJNewsPDFSessionRequest.h"

static BJNewsPDFManager * bjnews_pdf_manager = nil;

#define MAX_CURRENT_REQUESTS 1 // 超出限制后，不执行后台下载任务

@interface BJNewsPDFManager (){
    NSMutableDictionary * _requestDict; // 储存当前正在进行的任务
    NSMutableArray * _dataTaskArray;    // 储存准备后台下载的任务
    NSInteger _expectCount;           // 总的后台下载数量
}

@end

@implementation BJNewsPDFManager

- (instancetype)init{
    self = [super init];
    if(self){
        _requestDict = [[NSMutableDictionary alloc]init];
        _dataTaskArray = [[NSMutableArray alloc]init];
    }
    return self;
}

/**
 创建单例对象
 
 @return PDF管理对象
 */
+ (BJNewsPDFManager *_Nullable)defaultManager{
    if(bjnews_pdf_manager == nil){
        bjnews_pdf_manager = [[BJNewsPDFManager alloc]init];
        bjnews_pdf_manager.isAllowBackgroundTask = YES;
    }
    return bjnews_pdf_manager;
}

/**
 是否允许后台下载
 
 @param isAllow 是否允许后台下载
 */
- (void)setBackgroundTask:(BOOL)isAllow{
    self.isAllowBackgroundTask = isAllow;
    if(isAllow){
        NSLog(@"后台自动下载任务开启");
    }else{
        NSLog(@"后台自动下载任务关闭");
    }
}

#pragma mark - 
#pragma mark - 添加任务

/**
 添加多个请求任务

 @param urlArray 请求任务url数组
 */
- (void)addRequestWithArray:(NSArray *_Nullable)urlArray{
    for (NSString * url in urlArray) {
        if(![url isKindOfClass:[NSString class]]){
            continue;
        }
        if([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]){
            
        }else{
            continue;
        }
        //    创建一个新的任务
        BJNewsPDFSessionRequest * request = [[BJNewsPDFSessionRequest alloc]init];
        request.url = url;
        request.target = nil;
        __weak BJNewsPDFManager * weak_self = self;
        request.finishBlock = ^(NSData * _Nullable responseData, NSURLResponse * _Nullable response) {
            [weak_self removeRequestWithURL:url];
        };
        request.failedBlock = ^(NSData * _Nullable responseData, NSURLResponse * _Nullable response) {
            [weak_self removeRequestWithURL:url];
        };
        [self pushStack:request];
    }
    _expectCount = urlArray.count;
}

/**
 添加一个请求
 
 @param url 请求地址
 @param target 响应目标
 @param finished 成功回调
 @param failed 失败回调
 */
- (void)addRequestWithURL:(NSString *_Nullable)url target:(id _Nullable )target finished:(void (^_Nullable) (NSData * _Nullable responseData, NSURLResponse * _Nullable response))finished failed:(void (^_Nullable) (NSData * _Nullable responseData, NSURLResponse * _Nullable response))failed{
//    从字典中取得需要下载的数据
    BJNewsPDFSessionRequest * request = _requestDict[url];
//    如果url处于当前下载
    if(request){ // 切换target，防止对象被释放无法加载PDF
        [self changeRequestTargetWithUrl:url target:target finished:finished failed:failed];
        return;
    }
//    改变当前request的优先级
//    collection view cell end display 调用 suspend，来暂停下载任务,控制同时下载数量
//    如果栈中存在任务，提取栈中的任务
    if(_dataTaskArray.count){
        request = nil;
        for (BJNewsPDFSessionRequest * task in _dataTaskArray) {
            if([url isEqualToString:task.url]){
                request = task;
            }
        }
        if(request){
            [_dataTaskArray removeObject:request];
            //    任务优先下载
            [_requestDict setObject:request forKey:request.url];
            [self changeRequestTargetWithUrl:url target:target finished:finished failed:failed];
            //    开始下载任务
            [request resumeDataTask];
            return;
        }
    }
//    创建一个新的任务
    request = [[BJNewsPDFSessionRequest alloc]init];
    request.url = url;
//    任务优先下载
    [_requestDict setObject:request forKey:request.url];
    [self changeRequestTargetWithUrl:url target:target finished:finished failed:failed];
//    开始下载任务
//    [request startRequest];
    [request resumeDataTask];
}

#pragma mark - 任务处理

/**
 切换请求的响应目标，防止对象被释放无法加载PDF

 @param url  PDF url
 */
- (void)changeRequestTargetWithUrl:(NSString *)url target:(id _Nullable )target finished:(void (^_Nullable) (NSData * _Nullable responseData, NSURLResponse * _Nullable response))finished failed:(void (^_Nullable) (NSData * _Nullable responseData, NSURLResponse * _Nullable response))failed{
    for (NSString * requestKey in _requestDict.allKeys) {
        if([requestKey isEqualToString:url]){
            BJNewsPDFSessionRequest * currentRequest = _requestDict[requestKey];
            if(currentRequest){
                currentRequest.target = target;
//                currentRequest.finishBlock = finished;
//                currentRequest.failedBlock = failed;
                __weak BJNewsPDFManager * weak_self = self;
                currentRequest.finishBlock = ^(NSData * _Nullable responseData, NSURLResponse * _Nullable response) {
                    if(finished){
                        [weak_self removeRequestWithURL:url];
                        finished(responseData,response);
                    }
                };
                currentRequest.failedBlock = ^(NSData * _Nullable responseData, NSURLResponse * _Nullable response) {
                    if(failed){
                        [weak_self removeRequestWithURL:url];
                        failed(responseData,response);
                    }
                };
                NSLog(@"request 切换成功%@",url);
                [currentRequest resumeDataTask];
            }
        }
    }
}

/**
 暂停当前下载
 */
- (void)suspendCurrentDataTask{
    if(_requestDict.count >= MAX_CURRENT_REQUESTS){
        
    }else{
        return;
    }
//     暂停下载，并且该任务优先级排到最低
    for (BJNewsPDFSessionRequest * request in _dataTaskArray) {
        [request suspendDataTask];
        [self pushStack:request];
    }
}

/**
 暂停指定下载任务

 @param url 需要暂停的url
 */
- (void)suspendTaskWithUrl:(NSString *_Nullable)url{
    NSMutableArray * deleteArray = [[NSMutableArray alloc]init];
    for (NSString * key in _requestDict.allKeys) {
        if(![key isEqualToString:url]){
            continue;
        }
        BJNewsPDFSessionRequest * request = _requestDict[key];
        [request suspendDataTask];
        [deleteArray addObject:request];
    }
    if(deleteArray.count == 0){
        return;
    }
    for (BJNewsPDFSessionRequest * request in deleteArray) {
        [_requestDict removeObjectForKey:request.url];
        [_dataTaskArray addObject:request];
    }
    [deleteArray removeAllObjects];
//        自动开始下一个任务
    [self startNextTask];
}

/**
 移除已经完成的下载

 @param url url
 */
- (void)removeRequestWithURL:(NSString *_Nullable)url{
    if(_requestDict && _requestDict.count > 0){
        
    }else{
        return;
    }
    //    回调下载进度
    [self callBack:url];
    for (NSString * key in _requestDict.allKeys) {
        if(![url isEqualToString:key]){
            continue;
        }
        [_requestDict removeObjectForKey:url];
//        自动开始下一个任务
        [self startNextTask];
    }
}

#pragma mark - 
#pragma mark -  回调处理
- (void)callBack:(NSString *)url{
    if(!self.progressBlock){
        return;
    }
    if(_expectCount <= 0){
        return;
    }
    NSString * progress = [NSString stringWithFormat:@"%.1f",(1.0 - (float)_dataTaskArray.count / (float)_expectCount) * 100];
    if(_dataTaskArray.count <= 0){
        self.progressBlock(progress,@"缓存完成");
        return;
    }
    BJNewsPDFSessionRequest * request = _dataTaskArray[0];
    NSString * task_url = request.url;
    NSArray * arr = [task_url componentsSeparatedByString:@"/"];
    if(!arr || arr.count == 0){
        return;
    }
    NSString * fileName = [arr lastObject];
    if(fileName.length < 14){
        return;
    }
    NSString * pageNo = [fileName substringWithRange:NSMakeRange(11, 3)];
    NSString * date = [fileName substringWithRange:NSMakeRange(3, 8)];
    NSMutableString * dateForm = [[NSMutableString alloc]init];
    for(NSInteger i=0;i<date.length;i++){
        char c = [date characterAtIndex:i];
        [dateForm appendString:[NSString stringWithFormat:@"%c",c]];
        if(i == 3 || i == 5){
            [dateForm appendString:@"-"];
        }
    }
    self.progressBlock(progress, [NSString stringWithFormat:@"正在缓存：%@ %@",dateForm,pageNo]);
}

#pragma mark - 栈

- (void)startNextTask{
    if(_requestDict.count >= MAX_CURRENT_REQUESTS){
        return;
    }
    //        如果不允许后台下载，例如非wifi状态下
    if(self.isAllowBackgroundTask == NO){
        return;
    }
    //        下完一个，下排队的
    BJNewsPDFSessionRequest * request = [self popStack];
    if(!request){
        return;
        
    }
    [_requestDict setObject:request forKey:request.url];
    //        [request startRequest];
    [request resumeDataTask];
}

/**
 入栈

 @param request request
 */
- (void)pushStack:(BJNewsPDFSessionRequest *)request{
    if(_dataTaskArray == nil){
        _dataTaskArray = [[NSMutableArray alloc]init];
    }
    [_dataTaskArray addObject:request];
    
    NSLog(@"入栈---当前有%lu个请求在排队",(unsigned long)_dataTaskArray.count);
}

/**
 出栈

 @return 优先级最高的任务
 */
- (BJNewsPDFSessionRequest *)popStack{
    if(!_dataTaskArray || _dataTaskArray.count == 0){
        return nil;
    }
    BJNewsPDFSessionRequest * request = _dataTaskArray[0];
    [_dataTaskArray removeObjectAtIndex:0];
    NSLog(@"出栈---当前还有%lu个请求排队",(unsigned long)_dataTaskArray.count);
    return request;
}

@end
