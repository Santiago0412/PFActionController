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
//#import "UIButton+PFActionController.h"
@interface PFActionViewController ()<UIViewControllerTransitioningDelegate>

@property (nonatomic, strong)UIScrollView *topContainer;
@property (nonatomic, strong)NSString *topTitle;
@property (nonatomic, strong)NSString *topMessage;
@property (nonatomic, strong)UIView *contentView;
@property (nonatomic, strong)NSArray *actionArray;
@property (nonatomic, strong)NSArray *imageActionArray;
@property (assign, nonatomic)BOOL systemStyleOn;
@property (assign, nonatomic)PFActionViewControllerStyle colorStyle;
@property (assign, nonatomic)ConfirmActionBlock cancelBlock;
@property (strong, nonatomic)UIView *currentTopView;
@property (strong, nonatomic)NSArray *topContainersTopMarginConstraint;
@property (assign, nonatomic)float contentHeight;
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
    
    
    PFAction *cancel = [PFAction actionWithTitle:@"Cancel" view:nil andHandler:^{
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
        self.contentHeight = 140.f;
        [self setup];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

#pragma mark - Methods
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self backgroundViewTapped];
}

- (NSInteger)marginForCurrentStyle {
    
    if (self.systemStyleOn) {
        return 10;
    }else{
        return 0;
    }
}

- (CGFloat)actionSheetWidth {
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat minBounds = screenWidth < screenHeight ? screenWidth : screenHeight;
    if (self.systemStyleOn) {
        return minBounds - 2 * [self marginForCurrentStyle];
    }else{
        return screenWidth - 2 * [self marginForCurrentStyle];
    }
}

