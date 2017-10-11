/*
 SFSDKUserSelectionNavViewController.m
 SalesforceSDKCore
 
 Created by Raj Rao on 8/28/17.
 
 Copyright (c) 2017-present, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SFSDKUserSelectionNavViewController.h"
#import "SFSDKUserSelectionTableViewController.h"
#import "SFSDKIDPAuthClient.h"

@interface SFSDKUserSelectionNavViewController ()<SFSDKUserSelectionTableViewControllerDelegate> {
    SFSDKUserSelectionTableViewController *_selectionView;
}

@end

@implementation SFSDKUserSelectionNavViewController
@synthesize userSelectionDelegate = _userSelectionDelegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _selectionView= [[SFSDKUserSelectionTableViewController alloc] initWithNibName:nil bundle:nil];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _selectionView.listViewDelegate = self;
    [self pushViewController:_selectionView animated:NO];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (NSDictionary *)spAppOptions {
    return _selectionView.options;
}

- (void)setAppName:(NSDictionary *)spAppOptions {
    _selectionView.options = spAppOptions;
}


#pragma mark - SFSDKUserSelectionTableViewControllerDelegate
- (void)createNewuser:(NSDictionary *) options{
    [self.userSelectionDelegate createNewUser:options];
}

- (void)selectedUser:(SFUserAccount *)user options:(NSDictionary *)options{
    [self.userSelectionDelegate selectedUser:user spAppContext:options];
}

- (void)cancel:(NSDictionary *)options{
    [self.userSelectionDelegate cancel:options];
}

@end