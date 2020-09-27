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

#import "WebViewScreenSaverView.h"
#import <Carbon/Carbon.h>

static NSString * const kScreenSaverName = @"OpeningsMoeScreenSaver";
static NSTimeInterval const kOneMinute = 60.0;

@interface WebViewScreenSaverView () <
WebEditingDelegate,
WebFrameLoadDelegate,
WebPolicyDelegate,
WebUIDelegate>
@end

@implementation WebViewScreenSaverView {
    NSTimer *_timer;
    WebView *_webView;
    NSInteger _currentIndex;
    BOOL _isPreview;
}

+ (BOOL)performGammaFade {
    return YES;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    NSUserDefaults *prefs = [ScreenSaverDefaults defaultsForModuleWithName:kScreenSaverName];
    return [self initWithFrame:frame isPreview:isPreview prefsStore:prefs];
}


- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview prefsStore:(NSUserDefaults *)prefs {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [self setAutoresizesSubviews:YES];
        
        _currentIndex = 0;
        _isPreview = isPreview;
    }
    return self;
}

- (void)dealloc {
    [_webView setFrameLoadDelegate:nil];
    [_webView setPolicyDelegate:nil];
    [_webView setUIDelegate:nil];
    [_webView setEditingDelegate:nil];
    [_webView close];
    [_timer invalidate];
    _timer = nil;
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
    
    _webView = [[WebView alloc] initWithFrame:[self bounds]];
    [_webView setFrameLoadDelegate:self];
    [_webView setShouldUpdateWhileOffscreen:YES];
    [_webView setPolicyDelegate:self];
    [_webView setUIDelegate:self];
    [_webView setEditingDelegate:self];
    [_webView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_webView setAutoresizesSubviews:YES];
    [_webView setDrawsBackground:NO];
    
    [self addSubview:_webView];
    
    NSColor *color = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
    [[_webView layer] setBackgroundColor:color.CGColor];
    
    if (!_isPreview) {
        [self loadFromStart];
    }
}

- (void)stopAnimation {
    [super stopAnimation];
    [_timer invalidate];
    _timer = nil;
    [_webView removeFromSuperview];
    [_webView close];
    _webView = nil;
}

#pragma mark Loading URLs

- (void)loadFromStart {
    NSString *url = @"https://openings.moe";
    
    [_webView setMainFrameURL:url];
    [_webView stringByEvaluatingJavaScriptFromString:@"localStorage['autonext'] = true;"];
    [_webView stringByEvaluatingJavaScriptFromString:@"localStorage['videoType'] = 'op';"];
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

#define SET_COMMAND(key, value) case key: command = value; break;

- (void)keyDown:(NSEvent *)theEvent {
    NSString *command = NULL;

    switch (theEvent.keyCode) {
        SET_COMMAND(kVK_ANSI_A, @"toggleAutonext()");
        SET_COMMAND(kVK_ANSI_N, @"getNewVideo()");
        SET_COMMAND(kVK_Space, @"playPause()");
        SET_COMMAND(kVK_ANSI_S, @"subtitles.toggle()");
        SET_COMMAND(kVK_ANSI_T, @"showVideoTitle()");
        SET_COMMAND(kVK_LeftArrow, @"skip(-10)");
        SET_COMMAND(kVK_RightArrow, @"skip(10)");
    }
    
    if (command) {
        [_webView stringByEvaluatingJavaScriptFromString:command];
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
