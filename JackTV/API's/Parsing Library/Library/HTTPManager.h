
#import <Foundation/Foundation.h>
#import "ConstantsList.h"
#import <UIKit/UIKit.h>


@protocol HTTPManagerDelegate;

@interface HTTPManager : NSObject {
	
    NSURLConnection *theConnection;
	NSMutableData *receiveData;
	CGFloat totalSize;
    HTTPRequest requestType;
    id <HTTPManagerDelegate>delegate;
    id extraInfo;
    
    NSString *URL;
    NSString *postString;
      
    UIImage *downloadedImage;
    NSString *responseString;
    
    BOOL isReqForImage;
    
}

@property (nonatomic, retain)id <HTTPManagerDelegate> delegate;
@property (nonatomic, assign)CGFloat totalSize;
@property(nonatomic) HTTPRequest requestType;
@property (nonatomic,retain) NSString *URL;
@property (nonatomic,retain) NSString *postString;
@property (nonatomic,retain)  id extraInfo;
@property(nonatomic, readonly) UIImage *downloadedImage;
@property(nonatomic, readonly) NSString *responseString;


+(id)managerWithURL:(NSString*)strURL delegate:(id<HTTPManagerDelegate>)del;
-(void)StartUploadPostData:(NSData *)postContent Boundry:(NSString *)contentBoundry;
-(void)cancelConnection;
-(void)startImageDownload;
-(void)startDownload;
@end

@protocol HTTPManagerDelegate <NSObject>
@optional
-(void)HttpManger:(HTTPManager*)manger DownloadedWith:(id)response;
-(void)HttpManger:(HTTPManager*)manger DownloadedWithImage:(UIImage*)image;
-(void)HttpManger:(HTTPManager*)manger FailedWithError:(ErrorCode)errorcode;


@end


