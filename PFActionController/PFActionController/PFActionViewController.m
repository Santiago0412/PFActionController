//
//  AppDelegate.h
//  PFActionController
//
//  Created by Santiago on 2018/12/11.
//  Copyright © 2018 Santiago. All rights reserved.
//

#import "PFActionViewController.h"
#import "PFActionViewController+Private.h"
#import "PFActionControllerTransition.h"
#import "UIView+PFActionController.h"
@interface PFActionViewController ()<UIViewControllerTransitioningDelegate>

@property (nonatomic, strong)UIView *topContainer;
@property (nonatomic, strong)UIView *bottomContainer;
@property (nonatomic, strong)NSString *topTitle;
@property (nonatomic, strong)NSString *topMessage;
@property (nonatomic, strong)UIView *contentView;
@property (nonatomic, strong)NSArray *actionArray;
@property (nonatomic, strong)NSArray *imageActionArray;
@property (assign, nonatomic)BOOL systemStyleOn;
@property (assign, nonatomic)PFActionViewControllerStyle colorStyle;
@property (assign, nonatomic)ConfirmActionBlock cancelBlock;
@property (strong, nonatomic)UIView *currentTopView;

@end

@implementation PFActionViewController

#pragma mark - Class Method
+ (nullable instancetype)normalActionControllerWithTitle:(nonnull NSString *)title
                                                 message:(nullable NSString *)message
                                             contentView:(nullable UIView *)contentView
                                                 actions:(NSArray<PFAction*>*)actionArray
                                                  cancel:(nullable ConfirmActionBlock)canceld
                                                   style:(PFActionViewControllerStyle)style {
    
    return [[self alloc] initWithTitle:title message:message contentView:contentView actions:actionArray imageActions:nil cancel:canceld style:style systemStyleOn:YES];
}

+ (nullable instancetype)exportActionControllerWithTitle:(nonnull NSString *)title
                                                 message:(nullable NSString *)message
                                             contentView:(nullable UIView *)contentView
                                                 actions:(NSArray<PFAction*>*)actionArray
                                            imageActions:(nonnull NSArray<PFImageAction*>*)imageActionArray
                                                  cancel:(nullable ConfirmActionBlock)canceld
                                                   style:(PFActionViewControllerStyle)style {
    
    
    PFAction *cancel = [PFAction actionWithTitle:@"Cancel" andHandler:^{
        canceld();
    }];
    
    NSMutableArray *actionMutableArray = [NSMutableArray arrayWithArray:actionArray];
    [actionMutableArray insertObject:cancel atIndex:0];
    
    return [[self alloc] initWithTitle:title message:message contentView:contentView actions:actionMutableArray imageActions:imageActionArray cancel:canceld style:style systemStyleOn:NO];
}

