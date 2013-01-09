//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Joanne Dyer on 11/14/12.
//  Copyright (c) 2012 Joanne Dyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *displayHistory;
@property (weak, nonatomic) IBOutlet UILabel *displayVariables;

@end
