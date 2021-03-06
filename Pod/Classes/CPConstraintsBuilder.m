//
//  CPConstraintsBuilder.m
//  CPAutoLayout
//
//  Created by Sung Ahn Kim on 11/16/2014.
//  Copyright (c) 2014 Sung Ahn Kim. All rights reserved.
//

#import "CPConstraintsBuilder.h"
#import "Masonry.h"
#import "CPPositionConstraint.h"
#import "CPSizeConstraint.h"
#import "CPWidthConstraint.h"
#import "CPHeightConstraint.h"
#import "CPInsetsConstraint.h"
#import "CPHorizontalConstraint.h"
#import "CPVerticalConstraint.h"


@interface CPConstraintsBuilder()

@property (nonatomic, weak) MAS_VIEW *view;

@property (nonatomic, strong) CPPositionConstraint *positionConstraint;
@property (nonatomic, strong) CPHorizontalConstraint *horizontalConstraint;
@property (nonatomic, strong) CPVerticalConstraint *verticalConstraint;
@property (nonatomic, strong) CPSizeConstraint *sizeConstraint;
@property (nonatomic, strong) CPWidthConstraint *widthConstraint;
@property (nonatomic, strong) CPHeightConstraint *heightConstraint;

@property (nonatomic, strong) CPInsetsConstraint *insetsConstraint __attribute__((deprecated));

@end


@implementation CPConstraintsBuilder

- (instancetype)initWithView:(MAS_VIEW *)view
{
    self = [super init];
    if (self) {
        _view = view;
    }
    return self;
}


- (CPPositionConstraint * (^)(CPPosition position))position
{
    return ^id(CPPosition position) {
        if (self.positionConstraint != nil) {
            [self throwConflictException:@"position"];
        }
        CPPositionConstraint *constraint = [[CPPositionConstraint alloc] initWithPosition:position];
        self.positionConstraint = constraint;
        return constraint;
    };
}


- (CPHorizontalConstraint * (^)(CPPosition position))horizontal
{
    return ^id(CPPosition position) {
        if (self.horizontalConstraint != nil) {
            [self throwConflictException:@"horizontal"];
        }
        CPHorizontalConstraint *constraint = [[CPHorizontalConstraint alloc] initWithPosition:position];
        self.horizontalConstraint = constraint;
        return constraint;
    };
}


- (CPVerticalConstraint * (^)(CPPosition position))vertical
{
    return ^id(CPPosition position) {
        if (self.verticalConstraint != nil) {
            [self throwConflictException:@"vertical"];
        }
        CPVerticalConstraint *constraint = [[CPVerticalConstraint alloc] initWithPosition:position];
        self.verticalConstraint = constraint;
        return constraint;
    };
}


- (CPSizeConstraint *)size
{
    if (self.sizeConstraint != nil) {
        [self throwConflictException:@"size"];
    }
    CPSizeConstraint *constraint = [[CPSizeConstraint alloc] init];
    self.sizeConstraint = constraint;
    return constraint;
}


- (CPWidthConstraint *)width
{
    if (self.widthConstraint != nil) {
        [self throwConflictException:@"width"];
    }
    CPWidthConstraint *constraint = [[CPWidthConstraint alloc] init];
    self.widthConstraint = constraint;
    return constraint;
}


- (CPHeightConstraint *)height
{
    if (self.heightConstraint != nil) {
        [self throwConflictException:@"height"];
    }
    CPHeightConstraint *constraint = [[CPHeightConstraint alloc] init];
    self.heightConstraint = constraint;
    return constraint;
}


- (CPInsetsConstraint *(^)(UIEdgeInsets insets))insets __attribute__((deprecated))
{
    return ^id(UIEdgeInsets insets) {
        if (self.insetsConstraint != nil) {
            [self throwConflictException:@"insets"];
        }
        CPInsetsConstraint *constraint = [[CPInsetsConstraint alloc] initWithInsets:insets];
        self.insetsConstraint = constraint;
        return constraint;
    };
}


