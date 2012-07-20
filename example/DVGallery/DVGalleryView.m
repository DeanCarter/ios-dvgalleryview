//
//  DVGalleryView2.m
//  DVGallery
//
//  Created by Dmitry Ponomarev on 6/29/12.
//  Copyright (c) 2012 MySelf. All rights reserved.
//

#import "DVGalleryView.h"

@implementation DVGalleryView

@dynamic delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _cells = [[NSMutableDictionary alloc] init];
        memset(&_flags, 0, sizeof(_flags));
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)frame
{
    self = [super initWithCoder:frame];
    if (self) {
        _cells = [[NSMutableDictionary alloc] init];
        memset(&_flags, 0, sizeof(_flags));
    }
    return self;
}

// Get/set delegate

- (void)setDelegate:(id<DVGalleryDelegate>) delegate {
    [super setDelegate: (id)delegate];
}

- (id)delegate {
    return [super delegate];
}

#pragma mark -
#pragma mark Parameters

/**
 * Get cell view position
 * @param page index
 * @param cell index
 * @return point {x, y}
 */
- (CGPoint)cellPosition:(NSInteger)page index:(NSInteger)index {
    // Get by delegate if exists
    if ([[self delegate] respondsToSelector:@selector(galleryCellPosition:view:page:index:)]) {
        UIView *cell = [self cellView:page index:index];
        return [[self delegate] galleryCellPosition:self view:cell page:page index:index];
    }

    // Callculate item position
    CGSize cellSize = [self cellSize:page index:-1];
    NSInteger itemsCount = [self itemsPageCount:page];
    NSInteger columnsCount = [self columnsCount:page];
    NSInteger rowsCount = ceil(((CGFloat)itemsCount) / columnsCount);
    
    CGSize pageSize = [self pageGetSize:page];
    
    // Calculate space
    CGFloat colSpace = (pageSize.width-cellSize.width*columnsCount)
                     / (columnsCount+1);
    CGFloat rowSpace = (pageSize.height-cellSize.height*rowsCount)
                     / (rowsCount+1);

    // Calculate real grid size
    if (colSpace<rowSpace && columnsCount>1 && ![[self delegate] respondsToSelector:@selector(galleryColumnsCount:)]) {
    
        while (colSpace<rowSpace && columnsCount>1) {
            columnsCount--;
            rowsCount = ceil(((CGFloat)itemsCount) / columnsCount);

            colSpace = (pageSize.width-cellSize.width*columnsCount)
                     / (columnsCount+1);
            rowSpace = (pageSize.height-cellSize.height*rowsCount)
                     / (rowsCount+1);
        }
    }

    // Calculate greed position
    NSInteger rowIndex = index / columnsCount;
    NSInteger colIndex = index % columnsCount;

    // Fisic position
    CGPoint pos = CGPointMake(colIndex*(colSpace+cellSize.width)+colSpace,
                       rowIndex*(rowSpace+cellSize.height)+rowSpace);

    // Correct position
    if (_flags.correctCellPosition) {
        CGSize oSize = [self cellSize:page index:index];
        if (oSize.width!=cellSize.width) {
            pos.x += (cellSize.width-oSize.width)/2;
        }
        if (oSize.height!=cellSize.height) {
            pos.y += (cellSize.height-oSize.height)/2;
        }
    }
    return pos;
}

/**
 * Get and correct cell view size
 * @param page index
 * @param cell index
 * @return size {width, height}
 */
- (CGSize)cellSize:(NSInteger)page index:(NSInteger)index {
    if ([[self delegate] respondsToSelector:@selector(galleryCellSize:view:page:index:)]) {
        UIView *cell = [self cellView:page index:index];
        CGSize size = [[self delegate] galleryCellSize:self view:cell page:page index:index];
        // Correct image size
        if (_flags.correctCellMetrics) {
            CGSize base = [[self delegate] galleryCellSize:self view:cell page:page index:-1];
            if (size.height>base.height) {
                size.width *= base.height/size.height;
                size.height = base.height;
            }
            if (size.width>base.width) {
                size.height *= base.width/size.width;
                size.width = base.width;
            }
        }
        return size;
    }
    return CGSizeMake(60, 60);
}