#pragma mark - Lifecycle
- (instancetype)initWithTitle:(nonnull NSString *)title
                      message:(nullable NSString *)message
                  contentView:(nullable UIView *)contentView
                      actions:(NSArray<PFAction*>*)actionArray
                 imageActions:(nullable NSArray<PFImageAction*>*)imageActionArray
                       cancel:(nullable ConfirmActionBlock)canceld
                        style:(PFActionViewControllerStyle)style
                systemStyleOn:(BOOL)systemStyleOn {
    
    NSAssert(title.length < 23, @"Error: The title is too long!.");
    NSAssert(message.length < 100, @"Error: The message is too long!.");
    
    self = [super initWithNibName:nil bundle:nil];
    
    if(self) {
        self.topTitle = title;
        self.topMessage = message;
        self.contentView = contentView;
        self.actionArray = actionArray;
        self.imageActionArray = imageActionArray;
        self.cancelBlock = canceld;
        self.colorStyle = style;
        self.systemStyleOn = systemStyleOn;
        [self setup];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Methods
- (NSInteger)marginForCurrentStyle {
    
    if (self.systemStyleOn) {
        return 10;
    }else{
        return 0;
    }
}

- (void)setup {
    
    self.view.layer.masksToBounds = YES;
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.transitioningDelegate = self;
    
    NSDictionary *metrics = @{@"seperatorHeight": @(1.f / [[UIScreen mainScreen] scale]), @"Margin": @([self marginForCurrentStyle])};
    
    [self setupCancel:metrics];
    [self setupTopContainer:metrics];
    [self setupBottomBaseLine];
    [self setupImageActions];
    [self setupActions:metrics];
    [self setupContentView:metrics];
    [self setupMessage:metrics];
    [self setupTitle:metrics];
    [self setupTopConstraints];
}

- (void)setupTopConstraints {
    NSDictionary *bindingsDict = @{@"currentTopView":_currentTopView};
    if (_currentTopView.superview.subviews.count == 1) {_currentTopView.superview.backgroundColor = [UIColor clearColor];}
    [_currentTopView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[currentTopView]" options:0 metrics:nil views:bindingsDict]];
}

- (void)setupTitle:(NSDictionary *)metrics {
    
    if (_topTitle.length == 0 || _topTitle == nil) return;
    
    UIView *seperator = [UIView seperatorView];
    [self.topContainer addSubview:seperator];
    
    UILabel *headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerTitleLabel.backgroundColor = [UIColor clearColor];
    headerTitleLabel.textColor = [self getFontColor];
    headerTitleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    headerTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    headerTitleLabel.textAlignment = NSTextAlignmentCenter;
    headerTitleLabel.numberOfLines = 1;
    headerTitleLabel.text = self.topTitle;
    
    [self.topContainer addSubview:headerTitleLabel];
    
    NSDictionary *bindingsDict = @{@"headerTitleLabel":headerTitleLabel,@"currentTopView":self.currentTopView,@"seperator":seperator};
    
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(5)-[headerTitleLabel]-(5)-|" options:0 metrics:nil views:bindingsDict]];
    
    if (_topMessage.length == 0 || _topMessage == nil){
        [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[seperator]-(0)-|" options:0 metrics:nil views:bindingsDict]];
        [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[headerTitleLabel]-(5)-[seperator(seperatorHeight)]-(0)-[currentTopView]" options:0 metrics:metrics views:bindingsDict]];
    }else{
        [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[headerTitleLabel]-(5)-[currentTopView]" options:0 metrics:metrics views:bindingsDict]];
    }
    
    _currentTopView = headerTitleLabel;
}

- (void)setupMessage:(NSDictionary *)metrics {
    
    if (_topMessage.length == 0 || _topMessage == nil) return;
    
    UIView *seperator = [UIView seperatorView];
    [self.topContainer addSubview:seperator];
    
    UILabel *headerMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerMessageLabel.backgroundColor = [UIColor clearColor];
    headerMessageLabel.textColor = [self getFontColor];
    headerMessageLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    headerMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    headerMessageLabel.textAlignment = NSTextAlignmentCenter;
    headerMessageLabel.numberOfLines = 1;
    headerMessageLabel.text = self.topMessage;
    [self.topContainer addSubview:headerMessageLabel];
    
    NSDictionary *bindingsDict = @{@"headerMessageLabel":headerMessageLabel,@"currentTopView":_currentTopView,@"seperator":seperator};
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(5)-[headerMessageLabel]-(5)-|" options:0 metrics:nil views:bindingsDict]];
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[seperator]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[headerMessageLabel]-(5)-[seperator(seperatorHeight)]-(0)-[currentTopView]" options:0 metrics:metrics views:bindingsDict]];
    
    _currentTopView = headerMessageLabel;
}

- (void)setupContentView:(NSDictionary *)metrics {
    
    if (!_contentView) return;
    
    UIView *seperator = [UIView seperatorView];
    [self.topContainer addSubview:seperator];
    
    NSDictionary *bindingsDict = @{@"contentView":self.contentView,@"currentTopView":_currentTopView,@"seperator":seperator};
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topContainer addSubview:self.contentView];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentView(>=300)]" options:0 metrics:nil views:bindingsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contentView(140)]" options:0 metrics:nil views:bindingsDict]];
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[contentView]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[seperator]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contentView]-(0)-[seperator(seperatorHeight)]-(0)-[currentTopView]" options:0 metrics:metrics views:bindingsDict]];
    
    _currentTopView = _contentView;
}

- (void)setupActions:(NSDictionary *)metrics {
    
    if (!_actionArray||_actionArray.count == 0) return;
    
    __weak PFActionViewController *WEAKSELF = self;
    [self.actionArray enumerateObjectsUsingBlock:^(PFAction *action, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIButton *item = [UIButton buttonWithType:UIButtonTypeSystem];
        item.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
        [item setTitleColor:[WEAKSELF getFontColor] forState:UIControlStateNormal];
        [item setBackgroundColor:[UIColor clearColor]];
        [item setTitle:action.title forState:UIControlStateNormal];
        item.translatesAutoresizingMaskIntoConstraints = NO;
        [item setTitleColor:[WEAKSELF getFontColor] forState:UIControlStateNormal];
        
        [WEAKSELF.topContainer addSubview:item];
        [WEAKSELF.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[item]-(0)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(item)]];
        [WEAKSELF.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[item(height)]" options:0 metrics:@{@"height": @([WEAKSELF runningAtLeastiOS9] ? 55 : 44)} views:NSDictionaryOfVariableBindings(item)]];
        
        if (!WEAKSELF.systemStyleOn && idx == 0) {
            [item addTarget:WEAKSELF action:@selector(backgroundViewTapped) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [item addTarget:action action:@selector(performAction) forControlEvents:UIControlEventTouchUpInside];
        }
        
        UIView *seperator = [UIView seperatorView];
        NSDictionary *bindingsDict = @{@"item":item,@"currentTopView":WEAKSELF.currentTopView,@"seperator":seperator};
        [WEAKSELF.topContainer addSubview:seperator];
        [WEAKSELF.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[seperator]-(0)-|" options:0 metrics:nil views:bindingsDict]];
        [WEAKSELF.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[item]-(0)-[seperator(seperatorHeight)]-(0)-[currentTopView]" options:0 metrics:metrics views:bindingsDict]];
        
        WEAKSELF.currentTopView = item;
    }];
}

- (void)setupImageActions {
    
    if (_systemStyleOn) {return;}
    
    float SystemWidth = [[UIScreen mainScreen] bounds].size.width > [[UIScreen mainScreen] bounds].size.height ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width;
    float halfWidth = SystemWidth/7;
    float quarterWidth = halfWidth/2;
    float width = halfWidth*2;
    float labelWidth = 10;
    
    NSDictionary *metrics = @{@"width":@(width),@"halfWidth":@(halfWidth),@"labelWidth":@(labelWidth),@"quarterWidth":@(quarterWidth)};
    UIScrollView *bottomParentView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    bottomParentView.translatesAutoresizingMaskIntoConstraints = NO;
    bottomParentView.showsVerticalScrollIndicator = NO;
    bottomParentView.showsHorizontalScrollIndicator = NO;
    [bottomParentView setContentSize:CGSizeMake(width*_imageActionArray.count, width)];
    
    [self.topContainer addSubview:bottomParentView];
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[bottomParentView]-(0)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bottomParentView)]];
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomParentView(width)]-(0)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bottomParentView)]];
    
    __block UIView *currentRightView = nil;
    __weak PFActionViewController *WEAKSELF = self;
    [_imageActionArray enumerateObjectsUsingBlock:^(PFImageAction *imageAction, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIView *viewItem = [[UIView alloc] initWithFrame:CGRectZero];
        viewItem.translatesAutoresizingMaskIntoConstraints = NO;
        
        [bottomParentView addSubview:viewItem];
        [bottomParentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[viewItem(width)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(viewItem)]];
        
        if (currentRightView == nil) {
            [bottomParentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[viewItem(width)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(viewItem)]];
        }else{
            [bottomParentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[currentRightView]-(0)-[viewItem(width)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(viewItem,currentRightView)]];
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.image = imageAction.image;
        imageView.layer.cornerRadius = quarterWidth;
        imageView.layer.masksToBounds = YES;
        [viewItem addSubview:imageView];
        [viewItem addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(quarterWidth)-[imageView]-(quarterWidth)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(imageView)]];
        
        UILabel *actionTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        actionTitle.translatesAutoresizingMaskIntoConstraints = NO;
        actionTitle.textAlignment = NSTextAlignmentCenter;
        actionTitle.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
        actionTitle.textColor = [WEAKSELF getFontColor];
        actionTitle.text = imageAction.title;
        [viewItem addSubview:actionTitle];
        [viewItem addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[actionTitle]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionTitle)]];
        
        [viewItem addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(quarterWidth)-[imageView]-(0)-[actionTitle(quarterWidth)]-(0)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(imageView,actionTitle)]];
        
        UIButton *actionButton = [[UIButton alloc] initWithFrame:CGRectZero];
        actionButton.translatesAutoresizingMaskIntoConstraints = NO;
        [viewItem addSubview:actionButton];
        [viewItem addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[actionButton]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionButton)]];
        [viewItem addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[actionButton]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionButton)]];
        [actionButton addTarget:imageAction action:@selector(performAction) forControlEvents:UIControlEventTouchUpInside];
        
        currentRightView = viewItem;
    }];
    
    [bottomParentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[currentRightView]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(currentRightView)]];
    _currentTopView = bottomParentView;
}

