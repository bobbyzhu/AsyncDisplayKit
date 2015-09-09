/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "ASLayoutSpec.h"

#import "ASAssert.h"
#import "ASBaseDefines.h"

#import "ASInternalHelpers.h"
#import "ASLayout.h"
#import "ASLayoutOptions.h"
#import "ASLayoutOptionsPrivate.h"

#import <objc/runtime.h>

static NSString * const kDefaultChildKey = @"kDefaultChildKey";
static NSString * const kDefaultChildrenKey = @"kDefaultChildrenKey";

@interface ASLayoutSpec()
@property (nonatomic, strong) NSMutableDictionary *layoutChildren;
@end

@implementation ASLayoutSpec

@dynamic spacingAfter, spacingBefore, flexGrow, flexShrink, flexBasis, alignSelf, ascender, descender, sizeRange, layoutPosition, layoutOptions;
@synthesize layoutChildren = _layoutChildren;

- (instancetype)init
{
  if (!(self = [super init])) {
    return nil;
  }
  _layoutChildren = [NSMutableDictionary dictionary];
  _isMutable = YES;
  return self;
}

#pragma mark - Layout

- (ASLayout *)measureWithSizeRange:(ASSizeRange)constrainedSize
{
  return [ASLayout layoutWithLayoutableObject:self size:constrainedSize.min];
}

- (ASLayoutSpec *)finalLayoutableWithParent:(ASLayoutSpec *)parentSpec;
{
  return nil;
}

- (void)setChild:(id<ASLayoutable>)child;
{
  [self setChild:child forIdentifier:kDefaultChildKey];
}

- (id<ASLayoutable>)layoutableToAddFromLayoutable:(id<ASLayoutable>)child
{
  ASLayoutOptions *layoutOptions = [child layoutOptions];
  
  id<ASLayoutable> finalLayoutable = [child finalLayoutableWithParent:self];
  if (finalLayoutable) {
    [layoutOptions copyIntoOptions:finalLayoutable.layoutOptions];
    return finalLayoutable;
  }
  return child;
}

- (void)setChild:(id<ASLayoutable>)child forIdentifier:(NSString *)identifier
{
  ASDisplayNodeAssert(self.isMutable, @"Cannot set properties when layout spec is not mutable");
  self.layoutChildren[identifier] = [self layoutableToAddFromLayoutable:child];;
}

- (void)setChildren:(NSArray *)children
{
  ASDisplayNodeAssert(self.isMutable, @"Cannot set properties when layout spec is not mutable");
  
  NSMutableArray *finalChildren = [NSMutableArray arrayWithCapacity:children.count];
  for (id<ASLayoutable> child in children) {
    [finalChildren addObject:[self layoutableToAddFromLayoutable:child]];
  }
  
  self.layoutChildren[kDefaultChildrenKey] = [NSArray arrayWithArray:finalChildren];
}

- (id<ASLayoutable>)childForIdentifier:(NSString *)identifier
{
  return self.layoutChildren[identifier];
}

- (id<ASLayoutable>)child
{
  return self.layoutChildren[kDefaultChildKey];
}

- (NSArray *)children
{
  return self.layoutChildren[kDefaultChildrenKey];
}

                     
@end