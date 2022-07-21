//
//  KKWebBrowserViewController.m
//  YouJia
//
//  Created by liubo on 2018/6/26.
//  Copyright © 2018年 gouuse. All rights reserved.
//

#import "WebBrowserViewController.h"
#import <WebKit/WebKit.h>
#import "KKVideoPlayViewController.h"
#import "KKThemeManager.h"
#import "KKActionSheet.h"
#import "KKLocalizationManager.h"
#import "KKLibraryLocalizationDefineKeys.h"
#import "KKToastView.h"

NSNotificationName const NotificationName_TSWebBrowserViewControllerClose  = @"NotificationName_TSWebBrowserViewControllerClose";

@interface WebBrowserViewController ()
<
WKUIDelegate,
WKNavigationDelegate,
KKActionSheetDelegate
>

@property (nonatomic , strong) WKWebView *mywebview;
@property (nonatomic , strong) UIProgressView *progressview;
@property (nonatomic , assign) BOOL isRoot;
@property (nonatomic , copy) NSString *navTitle;
@property (nonatomic , assign) BOOL needShowNavRightButton;
@property (nonatomic , copy) NSString *inURL;

- (instancetype)initWithURL:(NSURL*)aURL
         navigationBarTitle:(NSString*)aTitle
     needShowNavRightButton:(BOOL)aNeedShowNavRightButton
                     isRoot:(BOOL)aIsRoot;

@end

@implementation WebBrowserViewController

// KVO一定要移除观察者
- (void)dealloc{
    if (self.mywebview) {
        [self.mywebview removeObserver:self forKeyPath:@"estimatedProgress"];
        [self.mywebview removeObserver:self forKeyPath:@"title"];
    }
}

#pragma mark ==================================================
#pragma mark == 初始化
#pragma mark ==================================================
- (instancetype)initWithURL:(NSURL*)aURL{
    return [self initWithURL:aURL navigationBarTitle:nil needShowNavRightButton:YES isRoot:YES];
}

- (instancetype)initWithURL:(NSURL*)aURL
         navigationBarTitle:(NSString*)aTitle{
    return [self initWithURL:aURL navigationBarTitle:aTitle needShowNavRightButton:YES isRoot:YES];
}

- (instancetype)initWithURL:(NSURL*)aURL
         navigationBarTitle:(NSString*)aTitle
     needShowNavRightButton:(BOOL)aNeedShowNavRightButton{
    return [self initWithURL:aURL navigationBarTitle:aTitle needShowNavRightButton:aNeedShowNavRightButton isRoot:YES];
}

- (instancetype)initWithURL:(NSURL*)aURL
         navigationBarTitle:(NSString*)aTitle
     needShowNavRightButton:(BOOL)aNeedShowNavRightButton
                     isRoot:(BOOL)aIsRoot{
    self = [super init];
    if (self) {
        self.inURL = aURL.absoluteString;
        self.myURL = [self aResultURL:aURL.absoluteString];
        self.isRoot = aIsRoot;
        self.navTitle = aTitle;
        self.needShowNavRightButton = aNeedShowNavRightButton;
    }
    return self;
}

