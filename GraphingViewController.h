//
//  GraphingViewController.h
//  Calculator
//
//  Created by Joanne Dyer on 12/30/12.
//  Copyright (c) 2012 Joanne Dyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphingViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) id program;
@property (weak, nonatomic) IBOutlet UILabel *equationLabel;

@end
