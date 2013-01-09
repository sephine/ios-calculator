//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Joanne Dyer on 11/14/12.
//  Copyright (c) 2012 Joanne Dyer. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain ()

@property (nonatomic, strong) NSMutableArray *programStack;
+ (double)popOperandOfStack:(NSMutableArray *)stack
        usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)possibleOperators;
+ (NSString *)createDescriptionFromStack:(NSMutableArray *)stack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (void)pushOperand:(id)operand
{
    if (operand) {
        [self.programStack addObject:operand];
    }
}

- (void)undo
{
    if ([self.programStack lastObject])
    {
        [self.programStack removeLastObject];
    }
}

- (double)performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variableValues
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program usingVariableValues:variableValues];
}

- (void)clearHistory
{
    [self.programStack removeAllObjects];
}

- (NSString *)description
{
    return [CalculatorBrain descriptionOfProgram:self.program];
}

- (id)program
{
    return [self.programStack copy];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSString *description = @"";;
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    else
    {
        return @"program is invalid";
    }
    
    description = [self createDescriptionFromStack:stack withBrackets:NO];
    while ([stack count] != 0)
    {
        description = [[description stringByAppendingString:@", "] stringByAppendingString:[self createDescriptionFromStack:stack withBrackets:NO]];
    }
    
    return description;
}

- (NSSet *)variablesUsed
{
    return [CalculatorBrain variablesUsedInProgram:self.program];
}

+ (NSString *)createDescriptionFromStack:(NSMutableArray *)stack withBrackets:(BOOL)bracketsRequired
{
    NSString *resultString = @"";
    
    id topOfStack = [stack lastObject];
    if (topOfStack)
    {
        [stack removeLastObject];
    }
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        resultString = [topOfStack description];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operationOrVariable = topOfStack;
        if([operationOrVariable isEqualToString:@"+"]) {
            NSString *secondOperand = [self createDescriptionFromStack:stack withBrackets:NO];
            NSString *firstOperand = [self createDescriptionFromStack:stack withBrackets:NO];
            resultString = [[firstOperand stringByAppendingString:@" + "] stringByAppendingString:secondOperand];
            if (bracketsRequired)
            {
                resultString = [[@"(" stringByAppendingString:resultString] stringByAppendingString:@")"];
            }
        } else if ([operationOrVariable isEqualToString:@"-"]) {
            NSString *secondOperand = [self createDescriptionFromStack:stack withBrackets:NO];
            NSString *firstOperand = [self createDescriptionFromStack:stack withBrackets:NO];
            resultString = [[firstOperand stringByAppendingString:@" - "] stringByAppendingString:secondOperand];
            if (bracketsRequired)
            {
                resultString = [[@"(" stringByAppendingString:resultString] stringByAppendingString:@")"];
            }
        } else if ([operationOrVariable isEqualToString:@"*"]) {
            NSString *secondOperand = [self createDescriptionFromStack:stack withBrackets:YES];
            NSString *firstOperand = [self createDescriptionFromStack:stack withBrackets:YES];
            resultString = [[firstOperand stringByAppendingString:@" * "] stringByAppendingString:secondOperand];
        } else if ([operationOrVariable isEqualToString:@"/"]) {
            NSString *secondOperand = [self createDescriptionFromStack:stack withBrackets:YES];
            NSString *firstOperand = [self createDescriptionFromStack:stack withBrackets:YES];
            resultString = [[firstOperand stringByAppendingString:@" / "] stringByAppendingString:secondOperand];
        } else if ([operationOrVariable isEqualToString:@"sin"]) {
            NSString *operand = [self createDescriptionFromStack:stack withBrackets:NO];
            resultString = [[@"sin(" stringByAppendingString:operand] stringByAppendingString:@")"];
        } else if ([operationOrVariable isEqualToString:@"cos"]) {
            NSString *operand = [self createDescriptionFromStack:stack withBrackets:NO];
            resultString = [[@"cos(" stringByAppendingString:operand] stringByAppendingString:@")"];
        } else if ([operationOrVariable isEqualToString:@"sqrt"]) {
            NSString *operand = [self createDescriptionFromStack:stack withBrackets:NO];
            resultString = [[@"sqrt(" stringByAppendingString:operand] stringByAppendingString:@")"];
        } else if ([operationOrVariable isEqualToString:@"pi"]) {
            resultString = @"pi";
        } else {
            resultString = operationOrVariable;
        }
    }

    return resultString;

}

+ (double)runProgram:(id)program
{
    NSDictionary *emptyDictionary = [[NSDictionary alloc] init];
    return [self runProgram:program usingVariableValues:emptyDictionary];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    return [self popOperandOfStack:stack usingVariableValues:variableValues];
}

+ (double)popOperandOfStack:(NSMutableArray *)stack
        usingVariableValues:(NSDictionary *)variableValues
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack)
    {
        [stack removeLastObject];
    }
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        if([operation isEqualToString:@"+"]) {
            result = [self popOperandOfStack:stack usingVariableValues:variableValues] + [self popOperandOfStack:stack usingVariableValues:variableValues];
        } else if ([operation isEqualToString:@"-"]) {
            double firstOperand = [self popOperandOfStack:stack usingVariableValues:variableValues];
            double secondOperand = [self popOperandOfStack:stack usingVariableValues:variableValues];
            result = secondOperand - firstOperand;
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOfStack:stack usingVariableValues:variableValues] * [self popOperandOfStack:stack usingVariableValues:variableValues];
        } else if ([operation isEqualToString:@"/"]) {
            double firstOperand = [self popOperandOfStack:stack usingVariableValues:variableValues];
            double secondOperand = [self popOperandOfStack:stack usingVariableValues:variableValues];
            result = secondOperand / firstOperand;
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOfStack:stack usingVariableValues:variableValues]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOfStack:stack usingVariableValues:variableValues]);
        } else if ([operation isEqualToString:@"sqrt"]) {
            result = sqrt([self popOperandOfStack:stack usingVariableValues:variableValues]);
        } else if ([operation isEqualToString:@"pi"]) {
            result = M_PI;
        } else {
            id operationValue = [variableValues objectForKey:operation];
            if ([operationValue isKindOfClass:[NSNumber class]]) {
                result = [operationValue doubleValue];
            }
        }
    }
    
    return result;
}

+ (NSSet *)possibleOperators
{
    return [NSSet setWithObjects:@"+", @"-", @"*", @"/", @"sin", @"cos", @"sqrt", @"pi", nil];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSMutableArray *stack;
    NSSet *operators = [self possibleOperators];
    
    if ([program isKindOfClass:[NSArray class]])
    {
        stack = [program mutableCopy];
    }
    for (id stackObject in stack)
    {
        if ([stackObject isKindOfClass:[NSString class]] && ![operators containsObject:stackObject])
        {
            [result addObject:stackObject];
        }
    }
    
    if ([result count] == 0)
    {
        return nil;
    }
    
    return [NSSet setWithArray:result];
}

@end
