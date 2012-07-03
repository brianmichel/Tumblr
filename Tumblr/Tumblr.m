//
//  Tumblr.m
//  Tumblr
//
//  Created by Brian Michel on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tumblr.h"
#import "NXOAuth2.h"

NSString * const kTumblrAPIBaseURL = @"http://api.tumblr.com/v2/blog/";
NSString * const kTumblrAPIVersion = @"v2";

NSString * const kTumblrHostNameKey = @"hostName";
NSString * const kTumblrAPIKeyKey = @"apiKey";
NSString * const kTumblrUserNameKey = @"userName";
NSString * const kTumblrPasswordKey = @"password";
NSString * const kTumblrConsumerSecretKey = @"consumerSecret";

NSString * const kTumblrOAuthRequestTokenURL = @"http://www.tumblr.com/oauth/request_token";
NSString * const kTumblrOAuthAuthorizeURL = @"http://www.tumblr.com/oauth/authorize";
NSString * const kTumblrOAuthAccessTokenURL = @"http://www.tumblr.com/oauth/access_token";

typedef enum TumblrAPIAuthenticationMethod {
  TumblrAPIAuthenticationMethodNone = 0,
  TumblrAPIAuthenticationMethodAPIKey,
  TumblrAPIAuthenticationMethodOAuth,
} TumblrAPIAuthenticationMethod;

NSDictionary * create_initialization_dictionary (NSString *hostName, NSString *apiKey, NSString *username, NSString *password, NSString *consumerSecret) {
  if (hostName && apiKey && username && password && consumerSecret) {
    NSDictionary *initDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    hostName, kTumblrHostNameKey, 
                                    apiKey, kTumblrAPIKeyKey, 
                                    username, kTumblrUserNameKey, 
                                    password, kTumblrPasswordKey, 
                                    consumerSecret, kTumblrConsumerSecretKey,  nil];
    return initDictionary;
  }
  return nil;
};
  
@interface Tumblr ()

@property (strong) NSDictionary *nameFromPostTypeDictionary;

@end

@implementation Tumblr

@synthesize hostName = _hostName;
@synthesize userName = _userName;
@synthesize APIKey = _APIKey;

@synthesize nameFromPostTypeDictionary = _nameFromPostTypeDictionary;

+ (NSString *)version {
  return @"0.0.1";
}

+ (Tumblr *)tumblrWithDictionary:(NSDictionary *)dictionary {
  return [[Tumblr alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
    _hostName = [dictionary objectForKey:kTumblrHostNameKey];
    _APIKey = [dictionary objectForKey:kTumblrAPIKeyKey];
    _userName = [dictionary objectForKey:kTumblrUserNameKey];
    [[NXOAuth2AccountStore sharedStore] setClientID:_userName
                                             secret:[dictionary objectForKey:kTumblrConsumerSecretKey] 
                                   authorizationURL:[NSURL URLWithString:kTumblrOAuthAuthorizeURL] 
                                           tokenURL:[NSURL URLWithString:kTumblrOAuthRequestTokenURL]
                                        redirectURL:nil 
                                     forAccountType:@"Tumblr"];

    self.nameFromPostTypeDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"text", TumblrPostTypeText,
                                       @"photo", TumblrPostTypePhoto,
                                       @"quote", TumblrPostTypeQuote, 
                                       @"link", TumblrPostTypeLink,
                                       @"chat", TumblrPostTypeChat,
                                       @"audio", TumblrPostTypeAudio,
                                       @"video", TumblrPostTypeVideo,
                                       @"answer", TumblrPostTypeAnswer, nil];
  }
  return self;
}


- (void)makeAPICallWithURL:(NSURL *)resourceURL method:(NSString *)method authenticationMethod:(TumblrAPIAuthenticationMethod)authMethod optionalParameters:(NSDictionary *)params andCallback:(TumblrAPICallback)callback {
  NXOAuth2Account *account = nil;
  NSString *apiKey = nil;
  switch (authMethod) {
    case TumblrAPIAuthenticationMethodAPIKey:
      apiKey = self.APIKey;
      break;
    case TumblrAPIAuthenticationMethodOAuth:
      account = [[NXOAuth2AccountStore sharedStore] accountWithIdentifier:self.userName];
      break;
    default:
      account = nil;
      apiKey = nil;
      break;
  }
  
  NSMutableDictionary *optionalParameters = [NSMutableDictionary dictionaryWithDictionary:params];
  [optionalParameters setObject:apiKey forKey:@"api_key"];
  
  [NXOAuth2Request performMethod:method onResource:resourceURL usingParameters:optionalParameters withAccount:account sendProgressHandler:nil responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
    if (!error) {
      NSError *parseError = nil;
      NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&parseError];
      if (callback) {
        callback(parseError, dictionary);
      }
    } else {
      if (callback) {
        callback(error, nil);
      }
    }
  }];
  
}

@end
@implementation Tumblr (Retreiving)

#pragma mark - Fetching
- (void)retreiveBlogInfo:(TumblrAPICallback)callback {
  NSURL *blogInfoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/info", kTumblrAPIBaseURL, self.hostName]];
  [self makeAPICallWithURL:blogInfoURL 
                    method:@"GET" 
      authenticationMethod:TumblrAPIAuthenticationMethodAPIKey 
        optionalParameters:nil 
               andCallback:callback];
}
- (void)retreivePostsOfType:(TumblrPostType)type withCallback:(TumblrAPICallback)callback {
  
}


@end

