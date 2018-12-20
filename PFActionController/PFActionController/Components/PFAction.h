//
//  AppDelegate.h
//  PFActionController
//
//  Created by Santiago on 2018/12/11.
//  Copyright © 2018 Santiago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ActionHandlerBlock)(void);

@interface PFAction : NSObject

+ (nullable instancetype)actionWithTitle:(nonnull NSString *)title view:(nullable UIView *)contentView andHandler:(ActionHandlerBlock)handler;

@property (strong, nonatomic)NSString *title;
@property (copy, nonatomic)ActionHandlerBlock actionHandler;
@property (strong, nonatomic)UIView *contentView;

- (void)performAction;

@end
