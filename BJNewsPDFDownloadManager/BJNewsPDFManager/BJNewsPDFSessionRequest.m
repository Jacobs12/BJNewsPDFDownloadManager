//
//  BJNewsPDFSessionRequest.m
//  BJNewsPDFDownloadManager
//
//  Created by wolffy on 2017/9/7.
//  Copyright © 2017年 派博在线（北京）科技有限责任公司. All rights reserved.
//

#import "BJNewsPDFSessionRequest.h"

@interface BJNewsPDFSessionRequest () <NSURLSessionDelegate>

@end

@implementation BJNewsPDFSessionRequest

- (void)startRequest{
    /*
     一般模式（default）：工作模式类似于原来的NSURLConnection，可以使用缓存的Cache，Cookie，鉴权。
     及时模式（ephemeral）：不使用缓存的Cache，Cookie，鉴权。
     后台模式（background）：在后台完成上传下载，创建Configuration对象的时候需要给一个NSString的ID用于追踪完成工作的Session是哪一个
     */
    NSURLSessionConfiguration * ephemralConfigObject = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession * ephemralSession = [NSURLSession sessionWithConfiguration:ephemralConfigObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:self.url];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    self.dataTask = [ephemralSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
//            NSLog(@"NSURLSession下载失败 %@",url);
            if(self.failedBlock){
                self.failedBlock(data, response);
            }
        }else{
            //            NSLog(@"使用session下载成功");
//            NSLog(@"任务完成%@",self.url);
            if(self.finishBlock){
                self.finishBlock(data, response);
            }
        }
    }];
    [self.dataTask resume];
}

/**
 暂停下载
 */
- (void)suspendDataTask{
    if(self.dataTask == nil){
        return;
    }
    NSLog(@"任务暂停：%@",self.url);
    [self.dataTask suspend];
}

/**
 恢复下载
 */
- (void)resumeDataTask{
    if(self.dataTask == nil){
        [self startRequest];
        return;
    }
    if(self.dataTask.state == NSURLSessionTaskStateRunning){
        NSLog(@"NSURLSessionTaskStateRunning");
    }else if (self.dataTask.state == NSURLSessionTaskStateCanceling){
        NSLog(@"NSURLSessionTaskStateCanceling");
        [self.dataTask resume];
    }else if (self.dataTask.state == NSURLSessionTaskStateCompleted){
        NSLog(@"NSURLSessionTaskStateCompleted");
        [self.dataTask resume];
    }else if (self.dataTask.state == NSURLSessionTaskStateSuspended){
        NSLog(@"NSURLSessionTaskStateSuspended");
        [self.dataTask resume];
    }else{
        [self.dataTask resume];
    }
}

/**
 移除下载
 */
- (void)cancelDataTask{
    [self.dataTask cancel];
}

@end
