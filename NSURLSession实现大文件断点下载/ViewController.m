//
//  ViewController.m
//  NSURLSession实现大文件断点下载
//
//  Created by 周君 on 16/10/20.
//  Copyright © 2016年 周君. All rights reserved.
//


#import "ViewController.h"
#import "ZJProgressView.h"

//下载的文件
#define DownURL [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"]
//文件路径
#define FilePath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[[DownURL absoluteString] lastPathComponent]]
//已经下载的文件长度
#define DownLoadLength [[[NSFileManager defaultManager] attributesOfItemAtPath:FilePath error:nil][NSFileSize] integerValue]

@interface ViewController ()<ZJProgressViewDelegate, NSURLSessionDataDelegate>

/** 进度条*/
@property (nonatomic, strong) ZJProgressView *progressView;
/** 下载任务*/
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
/** 操作流*/
@property (nonatomic, strong) NSOutputStream *stream;
/** 文件总长度*/
@property (nonatomic, assign) NSInteger totalLength;
/** 操作对象*/
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation ViewController

- (ZJProgressView *)progressView
{
    if(!_progressView)
    {
        _progressView = [[ZJProgressView alloc] initWithFrame:(CGRect){self.view.center.x, self.view.center.y, 50, 50} AndBeignImage:nil AndPauseImage:nil];
        _progressView.delegate = self;
    }
    
    return _progressView;
}

- (NSOutputStream *)stream
{
    if(!_stream)
    {
        _stream = [NSOutputStream outputStreamToFileAtPath:FilePath append:YES];
    }
    
    return _stream;
}

- (NSURLSession *)session
{
    if(!_session)
    {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    
    return _session;
}

- (NSURLSessionDataTask *)dataTask
{
    if(!_dataTask)
    {
        /*
         * 下载流程
         * 1、先判断下载的文件是否下载完成，如果下载完成，就不创建任务
         * 2、创建任务，从已经下载过的长度进行下载
         */
        if (self.totalLength && self.totalLength == DownLoadLength)
        {
            self.progressView.percent = 1.0;
            return nil;
        }
        // 设置请求头的格式   Range : bytes=xxx-xxx 多少到多少，后面数据不写表示到文件结尾
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:DownURL];
        
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", DownLoadLength];
        
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        _dataTask = [self.session dataTaskWithRequest:request];
    }
    
    return _dataTask;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.progressView];
}
#pragma mark - ZJProgressViewDelegate
- (void)ZJProgressViewdidSelected:(ZJProgressView *)progressView isPause:(BOOL)pause
{
    if (pause)
    {
        [self.dataTask suspend];
    }
    else
    {
        [self.dataTask resume];
    }
}

#pragma mark - NSURLSessionDataDelegate
/** 接到响应*/
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    /*
     * 进行的操作：
     * 1、打开操作流
     * 2、得到数据总长度
     * 3、允许接收数据
     */
    [self.stream open];
    //总长度=返回的长度+下载的长度
    self.totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + DownLoadLength;
    //接收这个请求，允许接收服务器数据
    completionHandler(NSURLSessionResponseAllow);
}

/** 接收到数据*/
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    //写入数据
    [self.stream write:data.bytes maxLength:data.length];

    //改变下载进度
    self.progressView.percent = (1.0 * DownLoadLength / self.totalLength);
    
//    NSLog(@"%f", self.progressView.percent);
}
/** 请求完毕*/
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    //关闭流
    [self.stream close];
    self.stream = nil;
    
    //清除任务
    self.dataTask = nil;
}



@end
