//
//  AppDelegate.h
//  PFActionController
//
//  Created by Santiago on 2018/12/11.
//  Copyright © 2018 Santiago. All rights reserved.
//

#import "PFAction.h"

@interface PFAction ()

@end

@implementation PFAction

+ (nullable instancetype)actionWithTitle:(nonnull NSString *)title andHandler:(ActionHandlerBlock)handler{
    
    PFAction *action = [[[self class] alloc] init];
    action.title = title;
    action.actionHandler = handler;
    return action;
}

- (void)performAction{
    if (_actionHandler) {
        _actionHandler();
    }
}

@end
