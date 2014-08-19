//
//  RESTfulInterface.h
//  pushRestAPI
//
//  Created by Andrew Sowers on 6/30/14.
//  Copyright (c) 2014 Andrew Sowers. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RESTfulInterface : NSObject <NSURLConnectionDataDelegate>{
    NSMutableData *mutableData;
    NSString *HTTPResponse;
}

#pragma mark - singleton
/**
 *  Creates a singleton object for use of NSURL utilities that connect to the Push Interactive REST API
 *
 *  @return RESTAPI
 */
+(instancetype)RESTAPI;
-(NSDictionary*)getBeaconCredsFromUUID:(NSString*)uuid;
-(NSArray*)getUserFavorites:(NSString*)uuid;
-(BOOL)addUserFavorite:(NSString*)uuid :(NSString*)favorite_id;
-(BOOL)removeUserFavorite:(NSString*)uuid :(NSString*)favorite_id;
-(BOOL)registerTriggeredBeaconAction: (NSString*)campaign_id :(NSString*)action_type :(BOOL)clicked :(NSString*)userUUID;
-(NSString*)addNewAnonUser:(NSString*)uuid;
-(NSArray*)getAllBeacons;
-(NSArray*)getAllListings;
-(NSArray*)getCampaignHasBeacon;
//-(NSData*)synchronousRequestWithString:(NSString*)urlString; // may not be needed as public mehtod

@end
