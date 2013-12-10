//
//  AboutViewController.m
//  DARTingAround
//
//  Created by Barry Scott on 18/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    LogIt(@"fetchDataFromServer");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    LogIt(@"fetchDataFromServer");
    [super viewDidLoad];
    //
    self.contentsView.frame = CGRectMake(0.0, 0.0, 320.0, 1400.0);
    [self.containerScrollView addSubview:self.contentsView];
    self.containerScrollView.contentSize = CGSizeMake(320, 1400);
	//
    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@ Build: %@",
                              [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                              [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
                              ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapCloseButt:(id)sender {
    LogIt(@"tapCloseButt");
    [self dismissViewControllerAnimated:YES completion:^{}];
}





#pragma mark - Opening links in other apps

- (IBAction)openLinkForTag:(id)sender {
    LogIt(@"openLinkForTag");
    NSInteger tag = [sender tag];
    UIApplication *app = [UIApplication sharedApplication];
    switch (tag) {
        case 101: // Me on twitter
            [self openLinkInTwitterAppForUsername:@"bazscott"];
            break;
            
        case 102: // Irish rail Real Time site
            [app openURL:[NSURL URLWithString:@"http://api.irishrail.ie/realtime/"]];
            break;
            
        case 111: // Adam
            [self openLinkInTwitterAppForUsername:@"adamkmccarthy"];
            break;
            
        case 112: // Baz
            [self openLinkInTwitterAppForUsername:@"bazmcbrien"];
            break;
            
        case 113: // Brian
            [self openLinkInTwitterAppForUsername:@"bkenny"];
            break;
            
        case 114: // Karl
            [self openLinkInTwitterAppForUsername:@"karlmonaghan"];
            break;
            
        case 115: // Neil C
            [self openLinkInTwitterAppForUsername:@"ncremins"];
            break;
        
        case 116: // Neil T
            [self openLinkInTwitterAppForUsername:@"theothernt"];
            break;
        
        case 117: // Oisin H
            [self openLinkInTwitterAppForUsername:@"oisin"];
            break;
        
        case 118: // Damo
            [self openLinkInTwitterAppForUsername:@"DamianOS3"];
            break;
            
        case 119: // Oisin P
            [self openLinkInTwitterAppForUsername:@"prendio2"];
            break;
            
        case 121: // Nikil Viswanathan
            [app openURL:[NSURL URLWithString:@"http://www.nikilster.com"]];
            break;
            
        case 122: // AFNetworking
            [app openURL:[NSURL URLWithString:@"https://github.com/AFNetworking/AFNetworking"]];
            break;
            
        case 123: // TBXML
            [app openURL:[NSURL URLWithString:@"https://github.com/71squared/TBXML"]];
            break;
            
        case 124: // TSMessages
            [app openURL:[NSURL URLWithString:@"https://github.com/toursprung/TSMessages"]];
            break;
            
        case 999:
            // My Website
            [app openURL:[NSURL URLWithString:@"http://bazscott.com"]];
            break;
            
        default:
            break;
    }
}

- (void)openLinkInTwitterAppForUsername:(NSString *)username {
    LogIt(@"openLinkInTwitterApp");
    UIApplication *app = [UIApplication sharedApplication];
    
    // Twitterrific
    NSURL *twitterrificURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitterrific:///profile?screen_name=%@", username]];
    if ([app canOpenURL:twitterrificURL]) {
        [app openURL:twitterrificURL];
        return;
    }
    
    // Tweetbot
    NSURL *tweetbotURL = [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot:///user_profile/%@", username]];
    if ([app canOpenURL:tweetbotURL]) {
        [app openURL:tweetbotURL];
        return;
    }
    
    // Twitter Default
    NSURL *twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", username]];
    if ([app canOpenURL:twitterURL]) {
        [app openURL:twitterURL];
        return;
    }
    
    // Fallback: Mobile Twitter in Safari
    NSURL *safariURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://mobile.twitter.com/%@", username]];
    [app openURL:safariURL];
    return;
}

- (void)openLinkInFacebookAppForUsername:(NSString *)username {
    LogIt(@"openLinkInFacebookAppForUsername");
    UIApplication *app = [UIApplication sharedApplication];
    
    // Facebook app
    NSURL *facebookURL = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", username]];
    if ([app canOpenURL:facebookURL]) {
        [app openURL:facebookURL];
        return;
    }
    
    // Fallback: Mobile Facebook in Safari
    NSURL *safariURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://touch.facebook.com/%@", username]];
    [app openURL:safariURL];
    return;
}

@end
