//
//  AppDelegate.h
//  PFActionController
//
//  Created by Santiago on 2018/12/11.
//  Copyright © 2018 Santiago. All rights reserved.
//

#import "PFActionViewController.h"

@interface PFActionViewController ()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, weak) NSLayoutConstraint *yConstraint;

@property (nonatomic, assign) BOOL hasBeenDismissed;

- (void)setupTopContainersTopMarginConstraint;

@end
