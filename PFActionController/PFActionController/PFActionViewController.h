//
//  AppDelegate.h
//  PFActionController
//
//  Created by Santiago on 2018/12/11.
//  Copyright © 2018 Santiago. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFAction.h"
#import "PFImageAction.h"

typedef void(^ConfirmActionBlock)(void);

typedef NS_ENUM(NSInteger, PFActionViewControllerStyle) {
    /** Displays a PFActionViewController with a light background. */
    PFActionViewControllerStyleWhite,
    /** Displays a PFActionViewController with a dark background. */
    PFActionViewControllerStyleBlack,
};

@interface PFActionViewController : UIViewController <UIAppearanceContainer>

//return a tableview style actioncontroller with a separate cancel button
//the content view's height depend on user, if you have a content view without height, then the content view's height will be 140.f
+ (nullable instancetype)normalActionControllerWithTitle:(nonnull NSString *)title
                                                 message:(nullable NSString *)message
                                             contentView:(nullable UIView *)contentView
                                                 actions:(NSArray<PFAction*>*)actionArray
                                                  cancel:(nullable ConfirmActionBlock)canceld
                                                   style:(PFActionViewControllerStyle)style;

//return a tableview style actioncontroller and one cell include many items is scrollable
//the content view's height depend on user, if you have a content view without height, then the content view's height will be 140.f
+ (nullable instancetype)exportActionControllerWithTitle:(nonnull NSString *)title
                                                 message:(nullable NSString *)message
                                             contentView:(nullable UIView *)contentView
                                                 actions:(NSArray<PFAction*>*)actionArray
                                            imageActions:(nonnull NSArray<PFImageAction*>*)imageActionArray
                                                  cancel:(nullable ConfirmActionBlock)canceld
                                                   style:(PFActionViewControllerStyle)style;

//show action with animation
- (void)showFromViewController:(UIViewController *)viewController;

@end


