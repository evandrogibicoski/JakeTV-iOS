

#import <Foundation/Foundation.h>

@interface ParseManager :NSObject 
{
    
}
+(id)parseGeneralResponse:(NSString *)jsonContent;
+(id)parseLoginResponse:(NSString *)jsonContent;
+(NSMutableArray *)parseAllPostList:(NSString*)jsonContent;
@end