- (void)setupBottomBaseLine {
    
    UIView *bottomBaseLine = [[UIView alloc] initWithFrame:CGRectZero];
    bottomBaseLine.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomBaseLine setBackgroundColor:[UIColor clearColor]];
    [self.topContainer addSubview:bottomBaseLine];
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[bottomBaseLine]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bottomBaseLine)]];
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomBaseLine(0.1)]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bottomBaseLine)]];
    _currentTopView = bottomBaseLine;
}

- (void)setupTopContainer:(NSDictionary *)metrics {
    
    self.topContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.topContainer.layer.cornerRadius = [metrics[@"Margin"] floatValue];
    self.topContainer.clipsToBounds = YES;
    self.topContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topContainer setBackgroundColor:[self getBackgroundColor]];
    
    [self.view addSubview:self.topContainer];
    
    if (_currentTopView) {
        
        NSDictionary *bindingsDict = @{
                                       @"topContainer":self.topContainer,
                                       @"currentTopView":_currentTopView,
                                       };
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topContainer]-(Margin)-[currentTopView]" options:0 metrics:metrics views:bindingsDict]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(Margin)-[topContainer]-(Margin)-|" options:0 metrics:metrics views:bindingsDict]];
    }else{
        
        UIView *bottomBaseViewForiPhoneX = [[UIView alloc] initWithFrame:CGRectZero];
        NSDictionary *bindingsDict = @{@"topContainer":self.topContainer,@"bottomBaseViewForiPhoneX":bottomBaseViewForiPhoneX};
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(Margin)-[topContainer]-(Margin)-|" options:0 metrics:metrics views:bindingsDict]];
        
        if(@available(iOS 11, *)) {
            bottomBaseViewForiPhoneX.translatesAutoresizingMaskIntoConstraints = NO;
            [bottomBaseViewForiPhoneX setBackgroundColor:[self getBackgroundColor]];
            [self.view addSubview:bottomBaseViewForiPhoneX];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[bottomBaseViewForiPhoneX]-(0)-|" options:0 metrics:metrics views:bindingsDict]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topContainer]-(0)-[bottomBaseViewForiPhoneX]-(0)-|" options:0 metrics:metrics views:bindingsDict]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_topContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
        } else {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topContainer]-(0)-|" options:0 metrics:metrics views:bindingsDict]];
        }
    }
}

