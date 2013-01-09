//
//  GraphView.h
//  Calculator
//
//  Created by Joanne Dyer on 12/30/12.
//  Copyright (c) 2012 Joanne Dyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource

- (double)yValueForGraphView:(GraphView *)sender forXValue:(double)xValue;

@end

@interface GraphView : UIView

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;

@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)pan:(UIPanGestureRecognizer *)gesture;
- (void)tripleTap:(UITapGestureRecognizer *)gesture;

@end
