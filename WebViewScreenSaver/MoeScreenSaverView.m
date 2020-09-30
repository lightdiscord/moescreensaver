//
//  WebViewScreenSaverView.m
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 8/8/10.
//
//  Copyright 2015 Alastair Tse.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MoeScreenSaverView.h"
#import <Carbon/Carbon.h>

@interface MoeScreenSaverView () <
WebEditingDelegate,
WebFrameLoadDelegate,
WebPolicyDelegate,
WebUIDelegate>
@end

@implementation MoeScreenSaverView {
    WebView *webview;
    BOOL _isPreview;
}

+ (BOOL)performGammaFade {
    return YES;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [self setAutoresizesSubviews:YES];
        
        _isPreview = isPreview;
    }
    return self;
}

- (void)dealloc {
    [webview setFrameLoadDelegate:nil];
    [webview setPolicyDelegate:nil];
    [webview setUIDelegate:nil];
    [webview setEditingDelegate:nil];
    [webview close];
}

#pragma mark - Configure Sheet

- (BOOL)hasConfigureSheet {
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

- (void)setFrame:(NSRect)frameRect {
  [super setFrame:frameRect];
}


#pragma mark ScreenSaverView

- (void)startAnimation {
    [super startAnimation];
    
    webview = [[WebView alloc] initWithFrame:[self bounds]];
    [webview setFrameLoadDelegate:self];
    [webview setShouldUpdateWhileOffscreen:YES];
    [webview setPolicyDelegate:self];
    [webview setUIDelegate:self];
    [webview setEditingDelegate:self];
    [webview setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [webview setAutoresizesSubviews:YES];
    [webview setDrawsBackground:NO];
    
    [self addSubview:webview];
    
    NSColor *color = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
    [[webview layer] setBackgroundColor:color.CGColor];
    
    if (!_isPreview) {
        [self loadFromStart];
    }
}

- (void)stopAnimation {
    [super stopAnimation];
    [webview removeFromSuperview];
    [webview close];
    webview = nil;
}

#pragma mark Loading URLs

- (void)loadFromStart {
    NSString *url = @"https://openings.moe";
    
    [webview setMainFrameURL:url];
}

- (void)animateOneFrame {
    [super animateOneFrame];
}

#pragma mark Focus Overrides

// A bunch of methods that captures all the input events to prevent
// the webview from getting any keyboard focus.

- (NSView *)hitTest:(NSPoint)aPoint {
    return self;
}

- (void)keyDown:(NSEvent *)theEvent {
    NSString *command = NULL;

    switch (theEvent.keyCode) {
        CASE_COMMAND(kVK_ANSI_A, @"toggleAutonext()");
        CASE_COMMAND(kVK_ANSI_N, @"getNewVideo()");
        //CASE_COMMAND(kVK_Space, @"playPause()");
        CASE_COMMAND(kVK_ANSI_S, @"subtitles.toggle()");
        CASE_COMMAND(kVK_ANSI_T, @"showVideoTitle()");
        CASE_COMMAND(kVK_LeftArrow, @"skip(-10)");
        CASE_COMMAND(kVK_RightArrow, @"skip(10)");
        CASE_COMMAND(kVK_ANSI_M, @"toggleMenu()");
    }
    
    if (command) {
        [webview stringByEvaluatingJavaScriptFromString:command];
    }
}

- (void)keyUp:(NSEvent *)theEvent {
    return;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)resignFirstResponder {
    return NO;
}

#pragma mark WebPolicyDelegate

- (void)webView:(WebView *)webView
decidePolicyForNewWindowAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request
   newFrameName:(NSString *)frameName
decisionListener:(id < WebPolicyDecisionListener >)listener {
    // Don't open new windows.
    [listener ignore];
}

- (void)webView:(WebView *)webView didFinishLoadForFrame:(WebFrame *)frame {
    [webView resignFirstResponder];
    [[[webView mainFrame] frameView] setAllowsScrolling:NO];
    //[webView setDrawsBackground:YES];
    [webview stringByEvaluatingJavaScriptFromString:@"changeVideoType('op')"];
    [webview stringByEvaluatingJavaScriptFromString:@"localStorage['autonext'] = true"];
}

- (void)webView:(WebView *)webView unableToImplementPolicyWithError:(NSError *)error frame:(WebFrame *)frame {
    NSLog(@"unableToImplement: %@", error);
}

#pragma mark WebUIDelegate

- (NSResponder *)webViewFirstResponder:(WebView *)sender {
    return self;
}

- (void)webViewClose:(WebView *)sender {
    return;
}

- (BOOL)webViewIsResizable:(WebView *)sender {
    return NO;
}

- (BOOL)webViewIsStatusBarVisible:(WebView *)sender {
    return NO;
}

- (void)webViewRunModal:(WebView *)sender {
    return;
}

- (void)webViewShow:(WebView *)sender {
    return;
}

- (void)webViewUnfocus:(WebView *)sender {
    return;
}

@end
