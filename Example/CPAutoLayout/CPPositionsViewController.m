//
// Created by sakim on 14. 11. 30..
// Copyright (c) 2014 Sung Ahn Kim. All rights reserved.
//

#import "CPPositionsViewController.h"
#import "CPAutoLayout.h"
#import "CPItemView.h"


@interface CPPositionsViewController ()

@property (nonatomic, weak) UIView *center;

@end

@implementation CPPositionsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Positions";
    }

    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    CPItemView *center = [[CPItemView alloc] initWithTitle:@"Center"];
    center.backgroundColor = [UIColor colorWithRed:0.6 green:0.82 blue:0.72 alpha:1];
    center.titleLabel.font = [UIFont fontWithName:@"GillSans" size:15];
    [self.view addSubview:center];
    [center setConstraints:^(CPConstraintsBuilder *builder) {
        builder.position(CPPositionCenter);
        builder.size.value(CGSizeMake(180, 180));
    }];
    self.center = center;

    [self createItemTo:CPPositionTop title:@"Top"];
    [self createItemTo:CPPositionRight title:@"Right"];
    [self createItemTo:CPPositionBottom title:@"Bottom"];
    [self createItemTo:CPPositionLeft title:@"Left"];

    [self createSeparatorTo:CPPositionTop size:CGSizeMake(300, 1)];
    [self createSeparatorTo:CPPositionBottom size:CGSizeMake(300, 1)];
    [self createSeparatorTo:CPPositionRight size:CGSizeMake(1, 300)];
    [self createSeparatorTo:CPPositionLeft size:CGSizeMake(1, 300)];

    // description
    CPItemView *description = [[CPItemView alloc] initWithTitle:@"Shows basic view positioning."];
    description.titleLabel.font = [UIFont fontWithName:@"GillSans" size:13.f];
    [self.view addSubview:description];
    [description setConstraints:^(CPConstraintsBuilder *builder) {
        builder.position(CPAlignmentTop|CPAlignmentLeft).withOffsetY(5);
        builder.width.toItem(self.view);
        builder.height.value(20);
    }];
}


- (void)createItemTo:(CPPosition)position title:(NSString *)title
{
    CPItemView *item = [[CPItemView alloc] initWithTitle:title];
    item.titleLabel.font = [UIFont fontWithName:@"GillSans" size:15];
    [self.view addSubview:item];
    [item setConstraints:^(CPConstraintsBuilder *builder) {
        builder.position(position).toItem(self.center);
        builder.size.value(CGSizeMake(60, 60));
    }];
}


- (void)createSeparatorTo:(CPPosition)position size:(CGSize)size
{
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor blackColor];
    [self.view addSubview:line];
    [line setConstraints:^(CPConstraintsBuilder *builder) {
        builder.position(position).toItem(self.center);
        builder.size.value(size);
    }];
}

@end