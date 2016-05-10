







#import "UIImage+MultiFormat.h"
#import "UIImage+GIF.h"

#ifdef SD_WEBP
#import "UIImage+WebP.h"
#endif

@implementation UIImage (MultiFormat)

+ (UIImage *)sd_imageWithData:(NSData *)data
{
    UIImage *image;

    if ([data sd_isGIF])
    {
        image = [UIImage sd_animatedGIFWithData:data];
    }
    else
    {
        image = [[UIImage alloc] initWithData:data];
    }

#ifdef SD_WEBP
    if (!image) 
    {
        image = [UIImage sd_imageWithWebPData:data];
    }
#endif

    return image;
}

@end
