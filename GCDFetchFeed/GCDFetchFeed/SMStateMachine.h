//
//  SMStateMachine.h
//  CarpoolBusiness
//
//  Created by DaiMing on 2017/11/21.
//

#import <Foundation/Foundation.h>
@class SMState, SMEvent;

@interface SMStateMachine : NSObject
@property (nonatomic, readonly) NSSet *states;
@property (nonatomic, readonly) NSSet *events;
@property (nonatomic, strong) SMState *currentState;

- (void)addStates:(NSArray *)states;
- (void)addEvents:(NSArray *)events;

- (SMState *)stateNamed:(NSString *)name;
- (SMEvent *)eventNamed:(NSString *)name;

@end
