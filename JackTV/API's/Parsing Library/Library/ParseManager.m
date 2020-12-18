

#import "ParseManager.h"
#import "SBJson.h"
#import "ConstantsList.h"
#import "ApplicationData.h"
#import "SinglePost.h"

@interface NSDictionary (JRAdditions)
- (NSDictionary *) dictionaryByReplacingNullsWithStrings;
@end

@implementation NSDictionary (JRAdditions)

- (NSDictionary *) dictionaryByReplacingNullsWithStrings {
    
    NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary:self];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    
    for(NSString *key in self) {
        const id object = [self objectForKey:key];
        if(object == nul) {
            [replaced setObject:blank forKey:key];
        }
    }
    return [NSDictionary dictionaryWithDictionary:replaced];
}

@end

@implementation ParseManager 

+(id)parseGeneralResponse:(NSString *)jsonContent
{
    NSMutableDictionary *jsonResponse=[jsonContent JSONValue];
    NSLog(@"jsonContent=%@",jsonContent);
    if(jsonResponse) {
        return jsonResponse;
    }
    else
    {
        return nil;
    }
}

+(id)parseLoginResponse:(NSString *)jsonContent
{
    NSMutableDictionary *jsonResponse=[jsonContent JSONValue];
    NSLog(@"jsonContent=%@",jsonContent);
    ApplicationData *appData=[ApplicationData sharedInstance];
    if(jsonResponse)
    {
        appData.aUser = [[User alloc] init];
        
        if([[jsonResponse valueForKey:@"success"] intValue] == jSuccess)
        {
            [appData hideLoader];
            appData.aUser.UserID = [jsonResponse valueForKey:@"userid"];
            appData.aUser.FacebookID = [jsonResponse valueForKey:@"facebookid"];
            appData.aUser.FirstName = [jsonResponse valueForKey:@"firstname"];
            appData.aUser.LastName = [jsonResponse valueForKey:@"lastname"];
            appData.aUser.ProfilePicture = [jsonResponse valueForKey:@"profilepic"];
            appData.aUser.Email = [jsonResponse valueForKey:@"email"];
            appData.aUser.Password = [jsonResponse valueForKey:@"password"];
            appData.aUser.Location = [jsonResponse valueForKey:@"location"];
            appData.aUser.Status = [jsonResponse valueForKey:@"status"];
            return jsonResponse;
        }
        else
        {
            [appData hideLoader];
            [appData ShowAlert:@"Alert" andMessage:[jsonResponse valueForKey:@"msg"]];
            return jsonResponse;
        }
    }
    else
    {
        return nil;
    }
}


+(NSMutableArray *)parseAllPostList:(NSString*)jsonContent
{
    jsonContent=[jsonContent stringByReplacingOccurrencesOfString:@"null" withString:@""];
    NSMutableArray *arrPostList = [[NSMutableArray alloc] init];
    ApplicationData *appData = [ApplicationData sharedInstance];
    NSMutableDictionary *jsonResponse=[jsonContent JSONValue];
    
    appData.totalPages = [[jsonResponse valueForKey:@"totalpage"] integerValue];
    if(jsonResponse)
    {
        if([[jsonResponse valueForKey:@"success"] intValue] == jSuccess)
        {
            NSArray *eventList=[jsonResponse valueForKey:@"data"];
            for(int i=0; i < [eventList count]; i++)
            {
                SinglePost *aSinglePost = [[SinglePost alloc] init];
                NSMutableArray *dictData = [eventList objectAtIndex:i];
                aSinglePost.postid = [dictData valueForKey:@"postid"];
                aSinglePost.title = [dictData valueForKey:@"title"];
                aSinglePost.catid = [dictData valueForKey:@"catid"];
                aSinglePost.category = [dictData valueForKey:@"category"];
                aSinglePost.subcatid = [dictData valueForKey:@"subcatid"];
                aSinglePost.subcategory = [dictData valueForKey:@"subcategory"];
                aSinglePost.image = [dictData valueForKey:@"image"];
                aSinglePost.url = [dictData valueForKey:@"url"];
                aSinglePost.descriptionStr = [dictData valueForKey:@"description"];
                aSinglePost.cr_date = [dictData valueForKey:@"cr_date"];
                aSinglePost.totalpostlikes = [dictData valueForKey:@"totalpostlikes"];
                aSinglePost.isbookmarked = [dictData valueForKey:@"isbookmarked"];
                aSinglePost.isliked = [dictData valueForKey:@"isliked"];
                aSinglePost.kickerline = [dictData valueForKey:@"kickerline"];
                aSinglePost.source = [dictData valueForKey:@"source"];
                
                [arrPostList addObject:aSinglePost];
                NSLog(@"%@",dictData);
            }
        }
        else
        {
            return arrPostList;
        }
    }
    else
    {
        [appData hideLoader];
        [appData ShowAlert:@"Alert" andMessage:@"Invalid Json Response"];
        return nil;
    }
    return arrPostList;
}

@end

