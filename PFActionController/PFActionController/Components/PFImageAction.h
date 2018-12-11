//
//  AppDelegate.h
//  PFActionController
//
//  Created by Santiago on 2018/12/11.
//  Copyright © 2018 Santiago. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFAction.h"

@interface PFImageAction : PFAction

+ (nullable instancetype)actionWithTitle:(nonnull NSString *)title image:(UIImage *)image andHandler:(ActionHandlerBlock)handler;

@property(strong, nonatomic)UIImage *image;

@end