- (NSURL*)aResultURL:(NSString*)aUrlString{
    NSURL *resultURL = [NSURL URLWithString:aUrlString];
    if (resultURL && [[UIApplication sharedApplication] canOpenURL:resultURL]) {
        return resultURL;
    }
    
    //拼接www
    NSString *url = @"";
    if ([aUrlString.lowercaseString hasPrefix:@"www."]==NO) {
        url = [NSString stringWithFormat:@"www.%@",aUrlString];
    }
    resultURL = [NSURL URLWithString:url];
    if (resultURL && [[UIApplication sharedApplication] canOpenURL:resultURL]) {
        return resultURL;
    }
    
    //拼接http://
    if ([aUrlString.lowercaseString hasPrefix:@"http"]==NO) {
        url = [NSString stringWithFormat:@"http://%@",aUrlString];
    }
    resultURL = [NSURL URLWithString:url];
    if (resultURL && [[UIApplication sharedApplication] canOpenURL:resultURL]) {
        return resultURL;
    }
    
    //拼接https://
    if ([aUrlString.lowercaseString hasPrefix:@"https"]==NO) {
        url = [NSString stringWithFormat:@"https://%@",aUrlString];
    }
    resultURL = [NSURL URLWithString:url];
    if (resultURL && [[UIApplication sharedApplication] canOpenURL:resultURL]) {
        return resultURL;
    }
    
    //拼接http://www.
    if ([aUrlString.lowercaseString hasPrefix:@"http"]==NO) {
        url = [NSString stringWithFormat:@"http://www.%@",aUrlString];
    }
    resultURL = [NSURL URLWithString:url];
    if (resultURL && [[UIApplication sharedApplication] canOpenURL:resultURL]) {
        return resultURL;
    }
    
    //拼接https://www.
    if ([aUrlString.lowercaseString hasPrefix:@"https"]==NO) {
        url = [NSString stringWithFormat:@"https://www.%@",aUrlString];
    }
    resultURL = [NSURL URLWithString:url];
    if (resultURL && [[UIApplication sharedApplication] canOpenURL:resultURL]) {
        return resultURL;
    }
    
    //拼接ftp://
    if ([aUrlString.lowercaseString hasPrefix:@"ftp"]==NO) {
        url = [NSString stringWithFormat:@"ftp://%@",aUrlString];
    }
    resultURL = [NSURL URLWithString:url];
    if (resultURL && [[UIApplication sharedApplication] canOpenURL:resultURL]) {
        return resultURL;
    }
    
    return nil;
}

// 判断url是否可以打开__
- (void) isConnectionAvailable{
    KKWeakSelf(self)
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.myURL];
    [request setHTTPMethod:@"HEAD"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"error<<为空的话说明可以访问里面的内容>> %@",error);
        if (error) {
            //回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself loadErrorView];
            });
        }
        else {
            //回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself loadWebViewAndRequest];
            });
        }
    }];
    
    [task resume];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self setNavLeftButtons];
    [self setNavRightButton];
    
    if ([NSString kk_isStringNotEmpty:self.navTitle]) {
        self.title = self.navTitle;
    }
    
    if (self.isRoot) {
        [self kk_observeNotification:NotificationName_TSWebBrowserViewControllerClose selector:@selector(Notification_TSWebBrowserViewControllerClose:)];
    }
    [self isConnectionAvailable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)loadErrorView{
    [self.view kk_removeAllSubviews];
    
    NSString *title = KKLocalization(@"KKLibLocalizable.Common.CannotOpenURL");
    
    NSString *message = [NSString stringWithFormat:@"%@:  %@",title,self.inURL];
    CGFloat height = KKApplicationHeight-44;
    
    UILabel *label = [UILabel kk_initWithTextColor:[UIColor lightGrayColor] font:[UIFont systemFontOfSize:14] text:message lines:0 maxWidth:KKScreenWidth-30];
    label.frame = CGRectMake(15, (height-label.kk_height)/2.0, KKScreenWidth-30, label.kk_height);
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview: label];
    
    if ([NSString kk_isStringEmpty:self.navTitle]) {
        self.title = title;
    }
}

