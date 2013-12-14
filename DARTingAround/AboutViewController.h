//
//  AboutViewController.h
//  DARTingAround
//
//  Created by Barry Scott on 18/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (strong, nonatomic) IBOutlet UIView *contentsView;

@property (strong, nonatomic) IBOutlet UILabel *versionLabel;

- (IBAction)openLinkForTag:(id)sender;
- (IBAction)tapCloseButt:(id)sender;
- (IBAction)tapShareButton:(id)sender;

@end
