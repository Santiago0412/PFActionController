//
//  AppDelegate.h
//  PFActionController
//
//  Created by Santiago on 2018/12/11.
//  Copyright © 2018 Santiago. All rights reserved.
//

#import "UIView+PFActionController.h"
@implementation UIView (RMActionController)

+ (UIView *)seperatorView {
    UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectZero];
    seperatorView.backgroundColor = [UIColor grayColor];
    seperatorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    return seperatorView;
}

@end
