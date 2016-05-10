
#import "AFHTTPRequestOperationManager.h"
#import "WebService.h"

@implementation WebService
@synthesize _delegate;

#pragma mark
#pragma mark Webservice
#pragma mark

+(WebService*)WebServiceClass
{
    WebService *webUrlObject;
    if (webUrlObject==nil) {
        
        webUrlObject=[[WebService alloc] init];
        
    }
    
    return webUrlObject;
}

-(void)callWebService:(NSString *)urlString dictionarywithdata:(NSDictionary *)dict withType:(NSString *)getPost
{
    
    AFHTTPRequestOperationManager *manager1 = [AFHTTPRequestOperationManager manager];
    manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *params = dict;
   
    
    if ([getPost isEqualToString:@"post"])
    {
        [manager1 POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             
             
             
             NSString *returnString=[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSString *returnString1=[returnString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
             returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&amp" withString:@"&"];
             returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
             
             returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&#034;" withString:@"\""];
             
             
             if ([_delegate respondsToSelector:@selector(webServiceResponce:)])
             {
                 [_delegate webServiceResponce:returnString1];
             }
             
             
         }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             
             [_delegate webServiceFailure];
         }];
    }
    else
    {
        
        
        [manager1 GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             
             
             
             NSString *returnString=[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSString *returnString1=[returnString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
             returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&amp" withString:@"&"];
             returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
             
             returnString1=[returnString1 stringByReplacingOccurrencesOfString:@"&#034;" withString:@"\""];
             
             
             if ([_delegate respondsToSelector:@selector(webServiceResponce:)])
             {
                 [_delegate webServiceResponce:returnString1];
             }
         }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"%@",error);
             [_delegate webServiceFailure];
         }];
    }
}

@end