- (void)setupCancel:(NSDictionary *)metrics {
    
    if (!_systemStyleOn) {return;}
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    cancel.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
    cancel.layer.cornerRadius = 10.f;
    cancel.clipsToBounds = YES;
    [cancel setTitleColor:[self getFontColor] forState:UIControlStateNormal];
    [cancel setBackgroundColor:[self getBackgroundColor]];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    cancel.translatesAutoresizingMaskIntoConstraints = NO;
    [cancel addTarget:self action:@selector(backgroundViewTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:cancel];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(Margin)-[cancel]-(Margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(cancel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cancel(height)]" options:0 metrics:@{@"height": @([self runningAtLeastiOS9] ? 55 : 44)} views:NSDictionaryOfVariableBindings(cancel)]];
    
    id bottomItem;
    if(@available(iOS 11, *)) {
        bottomItem = self.view.safeAreaLayoutGuide;
    } else {
        bottomItem = self.view;
    }
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cancel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bottomItem attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
    
    _currentTopView = cancel;
}

- (void)dismissActionViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupTopContainersTopMarginConstraint {
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[topContainer]" options:0 metrics:nil views:@{@"topContainer": self.topContainer}]];
}

- (BOOL)runningAtLeastiOS9 {
    return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){9, 0, 0}];
}

- (UIView *)backgroundView {
    if(!_backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTapped)];
        [_backgroundView addGestureRecognizer:tapRecognizer];
    }
    
    return _backgroundView;
}

- (UIBlurEffectStyle)backgroundBlurEffectStyleForCurrentStyle {
    
    switch (self.colorStyle) {
        case PFActionViewControllerStyleWhite:
            return UIBlurEffectStyleLight;
        case PFActionViewControllerStyleBlack:
            return UIBlurEffectStyleDark;
        default:
            return UIBlurEffectStyleLight;
    }   
}

- (UIColor *)getBackgroundColor {
    
    if (self.colorStyle == PFActionViewControllerStyleWhite) {
        return [UIColor whiteColor];
    }else{
        return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    }
}

- (UIColor *)getFontColor {
    if (self.colorStyle == PFActionViewControllerStyleWhite) {
        return [UIColor grayColor];
    }else{
        return [UIColor whiteColor];
    }
}

- (void)backgroundViewTapped {
    
    if (_cancelBlock) {
        _cancelBlock();
    }
    
    [self dismissActionViewController];
}

- (void)showFromViewController:(UIViewController *)viewController{
    [viewController presentViewController:self animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    PFActionControllerTransition *animationController = [[PFActionControllerTransition alloc] init];
    animationController.transitionStyle = PFActionControllerTransitionStylePresenting;
    return animationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    PFActionControllerTransition *animationController = [[PFActionControllerTransition alloc] init];
    animationController.transitionStyle = PFActionControllerTransitionStyleDismissing;
    return animationController;
}
@end
