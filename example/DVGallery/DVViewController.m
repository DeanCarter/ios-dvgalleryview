//
//  DVViewController.m
//  DVGallery
//
//  Created by Dmitry Ponomarev on 6/20/12.
//  Copyright (c) 2012 MySelf. All rights reserved.
//

#import "DVViewController.h"

@implementation DVViewController

@synthesize gallery;
@synthesize backgroundScreen;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    gallery.backgroundColor = [UIColor clearColor];
    gallery.delegate = self;
    //[gallery setDelegate:self];
    [gallery setCorrectCellPosition:YES];
    [gallery setCorrectCellMetrics:YES];
    [gallery reinitGallery];
}

- (void)viewDidUnload
{
    [self setGallery:nil];
    [self setBackgroundScreen:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [gallery reinitGallery:NO invert:YES];
    [super willRotateToInterfaceOrientation:interfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [gallery reinitGallery:NO invert:NO];
    [super didRotateFromInterfaceOrientation:interfaceOrientation];
}

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


- (void)galleryCellTapped:(DVGalleryView*)gl view:(UIView*)view {
    NSLog(@"galleryCellTapped: %@ %@", gl, view);
}

#pragma mark -
#pragma mark Pages delegate

- (NSInteger)pageGetCount:(DVPagesView*)pages {
    return 7;
}

- (UIView*)pageGetView:(DVPagesView*)pages page:(NSInteger)page view:(UIView *)view {
    return nil;
    //UIView *p = [[UIView alloc] initWithFrame:[[self view] frame]];
    //p.backgroundColor = page%2==0 ? [UIColor redColor] : [UIColor grayColor];
    //return p;
}

- (void)pageChange:(DVPagesView*)pageView oldPage:(NSInteger)oldPage newPage:(NSInteger)page duration:(NSTimeInterval)duration {

    if (oldPage!=page) {
        CGRect frame = [backgroundScreen frame];
        frame.origin.x = -((frame.size.width-[[self view] frame].size.width)/([self pageGetCount:pageView]-1))*page;

        if (duration) {
            [UIView beginAnimations:@"DVPageAnimationMove2" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; 
            [UIView setAnimationDuration:0.3];
            [backgroundScreen setFrame:frame];
            [UIView commitAnimations];
        }
        else {
            [backgroundScreen setFrame:frame];
        }
    }
}

@end
