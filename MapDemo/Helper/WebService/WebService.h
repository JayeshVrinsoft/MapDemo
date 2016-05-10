#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol WebServiceDelegate;

@interface WebService : NSObject
{
    id<WebServiceDelegate>_delegate;
  
    
}
@property(nonatomic,strong)id<WebServiceDelegate>_delegate;


-(void)callWebService:(NSString *)urlString dictionarywithdata:(NSDictionary *)dict withType:(NSString *)getPost;
+(WebService*)WebServiceClass;
@end


@protocol WebServiceDelegate <NSObject>

@optional
-(void)webServiceResponce:(NSString*)srtRes;
-(void)webServiceFailure;

@end


