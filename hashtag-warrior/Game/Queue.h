//
//  Queue.h
//  hashtag-warrior
//
//  Created by Nick James on 06/05/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Queue : NSObject
{
    NSMutableArray* _items;
}

- (void)addToQueue:(id)item;
- (id)peekQueue;
- (id)popQueue;

- (NSUInteger)count;

@end