- (void)setup {
    
    self.view.layer.masksToBounds = YES;
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.transitioningDelegate = self;
    
    NSDictionary *metrics = @{@"seperatorHeight" : @(1.f / [[UIScreen mainScreen] scale]), @"Margin" : @([self marginForCurrentStyle]), @"width":@([self actionSheetWidth])};
    
    [self setupCancel:metrics];
    [self setupTopContainer:metrics];
    [self setupBottomBaseLine:metrics];
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
    
    [self.topContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.topContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:headerTitleLabel attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    
    if (_topMessage.length == 0 || _topMessage == nil){
        [self.topContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.topContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:seperator attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[headerTitleLabel]-(5)-[seperator(seperatorHeight)]-(0)-[currentTopView]" options:0 metrics:metrics views:bindingsDict]];
    }else{
        [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[headerTitleLabel(15)]-(5)-[currentTopView]" options:0 metrics:metrics views:bindingsDict]];
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
    [self.topContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.topContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:headerMessageLabel attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.topContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.topContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:seperator attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[headerMessageLabel(15)]-(5)-[seperator(seperatorHeight)]-(0)-[currentTopView]" options:0 metrics:metrics views:bindingsDict]];
    
    _currentTopView = headerMessageLabel;
}

- (void)setupContentView:(NSDictionary *)metrics {
    
    if (!_contentView) return;
    
    self.contentHeight = _contentView.frame.size.height > 0 ? _contentView.frame.size.height : _contentHeight;
    
    UIView *seperator = [UIView seperatorView];
    [self.topContainer addSubview:seperator];
    
    NSDictionary *bindingsDict = @{@"contentView":self.contentView,@"currentTopView":_currentTopView,@"seperator":seperator};
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topContainer addSubview:self.contentView];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[contentView(>=300)]" options:0 metrics:nil views:bindingsDict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contentView(contentHeight)]" options:0 metrics:@{@"contentHeight":@(_contentHeight)} views:bindingsDict]];
    
    [self.topContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.topContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.topContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.topContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:seperator attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[contentView]-(0)-[seperator(seperatorHeight)]-(0)-[currentTopView]" options:0 metrics:metrics views:bindingsDict]];
    
    _currentTopView = _contentView;
}

- (void)setupActions:(NSDictionary *)metrics {
    
    if (!_actionArray||_actionArray.count == 0) return;
    
    __weak PFActionViewController *WEAKSELF = self;
    [self.actionArray enumerateObjectsUsingBlock:^(PFAction *action, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIView *item = [[UIView alloc] init];
        item.translatesAutoresizingMaskIntoConstraints = NO;
        [WEAKSELF.topContainer addSubview:item];
        
        float itemHeight = [WEAKSELF runningAtLeastiOS9] ? 55 : 44;
        
        if (action.contentView) {
            itemHeight = action.contentView.frame.size.height > 0 ? action.contentView.frame.size.height : itemHeight;

            action.contentView.translatesAutoresizingMaskIntoConstraints = NO;
            [item addSubview:action.contentView];
            [item addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[contentView]-(0)-|" options:0 metrics:nil views:@{@"contentView":action.contentView}]];
            [item addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[contentView]-(0)-|" options:0 metrics:nil views:@{@"contentView":action.contentView}]];
        }
        
        [WEAKSELF.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[item(height)]" options:0 metrics:@{@"height": @(itemHeight)} views:NSDictionaryOfVariableBindings(item)]];
        [WEAKSELF.topContainer addConstraint:[NSLayoutConstraint constraintWithItem:WEAKSELF.topContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:item attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
        [button setTitleColor:[WEAKSELF getFontColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitle:action.title forState:UIControlStateNormal];
        
        [item addSubview:button];
        [item addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[button]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
        [item addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[button]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
        
        if (!WEAKSELF.systemStyleOn && idx == 0) {
            [button addTarget:WEAKSELF action:@selector(backgroundViewTapped) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [button addTarget:action action:@selector(performAction) forControlEvents:UIControlEventTouchUpInside];
        }
        
        UIView *seperator = [UIView seperatorView];
        NSDictionary *bindingsDict = @{@"item":item,@"currentTopView":WEAKSELF.currentTopView,@"seperator":seperator};
        [WEAKSELF.topContainer addSubview:seperator];
        [WEAKSELF.topContainer addConstraint:[NSLayoutConstraint constraintWithItem:WEAKSELF.topContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:seperator attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
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
    
    NSDictionary *metrics = @{@"width":@(width),@"halfWidth":@(halfWidth),@"quarterWidth":@(quarterWidth)};
    UIScrollView *bottomParentView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    bottomParentView.translatesAutoresizingMaskIntoConstraints = NO;
    bottomParentView.showsVerticalScrollIndicator = NO;
    bottomParentView.showsHorizontalScrollIndicator = NO;
    [bottomParentView setContentSize:CGSizeMake(width*_imageActionArray.count, width)];
    
    [self.topContainer addSubview:bottomParentView];
    [self.topContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.topContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:bottomParentView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
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
    self.currentTopView = bottomParentView;
}

- (void)setupBottomBaseLine:(NSDictionary *)metrics {
    
    UIView *bottomBaseLine = [[UIView alloc] initWithFrame:CGRectZero];
    bottomBaseLine.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomBaseLine setBackgroundColor:[UIColor clearColor]];
    [self.topContainer addSubview:bottomBaseLine];
    [self.topContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.topContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:bottomBaseLine attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomBaseLine(0.1)]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bottomBaseLine)]];
    self.currentTopView = bottomBaseLine;
}

- (void)setupTopContainer:(NSDictionary *)metrics {
    
    self.topContainer = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.topContainer.layer.cornerRadius = [metrics[@"Margin"] floatValue];
    self.topContainer.clipsToBounds = YES;
    self.topContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topContainer setBackgroundColor:[self getBackgroundColor]];
    self.topContainer.showsVerticalScrollIndicator = NO;
    self.topContainer.showsHorizontalScrollIndicator = NO;
    
    [self.view addSubview:self.topContainer];
    
    if (_currentTopView) {
        
        NSDictionary *bindingsDict = @{
                                       @"topContainer":self.topContainer,
                                       @"currentTopView":_currentTopView,
                                       };
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topContainer]-(Margin)-[currentTopView]" options:0 metrics:metrics views:bindingsDict]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[topContainer(width)]" options:0 metrics:metrics views:bindingsDict]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topContainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    }else {
        
        UIView *bottomBaseViewForiPhoneX = [[UIView alloc] initWithFrame:CGRectZero];
        NSDictionary *bindingsDict = @{@"topContainer":self.topContainer,@"bottomBaseViewForiPhoneX":bottomBaseViewForiPhoneX};
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[topContainer]-(0)-|" options:0 metrics:metrics views:bindingsDict]];
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
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cancel(width)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(cancel)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cancel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cancel(height)]" options:0 metrics:@{@"height": @([self runningAtLeastiOS9] ? 55 : 44)} views:NSDictionaryOfVariableBindings(cancel)]];
    
    id bottomItem;
    if(@available(iOS 11, *)) {
        bottomItem = self.view.safeAreaLayoutGuide;
    } else {
        bottomItem = self.view;
    }
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cancel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bottomItem attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
    
    self.currentTopView = cancel;
}

- (float)getTopContainerHeight {

    float topContainerHeight = 0.f;
    
    float speratorHeight =  1.f / [[UIScreen mainScreen] scale];
    float SystemWidth = [[UIScreen mainScreen] bounds].size.width > [[UIScreen mainScreen] bounds].size.height ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width;
    float imageActionHeight = SystemWidth*2/7;

    for (PFAction *action in _actionArray) {
    
        float itemHeight = [self runningAtLeastiOS9] ? 55 : 44;
        
        if (action.contentView && action.contentView.frame.size.height > 0) {
            itemHeight = action.contentView.frame.size.height;
        }
        
        topContainerHeight = topContainerHeight + (itemHeight + speratorHeight);
    }

    if (_contentView) {
        topContainerHeight = topContainerHeight + _contentHeight + speratorHeight;
    }
    
    if (_topMessage) {
        topContainerHeight = topContainerHeight + 20;
    }
    
    topContainerHeight += 25;
    
    if (!_systemStyleOn) {
        
        topContainerHeight += imageActionHeight;
    }
    
    return topContainerHeight;
}

- (void)dismissActionViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupTopContainersTopMarginConstraint {
    
    float topContainerHeight = [self getTopContainerHeight];
    float maxEdge = [[UIScreen mainScreen] bounds].size.height;
    
    float systemTopContainerOffSetY;
    float expandTopContainerOffSetY;
    if ([[UIScreen mainScreen] bounds].size.height > [[UIScreen mainScreen] bounds].size.width) {
        systemTopContainerOffSetY = 170;
        expandTopContainerOffSetY = 100;
    }else{
        systemTopContainerOffSetY = 120;
        expandTopContainerOffSetY = 50;
    }
    
    float maxHeight = _systemStyleOn ? maxEdge - systemTopContainerOffSetY : maxEdge - expandTopContainerOffSetY;
    
    if (topContainerHeight > maxHeight) {
        _topContainer.scrollEnabled = YES;
        topContainerHeight = maxHeight;
    }else{
        _topContainer.scrollEnabled = NO;
    }
    
    NSDictionary *metrics = @{@"topContainerHeight":@(topContainerHeight)};
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    //why >=0 can't be deleted ???
    self.topContainersTopMarginConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[topContainer(topContainerHeight)]" options:0 metrics:metrics views:@{@"topContainer": self.topContainer}];
    [self.view addConstraints:_topContainersTopMarginConstraint];
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
        [self.view addGestureRecognizer:tapRecognizer];
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

#pragma mark - ChangeRotateNotificationMethod
- (void)changeRotate:(NSNotification*)noti {
    
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown) {
        [self.view removeConstraints:_topContainersTopMarginConstraint];
        [self setupTopContainersTopMarginConstraint];
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    } else {
        [self.view removeConstraints:_topContainersTopMarginConstraint];
        [self setupTopContainersTopMarginConstraint];
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }
}

@end
