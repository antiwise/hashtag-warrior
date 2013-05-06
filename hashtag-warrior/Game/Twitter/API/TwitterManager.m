//
//  TwitterManager.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 27/01/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "TwitterManager.h"

@implementation TwitterManager

@synthesize _twitterAccount;

- (id)init
{
    if(![super init])
    {
        return nil;
    }
    
    // Initialise the account store.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Set the account type to Twitter.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Ask the user for permission to access their Twitter account(s).
    [accountStore requestAccessToAccountsWithType:accountType
                                          options:nil
                                       completion:^(BOOL granted, NSError *error)
    {
        if (granted)
        {
            // Create an array of all the users Twitter accounts.
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            if (accounts.count > 0)
            {
                // To keep it simple, just take the last Twitter account.
                // In the future we should really provide a choice.
                _twitterAccount = [[accounts lastObject] retain];
                
                // Store if we've been granted permission for later.
                _granted = granted;
            }
        }
        else
        {
            NSLog(@"No Twitter access granted");
        }
    }];
    
    return self;
}

- (bool)twitterPermission
{
    return _granted;
}

- (bool)talkToTwitter:(NSObject<TwitterProtocol>*)protocol
{
    __block bool success = FALSE;
    
    // Make 100% sure we've got a Twitter account.
    if ( _twitterAccount != nil )
    {
        // Build the Twitter request.
        SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                           requestMethod:SLRequestMethodGET
                                                                     URL:[protocol getURL]
                                                              parameters:[protocol getParams]];
        
        // Attach the Twitter account for authentication.
        [twitterInfoRequest setAccount:_twitterAccount];
        
        // Actually talk to Twitter.
        [twitterInfoRequest performRequestWithHandler:^(NSData *responseData,
                                                        NSHTTPURLResponse *urlResponse,
                                                        NSError *error)
        {
            // Wait asynchronically so that we don't hold up other important processing. 
            dispatch_async(dispatch_get_main_queue(), ^
            {
                // Ensure we've got some data.
                if ( responseData )
                {
                    // Ensure we've got a valid response.
                    if ( urlResponse.statusCode >= 200 && urlResponse.statusCode < 300 )
                    {
                        // Parse the JSON from the response.
                        NSError *jsonError;
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                                             options:NSJSONReadingAllowFragments
                                                                               error:&jsonError];
                        
                        // Ensure the JSON deserialised correctly.
                        if ( json )
                        {
                            success = [protocol parseResponse:json];
                        }
                        else
                        {
                            // The JSON deserialisation went wrong. Log the error.
                            NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                        }
                    }
                    else
                    {
                        // Twitter was unhappy with us. Log the status code.
                        NSLog(@"The response status code was %d", urlResponse.statusCode);
                    }
                }
            });
        }];
    }
    
    return success;
}

@end