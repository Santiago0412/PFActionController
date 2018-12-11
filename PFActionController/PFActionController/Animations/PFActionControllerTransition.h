//
//  AppDelegate.h
//  PFActionController
//
//  Created by Santiago on 2018/12/11.
//  Copyright © 2018 Santiago. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PFActionControllerTransitionStyle) {
    PFActionControllerTransitionStylePresenting,
    PFActionControllerTransitionStyleDismissing
};

@interface PFActionControllerTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic)PFActionControllerTransitionStyle transitionStyle;

@end
