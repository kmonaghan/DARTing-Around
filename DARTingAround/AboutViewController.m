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

@end
