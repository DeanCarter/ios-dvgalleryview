Grid gallery iOS control
========================

Copyright 2012 Ponomarev Dmitry <demdxx@gmail.com> MIT

![Examples](https://github.com/demdxx/ios-dvgalleryview/raw/master/screenshot.png)

DVPageView
----------

A simplified alternative to the standard page component **UIPageView**.
The component forms a grid, the presence of pages **UIView** is not mandatory.

```ObjectiveC
- (void)viewDidLoad
{
    [super viewDidLoad];

    DVPageView *pages = [[DVPageView alloc] initWithFrame:[self frame]];
    pages.delegate = self;
    
    [self addSubview:pages];
}

#pragma mark -
#pragma mark Pages delegate

- (NSInteger)pageGetCount:(DVPagesView*)page {
    return <count>;
}

- (UIView*)pageGetView:(DVPagesView*)pageView page:(NSInteger)page view:(UIView *)view {
    return nil;
}

- (void)pageChange:(DVPagesView*)pageView oldPage:(NSInteger)oldPage newPage:(NSInteger)page duration:(NSTimeInterval)duration {
    // ...
}

- (void)galleryCellTapped:(DVGalleryView*)gallery view:(UIView*)view {
    // ...
}
```

DVGalleryView
-------------

Extending the Class **DVPageView** adds to the page grid with **UIView**.

```ObjectiveC
#pragma mark -
#pragma mark Gallery delegate

- (NSInteger)galleryItemsCount:(DVGalleryView*)gallery page:(NSInteger)page {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 18 : 8;
}

- (UIView*)galleryItem:(DVGalleryView*)gallery view:(UIView*)view page:(NSInteger)page index:(NSInteger)index {
    if (nil==view) {
        NSString *imgName = [NSString stringWithFormat:@"gPic%d", 1+(index%4)];
        NSString *imgPath = [[NSBundle mainBundle] pathForResource:imgName ofType:@"jpg"];
        view = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imgPath]];
    }
    return view;
}

- (CGSize)galleryCellSize:(DVGalleryView*)gallery view:(UIView*)view page:(NSInteger)page index:(NSInteger)index {
    return index>=0 ? [view frame].size : CGSizeMake(120, 120);
}


- (void)galleryCellTapped:(DVGalleryView*)gallery view:(UIView*)view {
    // ...
}
```