/**
 * Get or reinit cell view
 * @param page index
 * @param index
 * @return view
 */
- (UIView*)cellView:(NSInteger)page index:(NSInteger)index {
    UIView *cell = nil, *cell2 = nil;
    
    // Generate key
    NSString *key = [NSString stringWithFormat:@"%d.%d", page, index];
    
    // Get old view
    cell = [_cells objectForKey:key];
    
    // Get new view or old or nil (:
    cell2 = [[self delegate] galleryItem:self view:cell page:page index:index];
    
    if (nil!=cell2 && cell2!=cell) {
        if (nil!=cell) {
            [cell removeFromSuperview];
        }
        cell = cell2;
        
        [cell setUserInteractionEnabled:YES];
        
        // Set tap event
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellViewTapped:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [cell addGestureRecognizer:tap];
        
        // Add key
        [cell setTag:DVGALLERY_CELL_TAG];
        
        // Add to heap
        [_cells setValue:cell forKey:key];
    }

    return cell;
}

/**
 * Get page count items
 * @param page index
 * @return count
 */
- (NSInteger)itemsPageCount:(NSInteger)page {
    if ([[self delegate] respondsToSelector:@selector(galleryItemsCount:page:)])
        return [[self delegate] galleryItemsCount:self page:page];
    return 6;
}

/**
 * Get gallery column count
 * @param page index
 * @return count
 */
- (NSInteger)columnsCount:(NSInteger)page {
    if ([[self delegate] respondsToSelector:@selector(galleryColumnsCount:)])
        return [[self delegate] galleryColumnsCount:self];
    return floor([self pageGetSize:page].width / [self cellSize:page index:0].width);
}

#pragma mark -
#pragma mark Flags

- (void)setCorrectCellPosition:(BOOL)flag {
    _flags.correctCellPosition = flag ? 1 : 0;
}

- (void)setCorrectCellMetrics:(BOOL)flag {
    _flags.correctCellMetrics = flag ? 1 : 0;
}

#pragma mark -
#pragma mark Actions

/**
 * Init current page
 * @param page
 */
- (void)initPage:(NSInteger)page {
    [super initPage:page];

    CGRect frame = CGRectNull;
    CGPoint pageOffset = [self pageGetPosition:page];

    for (int i=0;i<[self itemsPageCount:page];i++) {
        UIView *v = [self cellView:page index:i];
        if (nil==v) {
            [NSException raise:@"Invalid cell item..." format:@"Invalid cell[%d] on page[%d]", i, page];
            continue;
        }

        frame.origin = [self cellPosition:page index:i];
        frame.origin.x += pageOffset.x;
        frame.origin.y += pageOffset.y;
        frame.size = [self cellSize:page index:i];
        [v setFrame:frame];
        [_scrollerView addSubview:v];
        [_scrollerView bringSubviewToFront:v];
    }
}

/**
 * reinit gallery
 * @param replace created pages
 * @param inver current page size
 */
- (void)reinitGallery:(BOOL)replace invert:(BOOL)invert {
    if (replace) {
        for (UIView *v in [_cells allValues])
            [v removeFromSuperview];
        [_cells removeAllObjects];
    }
    [super reinitPages:YES releace:replace invert:invert];
}

/**
 * reinit gallery
 */
- (void)reinitGallery {
    [self reinitGallery:NO invert:NO];
}

#pragma mark -
#pragma mark Events

/**
 * Tap event to cell
 */
- (void)cellViewTapped:(UITapGestureRecognizer *)gr {
    if ([[self delegate] respondsToSelector:@selector(galleryCellTapped:view:)])
        [[self delegate] galleryCellTapped:self view:gr.view];
}

@end
