//
//  AppDelegate.h
//  PFActionController
//
//  Created by Santiago on 2018/12/11.
//  Copyright © 2018 Santiago. All rights reserved.
//

#import "PFActionControllerTransition.h"
#import "PFActionViewController+Private.h"
@implementation PFActionControllerTransition

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    
    if(_transitionStyle == PFActionControllerTransitionStylePresenting) {
        return 1.0f;
    } else if(_transitionStyle == PFActionControllerTransitionStyleDismissing) {
        return 0.3f;
    }
    
    return 0.f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    UIView *containerView = [transitionContext containerView];
    
    if(_transitionStyle == PFActionControllerTransitionStylePresenting) {
        
        PFActionViewController *targetViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        if (![targetViewController isKindOfClass:[PFActionViewController class]]) {
            return;
        }
        
        [targetViewController setupTopContainersTopMarginConstraint];
        targetViewController.backgroundView.alpha = 0;
        
        [containerView addSubview:targetViewController.backgroundView];
        [containerView addSubview:targetViewController.view];
        
        NSDictionary *bindingsDict = @{@"BGView": targetViewController.backgroundView};
        
        [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[BGView]-(0)-|" options:0 metrics:nil views:bindingsDict]];
        [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[BGView]-(0)-|" options:0 metrics:nil views:bindingsDict]];
        
        [containerView addConstraint:[NSLayoutConstraint constraintWithItem:targetViewController.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [containerView addConstraint:[NSLayoutConstraint constraintWithItem:targetViewController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        
        targetViewController.yConstraint = [NSLayoutConstraint constraintWithItem:targetViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [containerView addConstraint:targetViewController.yConstraint];
        
        [containerView setNeedsUpdateConstraints];
        [containerView layoutIfNeeded];
        
        [containerView removeConstraint:targetViewController.yConstraint];
        targetViewController.yConstraint = [NSLayoutConstraint constraintWithItem:targetViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [containerView addConstraint:targetViewController.yConstraint];
        
        [containerView addConstraint:[NSLayoutConstraint constraintWithItem:targetViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:containerView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
   
        [containerView setNeedsUpdateConstraints];
        
        CGFloat damping = 1.0f;
        CGFloat duration = 0.3f;
        
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:1 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            targetViewController.backgroundView.alpha = 1;
            
            [containerView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
        
    } else if(_transitionStyle == PFActionControllerTransitionStyleDismissing) {
        
        PFActionViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        if (![fromViewController isKindOfClass:[PFActionViewController class]]) {
            return;
        }
        
        [containerView removeConstraint:fromViewController.yConstraint];
        fromViewController.yConstraint = [NSLayoutConstraint constraintWithItem:fromViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [containerView addConstraint:fromViewController.yConstraint];
        
        [containerView setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            fromViewController.backgroundView.alpha = 0;
            
            [containerView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [fromViewController.view removeFromSuperview];
            [fromViewController.backgroundView removeFromSuperview];
            
            fromViewController.hasBeenDismissed = NO;
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
