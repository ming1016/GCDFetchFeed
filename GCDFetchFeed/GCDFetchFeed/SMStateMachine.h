//
//  SMStateMachine.h
//  CarpoolBusiness
//
//  Created by DaiMing on 2017/11/21.
//

#import <Foundation/Foundation.h>
@class SMState;

@interface SMStateMachine : NSObject
@property (nonatomic, readonly) NSSet *states;
@property (nonatomic, strong) SMState *currentState;

- (void)addStates:(NSArray *)states;

- (SMState *)stateNamed:(NSString *)name;


@end
