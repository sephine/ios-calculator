//
//  GraphView.m
//  Calculator
//
//  Created by Joanne Dyer on 12/30/12.
//  Copyright (c) 2012 Joanne Dyer. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

#define DEFAULT_SCALE 50.0

@synthesize scale = _scale;
@synthesize origin = _origin;

- (void)setScale:(CGFloat)scale
{
    if (scale != _scale)
    {
        _scale = scale;
        [self setNeedsDisplay];
    }
}

- (void)setOrigin:(CGPoint)origin
{
    if (origin.x != _origin.x || origin.y != _origin.y) {
        _origin = origin;
        [self setNeedsDisplay];
    }
}

- (void)setup
{
    self.contentMode = UIViewContentModeRedraw;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //set scale to value in NSUserDefaults.
    if (![defaults valueForKey:@"scale"]) {
        [defaults setFloat:DEFAULT_SCALE forKey:@"scale"];
        [defaults synchronize];
    }
    self.scale = [defaults floatForKey:@"scale"];
    //set origin to value in NSUserDefaults.
    if (![defaults valueForKey:@"origin"]) {
        NSNumber *defaultXValue = [NSNumber numberWithFloat:self.bounds.origin.x + self.bounds.size.width/2];
        NSNumber *defaultYValue = [NSNumber numberWithFloat:self.bounds.origin.y + self.bounds.size.height/2];
        NSDictionary *defaultOriginDictionary = [NSDictionary dictionaryWithObjectsAndKeys:defaultXValue, @"x", defaultYValue, @"y", nil];
        [defaults setObject:defaultOriginDictionary forKey:@"origin"];
        [defaults synchronize];
    }
    NSDictionary *originDictionary = [defaults objectForKey:@"origin"];
    float xValue = [[originDictionary valueForKey:@"x"] floatValue];
    float yValue = [[originDictionary valueForKey:@"y"] floatValue];
    self.origin = CGPointMake(xValue, yValue);
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale;
        gesture.scale = 1;
        
        if (gesture.state == UIGestureRecognizerStateEnded) [self updateUserDefaultsWithScaleAndOrigin];
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        self.origin = CGPointMake(self.origin.x + translation.x, self.origin.y + translation.y);
        [gesture setTranslation:CGPointZero inView:self];
        
        if (gesture.state == UIGestureRecognizerStateEnded) [self updateUserDefaultsWithScaleAndOrigin];
    }
}

- (void)tripleTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        self.origin = [gesture locationInView:self];
        [self updateUserDefaultsWithScaleAndOrigin];
    }
}

- (void)updateUserDefaultsWithScaleAndOrigin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //update stored scale if necessary.
    if (self.scale != [defaults floatForKey:@"scale"])
    {
        [defaults setFloat:self.scale forKey:@"scale"];
        [defaults synchronize];
    }
    //update stored origin if necessary.
    NSDictionary *originDictionary = [defaults objectForKey:@"origin"];
    float xValue = [[originDictionary valueForKey:@"x"] floatValue];
    float yValue = [[originDictionary valueForKey:@"y"] floatValue];
    if (self.origin.x != xValue || self.origin.y != yValue) {
        NSNumber *newXValue = [NSNumber numberWithFloat:self.origin.x];
        NSNumber *newYValue = [NSNumber numberWithFloat:self.origin.y];
        NSDictionary *newOriginDictionary = [NSDictionary dictionaryWithObjectsAndKeys:newXValue, @"x", newYValue, @"y", nil];
        [defaults setObject:newOriginDictionary forKey:@"origin"];
        [defaults synchronize];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //draw axis
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.origin scale:self.scale];
    
    //draw line
    CGContextBeginPath(context);
    
    CGFloat pixelsPerPoint = self.contentScaleFactor;
    CGFloat widthInPixels = self.bounds.size.width*pixelsPerPoint;
    BOOL started = NO;
    for (int pixel = 0; pixel <= widthInPixels; pixel++)
    {
        double xValue = (pixel/pixelsPerPoint - self.origin.x)/self.scale;
        CGFloat xPoint = self.origin.x + xValue*self.scale;
        
        double yValue = [self.dataSource yValueForGraphView:self forXValue:xValue];
        CGFloat yPoint = self.origin.y - yValue*self.scale;
        
        if (!started) {
            CGContextMoveToPoint(context, xPoint, yPoint);
            started = YES;
        } else {
            CGContextAddLineToPoint(context, xPoint, yPoint);
        }
    }
    
    CGContextStrokePath(context);
}


@end
