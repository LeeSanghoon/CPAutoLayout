//
//  View+CPAutoLayout.m
//  CPAutoLayout
//
//  Created by Sung Ahn Kim on 11/16/2014.
//  Copyright (c) 2014 Sung Ahn Kim. All rights reserved.
//

#import <objc/runtime.h>
#import "View+CPAutoLayout.h"

@implementation MAS_VIEW (CPAutoLayout)

static char kAssociatedObjectKey;

- (void)setAssociatedObject:(id)object {
    objc_setAssociatedObject(self, &kAssociatedObjectKey, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)associatedObject {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey);
}

- (void)setConstraints:(void (^)(CPConstraintsBuilder *builder))block
{
    CPConstraintsBuilder *builder = [[CPConstraintsBuilder alloc] initWithView:self];
    block(builder);
    [builder make];
}


- (void)makeConstraints:(void (^)(CPConstraintsBuilder *builder))block
{
    CPConstraintsBuilder *builder = [[CPConstraintsBuilder alloc] initWithView:self];
    block(builder);
    [builder make];
    [self setAssociatedObject:builder];
}

- (void)remakeConstraints:(void (^)(CPConstraintsBuilder *builder))block
{
    CPConstraintsBuilder *builder = [[CPConstraintsBuilder alloc] initWithView:self];
    block(builder);
    [builder remake];
    [self setAssociatedObject:builder];
}


- (void)updateConstraints:(void (^)(CPConstraintsBuilder *builder))block
{
    CPConstraintsBuilder *updateBuilder = [[CPConstraintsBuilder alloc] initWithView:self];
    block(updateBuilder);

    CPConstraintsBuilder *builder = [self associatedObject];
    [builder update:updateBuilder];
}


// https://gist.github.com/nfarina/3412730
- (CGPoint)$origin { return self.frame.origin; }
- (void)set$origin:(CGPoint)origin { self.frame = (CGRect){ .origin=origin, .size=self.frame.size }; }

- (CGFloat)$x { return self.frame.origin.x; }
- (void)set$x:(CGFloat)x { self.frame = (CGRect){ .origin.x=x, .origin.y=self.frame.origin.y, .size=self.frame.size }; }

- (CGFloat)$y { return self.frame.origin.y; }
- (void)set$y:(CGFloat)y { self.frame = (CGRect){ .origin.x=self.frame.origin.x, .origin.y=y, .size=self.frame.size }; }

- (CGSize)$size { return self.frame.size; }
- (void)set$size:(CGSize)size { self.frame = (CGRect){ .origin=self.frame.origin, .size=size }; }

- (CGFloat)$width { return self.frame.size.width; }
- (void)set$width:(CGFloat)width { self.frame = (CGRect){ .origin=self.frame.origin, .size.width=width, .size.height=self.frame.size.height }; }

- (CGFloat)$height { return self.frame.size.height; }
- (void)set$height:(CGFloat)height { self.frame = (CGRect){ .origin=self.frame.origin, .size.width=self.frame.size.width, .size.height=height }; }

- (CGFloat)$left { return self.frame.origin.x; }
- (void)set$left:(CGFloat)left { self.frame = (CGRect){ .origin.x=left, .origin.y=self.frame.origin.y, .size.width=fmaxf(self.frame.origin.x+self.frame.size.width-left,0), .size.height=self.frame.size.height }; }

- (CGFloat)$top { return self.frame.origin.y; }
- (void)set$top:(CGFloat)top { self.frame = (CGRect){ .origin.x=self.frame.origin.x, .origin.y=top, .size.width=self.frame.size.width, .size.height=fmaxf(self.frame.origin.y+self.frame.size.height-top,0) }; }

- (CGFloat)$right { return self.frame.origin.x + self.frame.size.width; }
- (void)set$right:(CGFloat)right { self.frame = (CGRect){ .origin=self.frame.origin, .size.width=fmaxf(right-self.frame.origin.x,0), .size.height=self.frame.size.height }; }

- (CGFloat)$bottom { return self.frame.origin.y + self.frame.size.height; }
- (void)set$bottom:(CGFloat)bottom { self.frame = (CGRect){ .origin=self.frame.origin, .size.width=self.frame.size.width, .size.height=fmaxf(bottom-self.frame.origin.y,0) }; }


@end