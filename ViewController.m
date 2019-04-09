//
//  ViewController.m
//  MessageHandlerIOLimitTest
//
//  Created by liang on 2019/4/4.
//  Copyright © 2019 liang. All rights reserved.
//

#import "ViewController.h"

@import WebKit;

@interface ViewController () <WKScriptMessageHandler, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ViewController{
    UITextField *_input;
    UIButton *_sendBtn;
}

static NSString *sample1024 = @"The Cranberries The Cranberries The Cranberries The CranberriesThe Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries 1239384283423423423423423424234552534234The CranberriesThe Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The CranberriesThe Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries 1239384283423423423423423424234552534234 The CranberriesThe Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The CranberriesThe Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The Cranberries 1239384283423423423423423424234552534234 The CranberriesThe Cranberries The Cranberries The Cranberries The Cranberries The Cranberries The CranberriesThe Cranberries The Cranberries The Cranberries The Cranberries 471589964142";
- (void)check:(id)sender
{
    NSInteger i = [_input.text intValue];
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:100];
    if (i > 0) {
        _sendBtn.enabled = NO;
        NSInteger count = i / 1024;
        NSInteger left = i % 1024;
        for (NSInteger i = 0; i < count; i++) {
            [data addObject:sample1024];
        }
        [data addObject:[sample1024 substringToIndex:left]];
        
        NSString *toStr = [data componentsJoinedByString:@""];
        NSInteger total = toStr.length;
        long long time = [[NSDate date] timeIntervalSince1970] * 1000;
        
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"window.onReceived('%@',%ld, %lld)", toStr, (long)total, time] completionHandler:^(id _Nullable r, NSError * _Nullable error) {
            self->_sendBtn.enabled = YES;
            NSLog(@"Evaluate result = %@", r);
        }];
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
    l.text = @"Fill number( in bytes) which will be sent to H5";
    [l sizeToFit];
    [self.view addSubview:l];
    l.center = CGPointMake(180, 80);
    
    _input = [UITextField new];
    _input.frame = CGRectMake(5, 100, 200, 34);
    [self.view addSubview:_input];
    _input.placeholder = @"104857600";
    _input.keyboardType = UIKeyboardTypeNumberPad;
    _input.layer.borderColor = [UIColor redColor].CGColor;
    _input.layer.borderWidth = 1.f;
    _input.textColor = [UIColor blueColor];
    
    UIButton *submit = [UIButton new];
    submit.frame = CGRectMake(210, 100, 60, 34);
    [submit setTitle:@"Send to H5" forState:UIControlStateNormal];
    [submit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [submit addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
    _sendBtn = submit;
    [self.view addSubview:submit];
    
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
        NSLog(@"body.length = %d, cost time = %lld", bodyLen, time - [[body objectForKey:@"time"] longLongValue]);
        NSLog(@"Is Equal ? %d", content.length == bodyLen);
    }
}


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (WKWebView *)webView
{
    if (_webView == nil) {
        //
        WKUserContentController *userContentController = [WKUserContentController new];
        [userContentController addScriptMessageHandler:self name:@"f"];
        WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
        
        webViewConfig.allowsInlineMediaPlayback = YES;
        webViewConfig.userContentController = userContentController ;
    
        CGRect size = [[UIScreen mainScreen] bounds];
        WKWebView *webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 200, CGRectGetWidth(size), CGRectGetHeight(size)) configuration:webViewConfig];
        webview.UIDelegate = self;
        _webView = webview;
    }
    return _webView;
}
@end
