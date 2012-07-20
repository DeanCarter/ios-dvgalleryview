//
//  DVViewController.h
//  DVGallery
//
//  Created by Dmitry Ponomarev on 6/20/12.
//  Copyright (c) 2012 MySelf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVGalleryView.h"

@interface DVViewController : UIViewController<DVGalleryDelegate>

@property (weak, nonatomic) IBOutlet DVGalleryView *gallery;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundScreen;

@end
