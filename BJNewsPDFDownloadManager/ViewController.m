//
//  ViewController.m
//  BJNewsPDFDownloadManager
//
//  Created by wolffy on 2017/9/7.
//  Copyright © 2017年 派博在线（北京）科技有限责任公司. All rights reserved.
//

#import "ViewController.h"
#import "BJNewsPDFManager.h"

@interface ViewController (){
    NSArray * _array;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray * arr = @[
                      @"http://appimg2.tbnimg.com/ipaper/data/2017-09/08/A01/xjb20170908A01.pdf",
                      @"http://appimg2.tbnimg.com/ipaper/data/2017-09/08/A02/xjb20170908A02.pdf",
                      @"http://appimg2.tbnimg.com/ipaper/data/2017-09/08/A03/xjb20170908A03.pdf",
                      @"http://appimg2.tbnimg.com/ipaper/data/2017-09/08/A04/xjb20170908A04.pdf",
                      @"http://appimg2.tbnimg.com/ipaper/data/2017-09/08/A05/xjb20170908A05.pdf",
                      @"http://appimg2.tbnimg.com/ipaper/data/2017-09/08/A06/xjb20170908A06.pdf",
                      @"http://appimg2.tbnimg.com/ipaper/data/2017-09/08/A07/xjb20170908A07.pdf",
                      @"http://appimg2.tbnimg.com/ipaper/data/2017-09/08/A08/xjb20170908A08.pdf",
                      ];
    _array = arr;
    [[BJNewsPDFManager defaultManager] addRequestWithArray:arr];
    [[BJNewsPDFManager defaultManager] addRequestWithURL:@"http://appimg2.tbnimg.com/ipaper/data/2017-09/08/A06/xjb20170908A06.pdf" target:self finished:^(NSData * _Nullable responseData, NSURLResponse * _Nullable response) {
        
    } failed:^(NSData * _Nullable responseData, NSURLResponse * _Nullable response) {
        
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[BJNewsPDFManager defaultManager] suspendTaskWithUrl:@"http://appimg2.tbnimg.com/ipaper/data/2017-09/08/A06/xjb20170908A06.pdf"];
    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[BJNewsPDFManager defaultManager] setBackgroundTask:NO];
//    });
    [BJNewsPDFManager defaultManager].progressBlock = ^(NSString *process, NSString * _Nullable taskName) {
        NSLog(@"%@       %@",process,taskName);
    };
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pause:(id)sender{
//    for (NSString * url in _array) {
//        [[BJNewsPDFManager defaultManager] suspendTaskWithUrl:url];
//    }
    [[BJNewsPDFManager defaultManager] suspendTaskWithUrl:@"http://appimg2.tbnimg.com/ipaper/data/2017-09/08/A03/xjb20170908A03.pdf"];
}


@end
