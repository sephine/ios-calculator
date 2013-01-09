//
//  GraphingViewController.m
//  Calculator
//
//  Created by Joanne Dyer on 12/30/12.
//  Copyright (c) 2012 Joanne Dyer. All rights reserved.
//

#import "GraphingViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"

@interface GraphingViewController () <GraphViewDataSource>

@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) UIBarButtonItem *splitViewBarButtonItem;

@end

@implementation GraphingViewController

@synthesize graphView = _graphView;
@synthesize toolbar = _toolbar;
@synthesize program = _program;
@synthesize equationLabel = _equationLabel;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

- (void)setProgram:(id)program
{
    _program = program;
    [self.graphView setNeedsDisplay];
}

- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    UITapGestureRecognizer *tripleTapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tripleTap:)];
    tripleTapGestureRecogniser.numberOfTapsRequired = 3;
    [self.graphView addGestureRecognizer:tripleTapGestureRecogniser];
    self.graphView.dataSource = self;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    id masterController = [self.splitViewController.viewControllers objectAtIndex:0];
    if ([masterController isKindOfClass:[UIViewController class]]) {
        barButtonItem.title = ((UIViewController *)masterController).title;
    }
    self.splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.splitViewBarButtonItem = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (double)yValueForGraphView:(GraphView *)sender forXValue:(double)xValue
{
    NSDictionary *variableValues = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:xValue] forKey:@"x"];
    return [CalculatorBrain runProgram:self.program usingVariableValues:variableValues];
}

@end
