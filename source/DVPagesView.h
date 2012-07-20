//
//  DVPagesView.h
//  DVGallery
//
//  Created by Dmitry Ponomarev on 6/22/12.
//  Copyright (c) 2012 MySelf. All rights reserved.
//

#import <UIKit/UIKit.h>

enum { DVPAGES_PAGE_TAG = 231883 };

@class DVPagesView;

@protocol DVPagesDelegate <NSObject>

- (NSInteger)pageGetCount:(DVPagesView*)pageView;

@optional
- (UIView*)pageGetView:(DVPagesView*)pageView page:(NSInteger)page view:(UIView*)view;
- (CGSize)pageGetSize:(DVPagesView*)pageView page:(NSInteger)page view:(UIView*)view;

// Events ...
- (void)pageChange:(DVPagesView*)pageView oldPage:(NSInteger)oldPage newPage:(NSInteger)page duration:(NSTimeInterval)duration;

@end

@interface DVPagesView : UIView {
    NSInteger _currentPage;
    CGPoint _startMovePoint;
    CGPoint _startMovePosition;
    
    UIView *_scrollerView;
    NSMutableDictionary *_pages;

    UIControlContentHorizontalAlignment _pageHorizontalAlignment;
    UIControlContentVerticalAlignment _pageVerticalAlignment;
    
    BOOL _flagInvertPageSize;
}

@property (nonatomic, assign) id<DVPagesDelegate> delegate;

//
// Params
//
- (NSInteger)pageGetCount;
- (UIView*)pageGetView:(NSInteger)page;
- (UIView*)pageGetView:(NSInteger)page created:(BOOL)created;
- (CGSize)pageGetSize:(NSInteger)page;
- (CGPoint)pageGetPosition:(NSInteger)page;
- (NSInteger)pageGetCurrentIndex;
- (BOOL)isInvertPage;

//
// Actions
//
- (void)reinitPages;
- (void)reinitPages:(BOOL)savePosition;
- (void)reinitPages:(BOOL)savePosition releace:(BOOL)releace invert:(BOOL)invert;
- (void)initPage:(NSInteger)page;
- (void)initPage:(NSInteger)page reinit:(BOOL)reinit;
- (void)moveToPage:(NSInteger)page duration:(NSTimeInterval)duration;
- (void)moveToPage:(NSInteger)page;

@end
