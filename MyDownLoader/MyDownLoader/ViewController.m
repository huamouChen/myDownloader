//
//  ViewController.m
//  MyDownLoader
//
//  Created by HuaMou.Chen on 2017/12/10.
//  Copyright © 2017年 HuaMou.Chen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLConnectionDataDelegate>
// 文件的大小
@property (nonatomic, assign) long long totalLength;
// 当前接收的大小
@property (nonatomic, assign) long long currentLength;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
// 句柄操作
@property (nonatomic, strong) NSFileHandle *fileHandle;
// 输出流
@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, strong) NSURLConnection *connection;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@end

@implementation ViewController
// 开始下载
- (IBAction)startAction:(id)sender {
    NSString *urlString = @"http://huamouchen.info/video/2.flv";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 获取已经下载的大小
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/huamouchen/Desktop/2.flv"];
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",data.length];
    
    // 设置开始下载的位置
    [request setValue:range forHTTPHeaderField:@"Range"];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
// 暂停下载
- (IBAction)endAction:(id)sender {
    [self.connection cancel];
    self.connection = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:@"1.pm4"];
}

#pragma mark - NSURLConnectionDataDelegate
// 收到服务器响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%s", __FUNCTION__);
    // 要下载的文件的总大小
    self.totalLength = response.expectedContentLength;

//    // 句柄操作
//    NSLog(@"文件的总大小是-------------%zd", response.expectedContentLength);
//    // 文件缓存路径
//    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *filepath = [caches stringByAppendingPathComponent:response.suggestedFilename];
//    NSLog(@"file path is ---------- %@", filepath);
//    // 创建一个文件管理对象
//    [[NSFileManager defaultManager] createFileAtPath:filepath contents:nil attributes:nil];
//    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filepath];
    
    // output stream
    NSString *outputPath = [NSString stringWithFormat:@"/Users/huamouchen/Desktop/%@", response.suggestedFilename];
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:outputPath append:YES];
    [self.outputStream open];// 打开

}

// 当接收到服务器返回的尸体数据时调用
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"接收到的数据大小为------------%zd", data.length / 1024);
    // 句柄操作
    // 接收多少，就写入多少，避免内存溢出
    // 1. 设置偏移量， 句柄操作
//    [self.fileHandle seekToEndOfFile];// 每次都移到最后
//    [self.fileHandle writeData:data];
    
   
    // 输出流
    [self.outputStream write:data.bytes maxLength:data.length];
    
    self.currentLength += data.length;
    // 更新进度条
    self.progressView.progress = (double)_currentLength / self.totalLength;
    
    self.progressLabel.text = [NSString stringWithFormat:@"%f", self.progressView.progress * 100];
    
}

// 加载完毕后调用
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"%s", __FUNCTION__);

    self.currentLength = 0;
    self.totalLength = 0;
    
    // 关闭文件
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    
    
    // 关闭流
    [self.outputStream close];
}

// 请求失败
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
}




@end