- (void)loadWebViewAndRequest{
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    wkWebConfig.userContentController = wkUController;
    
    NSMutableString *javascript = [NSMutableString string];
    //自适应屏幕的宽度js
    [javascript appendString:@"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"];

    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    
    //添加js调用
    [wkUController addUserScript:wkUserScript];

    // 1.创建webview，并设置大小，"20"为状态栏高度
    self.mywebview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, KKApplicationWidth, KKScreenHeight-KKStatusBarAndNavBarHeight) configuration:wkWebConfig];
    // 2.创建请求
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:self.myURL];
    // 3.加载网页
    [self.mywebview loadRequest:request];
    // 最后将webView添加到界面
    [self.view addSubview:self.mywebview];
    self.mywebview.UIDelegate = self;
    self.mywebview.navigationDelegate = self;
    self.mywebview.allowsLinkPreview = NO;
    self.mywebview.allowsBackForwardNavigationGestures = NO;
    self.mywebview.configuration.allowsInlineMediaPlayback = YES;
    self.mywebview.multipleTouchEnabled = YES;
    self.mywebview.backgroundColor = [UIColor clearColor];
    self.mywebview.opaque = YES;
    self.mywebview.scrollView.zoomScale = 6.0;

    self.progressview = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, KKApplicationWidth, 2.0)];
    self.progressview.progressTintColor = [UIColor kk_colorWithHexString:@"3B6AE7"];
    self.progressview.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:self.progressview];
    
    //KVO: 让self对象监听webView的estimatedProgress
    [self.mywebview addObserver:self
                     forKeyPath:@"estimatedProgress"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
    [self.mywebview addObserver:self
                     forKeyPath:@"title"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
}

#pragma mark ==================================================
#pragma mark == 导航栏
#pragma mark ==================================================
- (void)setNavLeftButtons{
    if (self.isRoot) {
        //左导航
        NSString *backTitle = KKLibLocalizable_Common_Back;
        CGSize size = [backTitle kk_sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:KKApplicationWidth];
        KKButton *button = [[KKButton alloc] initWithFrame:CGRectMake(0, 0, MAX(size.width+10, 44), 44) type:KKButtonType_ImgLeftTitleRight_Left];
        UIImage *image = KKThemeImage(@"btn_NavBack");
        button.imageViewSize = image.size;
        button.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        button.spaceBetweenImgTitle = 0;
        button.textLabel.font = [UIFont systemFontOfSize:14];
        [button addTarget:self action:@selector(navigationPopBackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        button.exclusiveTouch = YES;//关闭多点
        button.backgroundColor = [UIColor clearColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        [button setTitle:backTitle forState:UIControlStateNormal];
        //        [button setTitle:backTitle forState:UIControlStateHighlighted];
        [button setImage:image forState:UIControlStateNormal];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        if ([UIDevice kk_isSystemVersionBigerThan:@"11.0"]) {
            //        negativeSeperator.width = -25;
        }
        else{
            negativeSeperator.width = 0;
        }
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSeperator,leftItem, nil];
    }
    else{
        //左导航
        NSString *backTitle = KKLibLocalizable_Common_Back;
        CGSize size = [backTitle kk_sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:KKApplicationWidth];
        KKButton *button = [[KKButton alloc] initWithFrame:CGRectMake(0, 0, MAX(size.width+10, 44), 44) type:KKButtonType_ImgLeftTitleRight_Left];
        UIImage *image = KKThemeImage(@"btn_NavBack");
        button.imageViewSize = image.size;
        button.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        button.spaceBetweenImgTitle = 0;
        button.textLabel.font = [UIFont systemFontOfSize:14];
        [button addTarget:self action:@selector(navigationPopBackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        button.exclusiveTouch = YES;//关闭多点
        button.backgroundColor = [UIColor clearColor];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //        [button setTitle:backTitle forState:UIControlStateNormal];
        //        [button setTitle:backTitle forState:UIControlStateHighlighted];
        [button setImage:image forState:UIControlStateNormal];
        UIBarButtonItem *leftItem01 = [[UIBarButtonItem alloc] initWithCustomView:button];
//        [button setBorderColor:[UIColor redColor] width:2.0];

        NSString *closeTitle = KKLibLocalizable_Common_Close;
        CGSize size1 = [closeTitle kk_sizeWithFont:[UIFont systemFontOfSize:14] maxWidth:KKApplicationWidth];
        KKButton *buttonClose = [[KKButton alloc] initWithFrame:CGRectMake(0, 0, MAX(size1.width+10, 44), 44) type:KKButtonType_ImgLeftTitleRight_Left];
        buttonClose.imageViewSize = CGSizeZero;
        buttonClose.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        buttonClose.spaceBetweenImgTitle = 0;
        buttonClose.textLabel.font = [UIFont systemFontOfSize:14];
        [buttonClose addTarget:self action:@selector(navigationCloseButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        buttonClose.exclusiveTouch = YES;//关闭多点
        buttonClose.backgroundColor = [UIColor clearColor];
        [buttonClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [buttonClose setTitle:closeTitle forState:UIControlStateNormal];
        [buttonClose setTitle:closeTitle forState:UIControlStateHighlighted];
        UIBarButtonItem *leftItem02 = [[UIBarButtonItem alloc] initWithCustomView:buttonClose];
//        [buttonClose setBorderColor:[UIColor redColor] width:2.0];
        
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        if ([UIDevice kk_isSystemVersionBigerThan:@"11.0"]) {
            negativeSeperator.width = -25;
        }
        else{
            negativeSeperator.width = 0;
        }
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSeperator,leftItem01,leftItem02, nil];
    }
}

- (void)setNavRightButton{
    [self setNavRightButtonTitle:@"下载管理" selector:@selector(navigationMoreBtnClicked)];
}

- (void)navigationPopBackButtonClicked{
    if ([self.navigationController.viewControllers firstObject]==self) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)navigationCloseButtonClicked{
    
    if (self.isRoot) {
        if ([self.navigationController.viewControllers firstObject]==self) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else{
        [self kk_postNotification:NotificationName_TSWebBrowserViewControllerClose];
    }
}

- (void)Notification_TSWebBrowserViewControllerClose:(NSNotification*)notice{
    
    NSInteger index = NSNotFound;
    NSArray *viewControllers = self.navigationController.viewControllers;
    for (NSInteger i=0; i<[viewControllers count]; i++) {
        UIViewController *viewController = [viewControllers objectAtIndex:i];
        if (viewController==self) {
            index = i;
            break;
        }
    }
    
    if (index!=NSNotFound) {
        if (index==0) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        else{
            UIViewController *viewController = [viewControllers objectAtIndex:index-1];
            [self.navigationController popToViewController:viewController animated:YES];
        }
    }
}

- (void)navigationMoreBtnClicked{
    [self.navigationController kk_pushViewController:@"FileDownloadListViewController" withParms:nil];
}

#pragma mark ==================================================
#pragma mark == KKActionSheetDelegate
#pragma mark ==================================================
- (void)KKActionSheet_backgroundClicked:(KKActionSheet*)aActionSheet{
    
}

- (void)KKActionSheet:(KKActionSheet*)aActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //取消
    if (buttonIndex==0) {
        return;
    }
    // 拷贝链接
    else if (buttonIndex==1){
        NSString *requestURL = aActionSheet.kk_tagInfo;

        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:requestURL];
        [KKToastView showInView:[UIWindow kk_currentKeyWindow]
                           text:KKLibLocalizable_Common_Success
                          image:nil
                      alignment:KKToastViewAlignment_Center];
    }
    // 播放
    else if (buttonIndex==2){
        NSString *requestURL = aActionSheet.kk_tagInfo;

        NSString *pathExtension = [[[requestURL lowercaseString] pathExtension] lowercaseString];
        if ([NSFileManager kk_isFileType_VIDEO:pathExtension] ||
            [NSFileManager kk_isFileType_AUDIO:pathExtension] ) {
            KKVideoPlayViewController *viewController = [[KKVideoPlayViewController alloc] initWitFilePath:requestURL fileName:requestURL.lastPathComponent?requestURL.lastPathComponent:@"播放文件"];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        else{
            WebBrowserViewController *viewController = [[WebBrowserViewController alloc] initWithURL:[NSURL URLWithString:requestURL] navigationBarTitle:nil needShowNavRightButton:self.needShowNavRightButton isRoot:NO];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
    // 下载
    else if (buttonIndex==3){
        NSString *requestURL = aActionSheet.kk_tagInfo;
        if ([NSString kk_isStringEmpty:requestURL]) {
            return;
        }
        [[FileDownloadManager defaultManager] downloadFileWithURL:[requestURL kk_KKURLDecodedString]];
    }
    // 在内部网页打开
    else if (buttonIndex==4){
        NSString *requestURL = aActionSheet.kk_tagInfo;
        if ([NSString kk_isStringEmpty:requestURL]) {
            return;
        }
        WebBrowserViewController *viewController = [[WebBrowserViewController alloc] initWithURL:[NSURL URLWithString:requestURL] navigationBarTitle:nil needShowNavRightButton:self.needShowNavRightButton isRoot:NO];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else{
        
    }
}

#pragma mark ==================================================
#pragma mark == KVO
#pragma mark ==================================================
// 只要监听的属性有新值就会调用
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id>
                                                                               *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressview.progress= self.mywebview.estimatedProgress;
        if (self.progressview.progress>=1) {
            self.progressview.hidden = YES;
        }
        else{
            self.progressview.hidden = NO;
        }
    }
    if ([keyPath isEqualToString:@"title"]) {
        if ([NSString kk_isStringEmpty:self.navTitle]) {
            self.title = [self.mywebview.title lowercaseString];
        }
    }
}

#pragma mark ==================================================
#pragma mark == 追踪加载过程函数:
#pragma mark ==================================================
/// 接收到服务器跳转请求之后调用 (服务器端redirect)，不一定调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"didReceiveServerRedirectForProvisionalNavigation");
    
}

/// 1 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{

    if ([[[navigationAction.request.URL absoluteString] lowercaseString] isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    }

    NSString *requestURL = [[navigationAction.request URL] absoluteString];
    NSLog(@"decidePolicyForNavigationAction:%@",requestURL);
    
    if ([requestURL isEqualToString:[self.myURL absoluteString]]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    else{
        if ([[requestURL lowercaseString] hasPrefix:@"https://see"]) {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
        else{
            if ([[requestURL lowercaseString] hasPrefix:@"http"]) {
                if (navigationAction.navigationType==WKNavigationTypeLinkActivated){
                    KKActionSheet *sheet = [[KKActionSheet alloc] initWithTitle:@"操作提示" subTitle:requestURL delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拷贝链接",@"播放",@"下载",@"在内部网页打开",nil];
                    sheet.kk_tagInfo = requestURL;
                    [sheet show];
                    decisionHandler(WKNavigationActionPolicyCancel);
                }
                else{
                    decisionHandler(WKNavigationActionPolicyAllow);
                }
            }
            else{
                decisionHandler(WKNavigationActionPolicyAllow);
            }
        }
    }
}


/// 2 页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"didStartProvisionalNavigation");
    
    
}

/// 3 在收到服务器的响应头，根据response相关信息，决定是否跳转。decisionHandler必须调用，来决定是否跳转，参数WKNavigationActionPolicyCancel取消跳转，WKNavigationActionPolicyAllow允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"decidePolicyForNavigationResponse");
    
    decisionHandler(WKNavigationResponsePolicyAllow);
    
}

/// 4 开始获取到网页内容时返回
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"didCommitNavigation");
    
    
}

/// 5 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"didFinishNavigation");
    
    //    NSString *webViewTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    //    if ([NSString isStringNotEmpty:webViewTitle]) {
    //        self.title = webViewTitle;
    //    }
    
}

/// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"didFailProvisionalNavigation");
    
    
}

#pragma mark ==================================================
#pragma mark == WKScriptMessageHandler
#pragma mark ==================================================
/// message: 收到的脚本信息.
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
}


#pragma mark ==================================================
#pragma mark == WKUIDelegate
#pragma mark ==================================================
///// 创建一个新的WebView
//- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
//    return <#expression#>
//}

/// 输入框
//- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
//
//}
//
///// 确认框
//- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
//
//}
//
///// 警告框
//- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
//
//}


@end
