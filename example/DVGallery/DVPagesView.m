//
//  DVPagesView.m
//  DVGallery
//
//  Created by Dmitry Ponomarev on 6/22/12.
//  Copyright (c) 2012 MySelf. All rights reserved.
//

#import "DVPagesView.h"

@implementation DVPagesView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentPage = -1;
        _pageHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _pageVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _scrollerView = nil;
        _pages = nil;
        _flagInvertPageSize = NO;
        [self reinitPages];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)frame
{
    self = [super initWithCoder:frame];
    if (self) {
        _currentPage = -1;
        _pageHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _pageVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _scrollerView = nil;
        _pages = nil;
        _flagInvertPageSize = NO;
        [self reinitPages];
    }
    return self;
}

#pragma mark -
#pragma mark Params

/**
 * Page count
 * @param count
 */
- (NSInteger)pageGetCount {
    return [delegate pageGetCount:self];
}

/**
 * Get page view at index
 * @param page index
 * @return UIView
 */
- (UIView*)pageGetView:(NSInteger)page {
    return [self pageGetView:page created:NO];
}

/**
 * Get page view
 * @param page index
 * @param created 
 * @return UIView
 */
- (UIView*)pageGetView:(NSInteger)page created:(BOOL)created {
    UIView *p = nil;
    NSString *key = [NSString stringWithFormat:@"%d", page];
    if ([_pages count]>page) {
        p = [_pages objectForKey:key];
        if (created && p)
            return p;
    }
    if ([delegate respondsToSelector:@selector(pageGetView:page:view:)]) {
        UIView* pg = [delegate pageGetView:self page:page view:p];
        if (pg!=p) {
            [p removeFromSuperview];
            [_pages setValue:pg forKey:key];
        }
        return pg;
    }
    return nil;
}

/**
 * Get page size at index
 * @param page index
 * @return size {width, height}
 */
- (CGSize)pageGetSize:(NSInteger)page {
    CGSize size = [self frame].size;

    if (_pageVerticalAlignment==UIControlContentVerticalAlignmentFill &&
        _pageHorizontalAlignment==UIControlContentHorizontalAlignmentFill) {
        // ...
    }
    else if ([delegate respondsToSelector:@selector(pageGetSize:page:view:)]) {
        UIView *p = [_pages objectForKey:[NSString stringWithFormat:@"%d", page]];
        size = [delegate pageGetSize:self page:page view:p];
    }
    
    if (_flagInvertPageSize) {
        CGSize sbsize = [[UIApplication sharedApplication] statusBarFrame].size;
        size = sbsize.width>sbsize.height
             ? CGSizeMake(size.height+sbsize.height, size.width)
             : CGSizeMake(size.height+sbsize.width, size.width);
    }

    return size;
}

/**
 * Get page position at index
 * @param page
 * @return point {x, y}
 */
- (CGPoint)pageGetPosition:(NSInteger)page {
    if ((_pageVerticalAlignment==UIControlContentVerticalAlignmentFill &&
         _pageHorizontalAlignment==UIControlContentHorizontalAlignmentFill) ||
        (_pageVerticalAlignment==UIControlContentVerticalAlignmentTop &&
         _pageHorizontalAlignment==UIControlContentHorizontalAlignmentLeft))
        return CGPointMake(0, 0);

    CGPoint position = CGPointMake(0, 0);
    for (int i=0;i<page;i++)
        position.x += [self pageGetSize:i].width;

    if (_pageVerticalAlignment!=UIControlContentVerticalAlignmentTop &&
        _pageVerticalAlignment!=UIControlContentVerticalAlignmentFill) {
        CGSize size = [self pageGetSize:page];
        
        if ([self isInvertPage]) {
            if (size.height!=[self frame].size.width) {
                position.y = [self frame].size.width - size.height;
                if (_pageVerticalAlignment==UIControlContentVerticalAlignmentCenter) {
                    position.y /= 2;
                }
            }
        }
        else {
            if (size.height!=[self frame].size.height) {
                position.y = [self frame].size.height - size.height;
                if (_pageVerticalAlignment==UIControlContentVerticalAlignmentCenter) {
                    position.y /= 2;
                }
            }
        }
    }

    return position;
}

/**
 * Get current page index from coords
 * @return index
 */
- (NSInteger)pageGetCurrentIndex {
    if (nil==_scrollerView)
        return -1;

    CGFloat offset          = 0,
            curOffset       = -[_scrollerView frame].origin.x,
            curOffsetRight  = curOffset+[self frame].size.width,
            curWidth        = 0.f;
    
    NSInteger current = -1;

    for (int i=0;i<[self pageGetCount];i++) {
        CGSize size = [self pageGetSize:i];
        if (
            (
                offset<=curOffset &&
                offset+size.width>=curOffset &&
                offset+size.width-curOffset>=size.width/2
            )
         || (
                offset>curOffset &&
                offset+size.width>=curOffsetRight &&
                offset+size.width-curOffsetRight<size.width/2
            )
        ) {
            CGFloat w = offset-curOffset+size.width;
            if (w>size.width) w = curOffsetRight-offset;

            if (current!=-1 && curWidth>w)
                return current;
            curWidth = w;
            current = i;
        }
        else if(current!=-1 || curOffset<0) {
            return MAX(current,0);
        }
        offset += size.width;
    }
    return [self pageGetCount]-1;
}


- (BOOL)isInvertPage {
    return _flagInvertPageSize;
}


