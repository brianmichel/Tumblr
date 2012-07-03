//
//  Tumblr.h
//  Tumblr
//
//  Created by Brian Michel on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

NSDictionary * create_initialization_dictionary (NSString *hostName, NSString *apiKey, NSString *username, NSString *password, NSString *consumerSecret);

typedef enum TumblrPostType {
  TumblrPostTypeUnknown = -1,
  TumblrPostTypeText,
  TumblrPostTypePhoto,
  TumblrPostTypeQuote,
  TumblrPostTypeLink,
  TumblrPostTypeChat,
  TumblrPostTypeAudio,
  TumblrPostTypeVideo,
  TumblrPostTypeAnswer
} TumblrPostType;

extern NSString * const kTumblrAPIBaseURL;
extern NSString * const kTumblrAPIVersion;

@interface Tumblr : NSObject

@property (strong, readwrite) NSString *hostName;
@property (strong, readonly) NSString *APIKey;
@property (strong, readonly) NSString *userName;

+ (NSString *)version;
+ (Tumblr *)tumblrWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface Tumblr (Retrieving)

extern NSString * const kTumblrAvatarSize16;
extern NSString * const kTumblrAvatarSize24;
extern NSString * const kTumblrAvatarSize30;
extern NSString * const kTumblrAvatarSize40;
extern NSString * const kTumblrAvatarSize48;
extern NSString * const kTumblrAvatarSize64;
extern NSString * const kTumblrAvatarSize96;
extern NSString * const kTumblrAvatarSize128;
extern NSString * const kTumblrAvatarSize512;

typedef void (^TumblrAvatarCallback)(NSError *error, NSString *avatar);
typedef void (^TumblrAPICallback)(NSError *error, NSDictionary *dictionary);

- (void)retreiveBlogInfo:(TumblrAPICallback)callback;
- (void)retreivePostsOfType:(TumblrPostType)type withCallback:(TumblrAPICallback)callback;

- (void)retreiveAvatarOfSize:(NSString * const)avatarSize withCallback:(TumblrAvatarCallback)callback;

- (void)retreiveFollowersWithCallback:(TumblrAPICallback)callback;

@end

@interface Tumblr (Posting)

- (void)createPostOfType:(TumblrPostType)type withData:(NSDictionary *)data andCallback:(TumblrAPICallback)callback;

@end
