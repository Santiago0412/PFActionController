//
//  AppDelegate.h
//  PFActionController
//
//  Created by Santiago on 2018/12/11.
//  Copyright © 2018 Santiago. All rights reserved.
//

#import "PFImageAction.h"

@implementation PFImageAction
+ (nullable instancetype)actionWithTitle:(nonnull NSString *)title image:(UIImage *)image andHandler:(ActionHandlerBlock)handler{
    
    PFImageAction *action = [[self class] actionWithTitle:title andHandler:handler];
    action.image = image;
    return action;
}
@end