- (void)throwConflictException:(NSString *)constraint
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[[NSString alloc] initWithFormat:@"You should never set a '%@' constraint twice to this view.", constraint]
                                 userInfo:nil];
}


- (void)make
{
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        [self buildConstraints:make update:NO];
    }];
}


- (void)remake {
    [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        [self buildConstraints:make update:NO];
    }];
}


- (void)update:(CPConstraintsBuilder *)builder
{
    [self updateConstraints:builder];
    [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        [self buildConstraints:make update:YES];
    }];
}


- (void)updateConstraints:(CPConstraintsBuilder *)builder {
    // position-related update
    if (builder.positionConstraint != nil) {
        self.positionConstraint = builder.positionConstraint;
        self.horizontalConstraint = nil;
        self.verticalConstraint = nil;
    }

    if (builder.horizontalConstraint != nil) {
        self.horizontalConstraint = builder.horizontalConstraint;
        if (builder.verticalConstraint == nil && self.positionConstraint != nil) {
            self.verticalConstraint = self.positionConstraint.verticalConstraint;
        }

        if (builder.positionConstraint == nil) {
            self.positionConstraint = nil;
        }
    }

    if (builder.verticalConstraint != nil) {
        self.verticalConstraint = builder.verticalConstraint;
        if (builder.horizontalConstraint == nil && self.horizontalConstraint != nil) {
            self.horizontalConstraint = self.positionConstraint.horizontalConstraint;
        }

        if (builder.positionConstraint == nil) {
            self.positionConstraint = nil;
        }
    }

    // size-related update
    if (builder.sizeConstraint != nil) {
        self.sizeConstraint = builder.sizeConstraint;
        self.widthConstraint = nil;
        self.heightConstraint = nil;
    }

    if (builder.widthConstraint != nil) {
        self.widthConstraint = builder.widthConstraint;
        if (self.heightConstraint == nil && self.sizeConstraint != nil) {
            self.heightConstraint = self.sizeConstraint.heightConstraint;
        }

        if (builder.sizeConstraint == nil) {
            self.sizeConstraint = nil;
        }
    }

    if (builder.heightConstraint != nil) {
        self.heightConstraint = builder.heightConstraint;
        if (self.widthConstraint == nil && self.sizeConstraint != nil) {
            self.widthConstraint = self.sizeConstraint.widthConstraint;
        }

        if (builder.sizeConstraint == nil) {
            self.sizeConstraint = nil;
        }
    }
}


- (void)buildConstraints:(MASConstraintMaker *)make update:(BOOL)update {
    if (self.view.superview == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"You should attach this view to its superview before making constraints."
                                     userInfo:nil];
    }

    if (self.positionConstraint != nil && (self.horizontalConstraint != nil || self.verticalConstraint != nil)) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"You should never set both a 'position' and a 'horizontal/vertical' constraint. This is an ambiguous position."
                                     userInfo:nil];
    }

    if (self.sizeConstraint != nil && (self.widthConstraint != nil || self.heightConstraint != nil)) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"You should never set both a 'size' and a 'width/height' constraint. This is an ambiguous size."
                                     userInfo:nil];
    }

    NSMutableArray *constraints = [NSMutableArray array];

    // NOTE: must kept in order to calculate initial frame.
    if (self.positionConstraint) [constraints addObject:self.positionConstraint];
    if (self.horizontalConstraint) [constraints addObject:self.horizontalConstraint];
    if (self.verticalConstraint) [constraints addObject:self.verticalConstraint];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (self.insetsConstraint) [constraints addObject:self.insetsConstraint];
#pragma clang diagnostic pop

    if (self.sizeConstraint) [constraints addObject:self.sizeConstraint];
    if (self.widthConstraint && ![self.widthConstraint hasAspectRatio]) [constraints addObject:self.widthConstraint];
    if (self.heightConstraint) [constraints addObject:self.heightConstraint];
    // update later to calculate width with aspect
    if (self.widthConstraint && [self.widthConstraint hasAspectRatio]) [constraints addObject:self.widthConstraint];

    for (CPLayoutConstraint *constraint in constraints) {
        constraint.target = self.view;
        [constraint build:make update:update];
    }
}

@end