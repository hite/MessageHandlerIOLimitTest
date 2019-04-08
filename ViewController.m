//
//  ViewController.m
//  MessageHandlerIOLimitTest
//
//  Created by liang on 2019/4/4.
//  Copyright © 2019 liang. All rights reserved.
//

#import "ViewController.h"

@import WebKit;

@interface ViewController () <WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ViewController{
    UITextField *_input;
}

static NSString *sample1024 = @"The Cranberries The Cranberries The Cranberries The CranberriesThe Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries 1239384283423423423423423424234552534234The CranberriesThe Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The CranberriesThe Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries 1239384283423423423423423424234552534234 The CranberriesThe Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The CranberriesThe Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries 1239384283423423423423423424234552534234 The CranberriesThe Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The CranberriesThe Cranberries The Cranberries The Cranberries The Cranberries 471589964142";
- (void)check:(id)sender
{
    NSInteger i = [_input.text intValue];
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:100];
    if (i > 0) {
        NSInteger count = i / 1024;
        NSInteger left = i % 1024;
        for (NSInteger i = 0; i < count; i++) {
            [data addObject:sample1024];
        }
        [data addObject:[sample1024 substringToIndex:left]];
        
        NSString *toStr = [data componentsJoinedByString:@""];
        NSInteger total = toStr.length;
        long long time = [[NSDate date] timeIntervalSince1970] * 1000;
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"window.onReceived('%@',%ld, %lld)", toStr, (long)total, time] completionHandler:nil];
    } else {
        NSLog(@"Nothing happened.");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.webView];
    
    // 左边输入框，右边是添加按钮
    UILabel *l = [UILabel new];
    l.text = @"测试向 h5 发数据";
    [l sizeToFit];
    [self.view addSubview:l];
    l.center = CGPointMake(100, 80);
    
    _input = [UITextField new];
    _input.frame = CGRectMake(5, 100, 200, 34);
    [self.view addSubview:_input];
    _input.placeholder = @"1048576";
    _input.layer.borderColor = [UIColor redColor].CGColor;
    _input.layer.borderWidth = 1.f;
    _input.textColor = [UIColor blueColor];
    
    UIButton *submit = [UIButton new];
    submit.frame = CGRectMake(210, 100, 60, 34);
    [submit setTitle:@"try" forState:UIControlStateNormal];
    [submit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [submit addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submit];
    
    // NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://10.242.24.59:9999/index.html"]];
    // [self.webView loadRequest:req];
   NSURL *mainBundlePath = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];

   NSError *error;
   NSStringEncoding encoding = NSUTF8StringEncoding;
   NSString *content = [NSString stringWithContentsOfURL:mainBundlePath encoding:encoding error:&error];
   [self.webView loadHTMLString:content baseURL:[NSURL URLWithString:@"https://qian.163.com"]];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:@"f"]) {
        NSDictionary *body = message.body;
        
        NSString *content = [body objectForKey:@"content"];
        int bodyLen = [[body objectForKey:@"length"] intValue];
        long long time = [[NSDate date] timeIntervalSince1970] * 1000;
        NSLog(@"body.length = %d, costtime = %lld", bodyLen, time - [[body objectForKey:@"time"] longLongValue]);
        NSLog(@"Is Equal ? %d", content.length == bodyLen);
    }
}

- (WKWebView *)webView
{
    if (_webView == nil) {
        // 设置加载页面完毕后，里面的后续请求，如 xhr 请求使用的cookie
        WKUserContentController *userContentController = [WKUserContentController new];
        [userContentController addScriptMessageHandler:self name:@"f"];
        WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
        
        webViewConfig.allowsInlineMediaPlayback = YES;
        webViewConfig.userContentController = userContentController ;
    
        CGRect size = [[UIScreen mainScreen] bounds];
        WKWebView *webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 200, CGRectGetWidth(size), CGRectGetHeight(size)) configuration:webViewConfig];
  
        _webView = webview;
    }
    return _webView;
}
@end