#pragma mark -
#pragma mark Touch events

/*
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // tview is the UITableView subclass instance
    //CGPoint tViewHit = [tView convertPoint:point fromView:self];        
    //if ([tView pointInside:tViewHit withEvent:event]) return tView;

    return [super hitTest:point withEvent:event];
}*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _startMovePoint = [touch locationInView:self];
    _startMovePosition = [_scrollerView frame].origin;

    // view is the UIView's subclass instance
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];    
    CGPoint touchLocation = [touch locationInView:self];

    CGRect frame = [_scrollerView frame];
    if (_startMovePoint.x!=touchLocation.x) {
        if (_startMovePoint.x>touchLocation.x) {
            frame.origin.x = _startMovePosition.x
                           -(_startMovePoint.x-touchLocation.x)+
                            (frame.origin.x+frame.size.width<[self frame].size.width ?
                                sqrt(_startMovePoint.x-touchLocation.x)
                                *log(_startMovePoint.x-touchLocation.x) : 0);
        }
        else {
            frame.origin.x = _startMovePosition.x
                           -(_startMovePoint.x-touchLocation.x)-
                            (frame.origin.x>0 ?
                                sqrt(touchLocation.x-_startMovePoint.x)
                                *log(touchLocation.x-_startMovePoint.x) : 0);
        }
        [_scrollerView setFrame:frame];
    }
    
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self moveToPage:[self pageGetCurrentIndex]];
    return [super touchesEnded:touches withEvent:event];
}

#pragma mark -
#pragma mark Actions

/**
 * Reinit page initialize
 * @param savePosition current page
 * @param relsece current viewes
 * @param invert page size
 */
- (void)reinitPages:(BOOL)savePosition releace:(BOOL)releace invert:(BOOL)invert {

    if (invert)
        _flagInvertPageSize = YES;

    int _curPage = savePosition ? _currentPage : -1;
    _currentPage = -1;

    CGRect rect = [self frame];
    if ([self pageGetCount]>0) {
        NSInteger lPage = [self pageGetCount]-1;
        rect.size.width = [self pageGetPosition:lPage].x + [self pageGetSize:lPage].width;
    }
    
    if (!_scrollerView) {
        _scrollerView = [[UIView alloc] initWithFrame:rect];
        _scrollerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollerView];
    }
    else if (releace) {
        for (UIView *v in [_pages allValues])
            [v removeFromSuperview];
        [_pages removeAllObjects];
        [_scrollerView setFrame:rect];
    }
    [self moveToPage:_curPage>-1 ? _curPage : 0];
    
    if (invert)
        _flagInvertPageSize = NO;
}

- (void)reinitPages:(BOOL)savePosition {
    [self reinitPages:savePosition releace:YES invert:NO];
}

- (void)reinitPages {
    [self reinitPages:YES];
}

/**
 * Init page view
 * @param page index
 */
- (void)initPage:(NSInteger)page reinit:(BOOL)reinit {
    if (page>=[self pageGetCount])
        page = [self pageGetCount]-1;

    if (nil==_pages)
        _pages = [NSMutableDictionary dictionary];
    
    NSString *key = [NSString stringWithFormat:@"%d", page];

    UIView *pageView = [_pages objectForKey:key];
    if (nil==pageView) {
        pageView = [self pageGetView:page];
        if (nil==pageView)
            return;
    }

    CGRect rect = CGRectMake(0, 0, 0, 0);
    rect.size = [self pageGetSize:page];
    rect.origin = [self pageGetPosition:page];
    
    if ([[_scrollerView subviews] indexOfObject:pageView]==NSNotFound) {
        [_scrollerView addSubview:pageView];
        [pageView setFrame:rect];
        [_pages setObject:pageView forKey:key];
    }
    else {
        [pageView setFrame:rect];
    }
}

- (void)initPage:(NSInteger)page {
    [self initPage:page reinit:NO];
}

/**
 * Move to page
 * @param page index
 * @param duration animate
 */
- (void)moveToPage:(NSInteger)page duration:(NSTimeInterval)duration {
    int pageCount = [self pageGetCount];

    if (page>=pageCount)
        page = pageCount-1;

    // incidental to initialize the page
    if (_currentPage<page) {
        if (_currentPage<0)
            _currentPage = 0;
        for (int i=_currentPage;i<=page+1 && i<pageCount;i++)
            if (i>-1) [self initPage:i];
    }
    else {
        for (int i=_currentPage;i>=page+1;i--)
            if (i>-1) [self initPage:i];
    }

    // Move to
    CGRect frame = [_scrollerView frame];
    frame.origin.x = -[self pageGetPosition:page].x;
    
    if (_currentPage<0 || duration<=0) {
        [_scrollerView setFrame:frame];
        if ([delegate respondsToSelector:@selector(pageChange:oldPage:newPage:duration:)])
            [delegate pageChange:self oldPage:_currentPage newPage:page duration:0];
    }
    else {
        [UIView beginAnimations:@"DVPageAnimationMove" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; 
        [UIView setAnimationDuration:duration];

        if ([delegate respondsToSelector:@selector(pageChange:oldPage:newPage:duration:)])
            [delegate pageChange:self oldPage:_currentPage newPage:page duration:duration];
        [_scrollerView setFrame:frame];
        
        [UIView commitAnimations];
    }
    
    _currentPage = page;
}

- (void)moveToPage:(NSInteger)page {
    [self moveToPage:page duration:0.3];
}

@end



