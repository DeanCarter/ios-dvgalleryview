//
//  DVGalleryView.h
//  DVGallery
//
//  Created by Dmitry Ponomarev on 6/29/12.
//  Copyright (c) 2012 MySelf. All rights reserved.
//

#import "DVPagesView.h"

enum { DVGALLERY_CELL_TAG = DVPAGES_PAGE_TAG+1 };

@class DVGalleryView;

@protocol DVGalleryDelegate<NSObject, DVPagesDelegate>

- (NSInteger)galleryItemsCount:(DVGalleryView*)gallery page:(NSInteger)page;
- (UIView*)galleryItem:(DVGalleryView*)gallery view:(UIView*)view page:(NSInteger)page index:(NSInteger)index;

@optional
- (CGPoint)galleryCellPosition:(DVGalleryView*)gallery view:(UIView*)view page:(NSInteger)page index:(NSInteger)index;
- (CGSize)galleryCellSize:(DVGalleryView*)gallery view:(UIView*)view page:(NSInteger)page index:(NSInteger)index;
- (NSInteger)galleryColumnsCount:(DVGalleryView*)gallery;

// Events
- (void)galleryCellTapped:(DVGalleryView*)gallery view:(UIView*)view;

@end

@interface DVGalleryView : DVPagesView {
    struct {
        unsigned int correctCellPosition:1;
        unsigned int correctCellMetrics:1;
    } _flags;

    NSMutableDictionary* _cells;
}

@property (nonatomic, assign) id<DVGalleryDelegate> delegate;

//
// Parameters
//

- (CGPoint)cellPosition:(NSInteger)page index:(NSInteger)index;
- (CGSize)cellSize:(NSInteger)page index:(NSInteger)index;
- (UIView*)cellView:(NSInteger)page index:(NSInteger)index;
- (NSInteger)itemsPageCount:(NSInteger)page;
- (NSInteger)columnsCount:(NSInteger)page;

//
// Flags
//
- (void)setCorrectCellPosition:(BOOL)flag;
- (void)setCorrectCellMetrics:(BOOL)flag;

//
// Actions
//

- (void)reinitGallery;
- (void)reinitGallery:(BOOL)replace invert:(BOOL)invert;

//
// Events
//
- (void)cellViewTapped:(UITapGestureRecognizer *)gr;

@end
