//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Joanne Dyer on 11/14/12.
//  Copyright (c) 2012 Joanne Dyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(id)operand;
- (void)undo;
- (double)performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variableValues;
- (void)clearHistory;
- (NSString *)description;
- (NSSet *)variablesUsed;

@property (readonly) id program;

+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues;
+ (NSString *)descriptionOfProgram:(id)program;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end
