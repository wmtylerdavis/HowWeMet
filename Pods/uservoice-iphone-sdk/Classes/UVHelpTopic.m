//
//  UVHelpTopic.m
//  UserVoice
//
//  Created by Austin Taylor on 11/16/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVHelpTopic.h"
#import "UVResponseDelegate.h"

@implementation UVHelpTopic

@synthesize name;
@synthesize topicId;
@synthesize articleCount;

+ (void)initialize {
    [self setDelegate:[[UVResponseDelegate alloc] initWithModelClass:[self class]]];
    [self setBaseURL:[self siteURL]];
}

+ (id)getAllWithDelegate:(id)delegate {
    NSString *path = [self apiPath:@"/topics.json"];
    return [self getPath:path
              withParams:nil
                  target:delegate
                selector:@selector(didRetrieveHelpTopics:)];
}

+ (id)getTopicWithId:(NSInteger)topicId delegate:(id)delegate {
    NSString *path = [self apiPath:[NSString stringWithFormat:@"/topics/%i.json", topicId]];
    return [self getPath:path
              withParams:nil
                  target:delegate
                selector:@selector(didRetrieveHelpTopic:)];
}


- (id)initWithDictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        self.topicId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        self.name = [self objectOrNilForDict:dict key:@"name"];
        self.articleCount = [(NSNumber *)[dict objectForKey:@"article_count"] integerValue];
        // position, url
    }
    return self;
}

- (void)dealloc {
    self.name = nil;
    [super dealloc];
}

@end
