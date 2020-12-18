
#define SERVER_ADDRESS      @"http://jaketv.tv/jaketv/jaketv_webservice/service.php?"
//#define SERVER_ADDRESS      @"jake:jake@staging.jaketv.tv/jaketv/jaketv_webservice/service.php?"

#define EMAILCHIMP_ADDRESS  @"http://jaketv.tv/emails.php?"

#define IMAGE_ADDRESS @"http://54.148.31.176/uphere/gridfs.php?"

#define APPLINK @"https://itunes.apple.com/us/app/hotmix-99/id981845608?ls=1&mt=8"
#define ADKEY @"ca-app-pub-9523887351309576/2547753649"

#define GENERAL_TIME_FORMAT				@"HH:mm:ss"
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

typedef enum{
    
    jGeneralQuery,
    jLoginQuery,
    jAllPostList,
    jForgotPassword,
    jSelectCategory,
    
    jMailChimp,
    
    jMarksList,
    jMarksPostList,
    
    jAd,
    
} HTTPRequest;

typedef enum {
    
	jServerError = 0,
	jSuccess,
    jInvalidResponse,
    jNetworkError,
    jFailResponse,
   
}ErrorCode;



