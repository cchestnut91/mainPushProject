//
//  RESTfulInterface.m
//  pushRestAPI
//
//  Created by Andrew Sowers on 6/30/14.
//  Copyright (c) 2014 Andrew Sowers. All rights reserved.
//

#import "RESTfulInterface.h"

@implementation RESTfulInterface

#pragma mark - singleton

+(instancetype)RESTAPI
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance =[[self alloc] init];
    });
    return _sharedInstance;
}

-(instancetype)init
{
    if (self == [super init]){
        return self;
    }
    return nil;
}

#pragma mark - RESTful data interface with GET calls

-(NSDictionary *)getBeaconCredsFromUUID:(NSString*)uuid
{
    NSString *urlString = [NSString stringWithFormat:@"http://experiencepush.com/csp_portal/rest/?uuid=%@&call=getBeacon&PUSH_ID=123",uuid];
    NSData * data = [self synchronousRequestWithStringGET:urlString];
    if (data!=nil) {
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if(error){
            NSLog(@"error");
            return nil;
        }
        return json;
    }
    return nil;
}

-(NSArray*)getUserFavorites:(NSString *)uuid
{
    NSString *urlString = [NSString stringWithFormat:@"http://experiencepush.com/csp_portal/rest/?uuid=%@&call=getUserFavorites&PUSH_ID=123",uuid];
    NSData * data = [self synchronousRequestWithStringGET:urlString];
    if (data!=nil) {
        NSError *error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            NSLog(@"error");
            return nil;
        }
        return jsonArray;
    }
    return nil;
}

-(NSArray *)getAllBeacons
{
    NSString *urlString = [NSString stringWithFormat:@"http://experiencepush.com/csp_portal/rest/?PUSH_ID=123&call=getAllBeacons"];
    
    NSData * data = [self synchronousRequestWithStringGET:urlString];
    if (data!=nil) {
        
        NSError *error;
        
        //Receive multi-dimentisonal array
        //Inner array
        //ID, EnglishID, UUID, Major, Minor
        
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            return nil;
        }
        return json;
    }
    return nil;
}

-(NSArray *)getAllListings
{
    
    NSString *urlString = [NSString stringWithFormat:@"http://experiencepush.com/csp_portal/rest/?PUSH_ID=123&call=getAllListings"];
    
    NSData * data = [self synchronousRequestWithStringGET:urlString];
    if (data!=nil) {
        
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
        
        if (e) {
            return nil;
        }
        return jsonArray;
    }
    return nil;
}

-(NSArray*)getCampaignHasBeacon
{
    NSString *urlString = [NSString stringWithFormat:@"http://experiencepush.com/csp_portal/rest/index.php?PUSH_ID=123&call=getCampaignHasBeacon"];
    
    NSData * data = [self synchronousRequestWithStringGET:urlString];
    if (data!=nil) {
        
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
        
        if (e) {
            return nil;
        }
        return jsonArray;
    }
    return nil;
}

#pragma mark - RESTful data interface with POST calls

-(BOOL)addUserFavorite: (NSString*)uuid :(NSString*)favorite_id
{
    NSString *urlString = @"http://experiencepush.com/csp_portal/rest/index.php";
    NSString *urlVariables = [NSString stringWithFormat:@"PUSH_ID=123&call=addUserFavorite&uuid=%@&favorite_id=%@",uuid,favorite_id];
    NSData * data = [self synchronousRequestWithStringPOST:urlString :urlVariables];
    if (data!=nil) {
        NSString *content = [NSString stringWithUTF8String:[data bytes]];
        if ([content isEqualToString:@"0"]||[content isEqualToString:@"-1"]) {
            return false;
        }
        return true;
    }
    return false;
}

-(BOOL)removeUserFavorite: (NSString*)uuid :(NSString*)favorite_id
{
    NSString *urlString =@"http://experiencepush.com/csp_portal/rest/index.php";
    NSString *urlVariables = [NSString stringWithFormat:@"PUSH_ID=123&call=removeUserFavorite&uuid=%@&favorite_id=%@",uuid,favorite_id];
    NSData * data = [self synchronousRequestWithStringPOST:urlString :urlVariables];
    if (data!=nil) {
        NSString *content = [NSString stringWithUTF8String:[data bytes]];
        if ([content isEqualToString:@"0"]||[content isEqualToString:@"-1"]) {
            return false;
        }
        return true;
    }
    return false;
}

-(BOOL)registerTriggeredBeaconAction: (NSString*)campaign_id :(NSString*)action_type :(BOOL)clicked :(NSString*)userUUID
{
    NSString *urlString =@"http://experiencepush.com/csp_portal/rest/index.php";
    NSString *urlVariables = [NSString stringWithFormat:@"PUSH_ID=123&call=registerTriggeredBeaconAction&campaign_id=%@&action_type=%@&clicked=%d&uuid=%@",campaign_id,action_type,clicked,userUUID];
    NSData * data = [self synchronousRequestWithStringPOST:urlString :urlVariables];
    if (data!=nil) {
        NSString *content = [NSString stringWithUTF8String:[data bytes]];
        if ([content isEqualToString:@"0"]||[content isEqualToString:@"-1"]) {
            return false;
        }
        return true;
    }
    return false;
}

-(NSString*)addNewAnonUser:(NSString *)uuid
{
    NSString *urlString =@"http://experiencepush.com/csp_portal/rest/index.php";
    NSString *urlVariables = [NSString stringWithFormat:@"PUSH_ID=123&call=addNewAnonUser&uuid=%@",uuid];
    NSData * data = [self synchronousRequestWithStringPOST:urlString :urlVariables];
    if (data!=nil) {
        return [NSString stringWithUTF8String:[data bytes]];
    }
    return @"0";
}
#pragma mark - NSURLConnection synchronous methods

-(NSData*)synchronousRequestWithStringGET:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue: @"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    NSURLResponse* response;
    NSError* error;
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error){
        NSLog(@"%@",error);
        return nil;
    }
    return data;
}

-(NSData*)synchronousRequestWithStringPOST:(NSString *)urlString :(NSString*)urlVariableString
{
    NSString *myRequestString = urlVariableString;
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: urlString ] ];
    [request setHTTPMethod: @"POST" ];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody: myRequestData ];
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
    return returnData;
}


#pragma mark - NSURLConnection asynchronous delegates

-(void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *)response
{
    // Discard all previously received data.
    [mutableData setLength:0];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // add new data
    [mutableData appendData:data];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    // If we get any connection error we can manage it here…
    return;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // in the form of JSON
    HTTPResponse = [[NSString alloc] initWithData: mutableData encoding:NSUTF8StringEncoding];
}
@end

