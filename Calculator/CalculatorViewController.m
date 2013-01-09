//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Joanne Dyer on 11/14/12.
//  Copyright (c) 2012 Joanne Dyer. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphingViewController.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL alreadyEntered;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;

- (void)updateDisplayVariables;
- (NSString *)getVariableString;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize displayHistory = _displayHistory;
@synthesize displayVariables = _displayVariables;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize alreadyEntered = _alreadyEntered;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *) brain
{
    if(!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowGraph"]) {
        [segue.destinationViewController equationLabel].text = [@"y = " stringByAppendingString:self.brain.description];
        [segue.destinationViewController setProgram:self.brain.program];
    }
}

- (IBAction)digitPressed:(UIButton *)sender
{
    self.alreadyEntered = NO;
    NSString *digit = [sender currentTitle];
    NSRange range = [self.display.text rangeOfString:@"."];
    
    if (self.userIsInTheMiddleOfEnteringANumber)
    {
        if(![digit isEqualToString:@"."] ||
            range.location == NSNotFound)
        {
            self.display.text = [self.display.text stringByAppendingString:digit];
        }
    }
    else
    {
        if ([digit isEqualToString:@"."]) {
            self.display.text = [@"0" stringByAppendingString:digit];
        }
        else {
            self.display.text = digit;
        }
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)operationPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    self.alreadyEntered = YES;
    double result = [self.brain performOperation:sender.currentTitle usingVariableValues:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    self.displayHistory.text = [self.brain description];
}

- (IBAction)enterPressed
{
    if (!self.alreadyEntered) {
        [self.brain pushOperand:[NSNumber numberWithDouble:[self.display.text doubleValue]]];
        self.userIsInTheMiddleOfEnteringANumber = NO;
        self.displayHistory.text = [self.brain description];
        self.alreadyEntered = YES;
    }
}

- (IBAction)clearPressed
{
    [self.brain clearHistory];
    self.display.text = @"0";
    self.displayHistory.text = [self.brain description];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self updateDisplayVariables];
}

- (IBAction)variablePressed:(UIButton *)sender {
    NSString *variable = [sender currentTitle];
    self.display.text = variable;
    self.alreadyEntered = YES;
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self.brain pushOperand:variable];
    self.displayHistory.text = [self.brain description];
    [self updateDisplayVariables];
}

- (IBAction)testButtonPressed:(id)sender {
    NSString *test = [sender currentTitle];
    if ([test isEqualToString:@"Test 1"]) {
        self.testVariableValues = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:1], @"x", [NSNumber numberWithDouble:-2], @"y", [NSNumber numberWithDouble:3], @"z", nil];
    } else if ([test isEqualToString:@"Test 2"]) {
        self.testVariableValues = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:0.5], @"x", [NSNumber numberWithDouble:55.9], @"y", [NSNumber numberWithDouble:-66.95], @"z", nil];
    } else if ([test isEqualToString:@"Test 3"]) {
        self.testVariableValues = nil;
    }
    [self updateDisplayVariables];
}

- (IBAction)undoPressed {
    if (self.userIsInTheMiddleOfEnteringANumber)
    {
        if (self.display.text.length == 0)
        {
            self.display.text = [[NSNumber numberWithDouble:[CalculatorBrain runProgram:self.brain usingVariableValues:self.testVariableValues]] description];
            self.userIsInTheMiddleOfEnteringANumber = NO;
        } else if (self.display.text.length == 1)
        {
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringANumber = NO;
        } else
        {
            int newLength = self.display.text.length - 1;
            self.display.text = [self.display.text substringToIndex:newLength];
        }
    }
    else
    {
        [self.brain undo];
    }
    self.displayHistory.text = [self.brain description];
    [self updateDisplayVariables];
}

- (IBAction)graphPressed {
    if (self.splitViewController)
    {
        [self splitViewGraphingViewController].program = self.brain.program;
        [self splitViewGraphingViewController].equationLabel.text = [@"y = " stringByAppendingString:self.brain.description];
    } else {
        [self performSegueWithIdentifier:@"ShowGraph" sender:self];
    }
}

- (GraphingViewController *)splitViewGraphingViewController
{
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[GraphingViewController class]]) {
        gvc = nil;
    }
    return gvc;
}

- (void)updateDisplayVariables
{    
    NSString *variableString = [self getVariableString];
    self.displayVariables.text = variableString;
}
         
- (NSString *)getVariableString
{
    NSString *variableString = @"";
    BOOL firstVariable = YES;
    for (id possibleVariable in [self.brain variablesUsed])
    {
        if (!firstVariable)
        {
            variableString = [variableString stringByAppendingString:@", "];
        }
        variableString = [variableString stringByAppendingString:possibleVariable];
        variableString = [variableString stringByAppendingString:@" = "];
        
        NSNumber *variableValue = [self.testVariableValues valueForKey:possibleVariable];
        
        if (variableValue)
        {
            variableString = [variableString stringByAppendingString:[variableValue description]];
        }
        else
        {
            variableString = [variableString stringByAppendingString:@"0"];
        }
        
        firstVariable = NO;
    }
    
    return variableString;
}

@end
