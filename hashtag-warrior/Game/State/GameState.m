//
//  GameState.m
//  hashtag-warrior
//
//  Created by Nick James on 20/01/2013.
//
//

#import "GameState.h"

SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(GameState);

@implementation GameState

@synthesize _score;
@synthesize _hashtag;
@synthesize _won;

SYNTHESIZE_SINGLETON_FOR_CLASS(GameState);

- (id)init
{
    if ((self=[super init]))
    {
        self._score = 0;
        self._hashtag = @"foo";
        self._won = NO;
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:self._score forKey:@"_score"];
    [coder encodeObject:self._hashtag forKey:@"_hashtag"];
    [coder encodeBool:self._won forKey:@"_won"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if(self != nil)
    {
        self._score = [coder decodeIntForKey:@"_score"];
        self._hashtag = [coder decodeObjectForKey:@"_hashtag"];
        self._won = [coder decodeBoolForKey:@"_won"];
    }
    
    return self;
}

@end