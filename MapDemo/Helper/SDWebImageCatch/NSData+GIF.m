#import "NSData+GIF.h"

@implementation NSData (GIF)

- (BOOL)sd_isGIF
{
    BOOL isGIF = NO;
    
    uint8_t c;
    [self getBytes:&c length:1];
    
    switch (c)
    {
        case 0x47:  
            isGIF = YES;
            break;
        default:
            break;
    }
    
    return isGIF;
}

@end
