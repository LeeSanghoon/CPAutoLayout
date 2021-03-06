//
//  CPHeightConstraint.m
//  CPAutoLayout
//
//  Created by Sung Ahn Kim on 11/28/2014.
//  Copyright (c) 2014 Sung Ahn Kim. All rights reserved.
//

#import "CPWidthConstraint.h"
#import "Masonry.h"
#import "MASConstraint+Private.h"
#import "View+CPAutoLayout.h"


@interface CPWidthConstraint ()

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) NSLayoutRelation relation;

// relative width
@property (nonatomic, weak) MAS_VIEW *item;
@property (nonatomic, assign) CGFloat offsetX;
@property (nonatomic, assign) CGFloat multiplier;
@property (nonatomic, assign) CGFloat aspect;

@property (nonatomic, assign) CPPosition distancePosition;

@end


@implementation CPWidthConstraint

- (instancetype)init
{
    self = [super init];
    if (self) {
        _multiplier = 1.f;
        _aspect = NAN;
    }
    return self;
}


- (CPWidthConstraint *(^)(CGFloat width))equalTo
{
    return ^id (CGFloat width) {
        return self.equalToWithRelation(width, NSLayoutRelationEqual);
    };
}


- (CPWidthConstraint *(^)(CGFloat width))lessThanOrEqualTo
{
    return ^id (CGFloat width) {
        return self.equalToWithRelation(width, NSLayoutRelationLessThanOrEqual);
    };
}


- (CPWidthConstraint *(^)(CGFloat width))greaterThanOrEqualTo
{
    return ^id (CGFloat width) {
        return self.equalToWithRelation(width, NSLayoutRelationGreaterThanOrEqual);
    };
}


- (CPWidthConstraint *(^)(CGFloat width, NSLayoutRelation relation))equalToWithRelation
{
    return ^id (CGFloat width, NSLayoutRelation relation) {
        self.width = width;
        self.relation = relation;
        return self;
    };
}


- (CPWidthConstraint *(^)(MAS_VIEW *item))equalToItem
{
    return ^id (MAS_VIEW *item) {
        return self.equalToItemWithRelation(item, NSLayoutRelationEqual);
    };
}


- (CPWidthConstraint *(^)(MAS_VIEW *item))lessThanOrEqualToItem
{
    return ^id (MAS_VIEW *item) {
        return self.equalToItemWithRelation(item, NSLayoutRelationLessThanOrEqual);
    };
}


- (CPWidthConstraint *(^)(MAS_VIEW *item))greaterThanOrEqualToItem
{
    return ^id (MAS_VIEW *item) {
        return self.equalToItemWithRelation(item, NSLayoutRelationGreaterThanOrEqual);
    };
}


- (CPWidthConstraint *(^)(MAS_VIEW *item))distanceToLeftOf
{
    return ^id (MAS_VIEW *item) {
        self.item = item;
        self.distancePosition = CPPositionLeft;
        return self;
    };
}


- (CPWidthConstraint *(^)(MAS_VIEW *item))distanceToRightOf
{
    return ^id (MAS_VIEW *item) {
        self.item = item;
        self.distancePosition = CPPositionRight;
        return self;
    };
}


- (CPWidthConstraint * (^)(MAS_VIEW *item, NSLayoutRelation relation))equalToItemWithRelation
{
    return ^id (MAS_VIEW *item, NSLayoutRelation relation) {
        self.item = item;
        self.relation = relation;
        return self;
    };
}


- (CPWidthConstraint *(^)(CGFloat offsetX))withSizeOffsetX
{
    return ^id (CGFloat offsetX) {
        self.offsetX = offsetX;
        return self;
    };
}


- (CPWidthConstraint *(^)(CGFloat multiplier))multipliedBy
{
    return ^id (CGFloat multiplier) {
        self.multiplier = multiplier;
        return self;
    };
}


- (CPWidthConstraint *(^)(CGFloat aspectRatio))aspectRatio
{
    return ^id (CGFloat aspectRatio) {
        self.aspect = aspectRatio;
        return self;
    };
}


- (BOOL)hasAspectRatio {
    return !isnan(self.aspect);
}


- (void)build:(MASConstraintMaker *)make update:(BOOL)update
{
    CGFloat width = 0;

    if (self.distancePosition == CPPositionLeft) {
        make.right.equalTo(self.item.mas_left).with.offset(self.offsetX);
    } else if (self.distancePosition == CPPositionRight) {
        make.left.equalTo(self.item.mas_right).with.offset(-self.offsetX);
    } else if (self.item) {
        make.width.equalToWithRelation(self.item.mas_width, self.relation).multipliedBy(self.multiplier).sizeOffset(CGSizeMake(self.offsetX, 0));
        width = self.item.$width * self.multiplier + self.offsetX;
    } else if (!isnan(self.aspect)) {
        make.width.equalToWithRelation(self.target.mas_height, self.relation).multipliedBy(self.aspect).sizeOffset(CGSizeMake(self.offsetX, 0));
        width = self.target.$height * self.aspect + self.offsetX;
    } else {
        make.width.equalToWithRelation(@(self.width), self.relation);
        width = self.width;
    }

    // set initial 'frame.size.width'
    if (!update) {
        self.target.$width = width;
    }
}

@end