

#import "HTTPManager.h"
#import "ParseManager.h"
#import "ApplicationData.h"


@implementation HTTPManager

@synthesize delegate;
@synthesize totalSize;
@synthesize URL;
@synthesize postString;
@synthesize downloadedImage;
@synthesize responseString;
@synthesize requestType;
@synthesize extraInfo;

+(id)managerWithURL:(NSString*)strURL delegate:(id<HTTPManagerDelegate>)del
{
    HTTPManager *manager =[[HTTPManager alloc] init];
    manager.URL = [strURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    manager.delegate=del;
    return manager;
}

//download image
-(void)startImageDownload
{
    ApplicationData *appData=[ApplicationData sharedInstance];
    if([appData connectedToNetwork])
    {
        isReqForImage =TRUE;
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
        if ([NSURLConnection canHandleRequest:request]) {
            theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [theConnection start];
        }
    }
}

//get string data
-(void)startDownload
{
    isReqForImage =FALSE;
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0 ];
	
	[theRequest addValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[theRequest setHTTPMethod:@"POST"];
    if(postString.length)
    {
        NSMutableData *oHttpBody = [NSMutableData data];
        [oHttpBody appendData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[oHttpBody length]];
        [theRequest addValue:postLength forHTTPHeaderField:@"Content-Length"];
        [theRequest setHTTPBody:oHttpBody];
    }
	theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	[theConnection start];
}

-(void)StartUploadPostData:(NSData *)postContent Boundry:(NSString *)contentBoundry
{
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0 ];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:postContent];
	[theRequest addValue:contentBoundry forHTTPHeaderField: @"Content-Type"];
    theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	[theConnection start];
}

#pragma mark -
#pragma mark NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	receiveData = [[NSMutableData alloc] init];
	self.totalSize=[response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (isReqForImage) {
        downloadedImage = [[UIImage alloc]initWithData:receiveData];  
        if([self.delegate respondsToSelector:@selector(HttpManger:DownloadedWithImage:)])
        {
            [self.delegate HttpManger:self DownloadedWithImage:downloadedImage];
        }
        
    } else {
        
        responseString = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
        
        if([self.delegate respondsToSelector:@selector(HttpManger:DownloadedWith:)])
        {
            id returnValue=responseString;
            switch (requestType) {
                case jLoginQuery:
                    returnValue=[ParseManager parseLoginResponse:responseString];
                    break;
                case jGeneralQuery:
                    returnValue = [ParseManager parseGeneralResponse:responseString];
                    break;
                case jAllPostList:
                    returnValue = [ParseManager parseAllPostList:responseString];
                    break;
                case jForgotPassword:
                    returnValue = [ParseManager parseGeneralResponse:responseString];
                    break;
                case jSelectCategory:
                    returnValue = [ParseManager parseGeneralResponse:responseString];
                    break;
                default:
                    break;
            }
            if(returnValue == nil) // Invalid Response or Error 
            {
                if([self.delegate respondsToSelector:@selector(HttpManger:FailedWithError:)])
                {
                    [self.delegate HttpManger:self FailedWithError:jInvalidResponse];
                }
            }
            else
            {
                [self.delegate HttpManger:self DownloadedWith:returnValue];
            }
        }
    }
	
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   if([self.delegate respondsToSelector:@selector(HttpManger:FailedWithError:)])
    {
        [self.delegate HttpManger:self FailedWithError:jServerError];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	float progress = [[NSNumber numberWithInteger:totalBytesWritten] floatValue];
	float total = [[NSNumber numberWithInteger: totalBytesExpectedToWrite] floatValue];
    
    NSLog(@"Bytes Uploaded Total = %f/ Progress = %f ",total,progress);
    
    
}

-(void)cancelConnection
{    
    [theConnection cancel];
}

@end
