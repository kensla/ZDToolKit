//
//  MMScrollView.m
//  MMUIDemo
//
//  Created by Zero.D.Saber on 2017/5/5.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "ZDBannerScrollView.h"
#import <ZDToolKit/NSTimer+ZDUtility.h>
#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#endif

@interface ZDImageCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, copy) void(^zdDownloadBlock)(UIImageView *imageView, NSString *urlString, UIImage *placeHolderImage);
@end


@interface ZDBannerScrollView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *innerDataSource; ///< 真正的数据源（比传入的数据多2条）
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, weak  ) id<ZDBannerScrollViewDelegate> delegate;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIImage *placeholderImage;
@end

@implementation ZDBannerScrollView

- (void)dealloc {
    [self invalidateTimer];
    
    if (_collectionView) {
        _collectionView.delegate = nil;
        _collectionView.dataSource = nil;
    }
    
    NSLog(@"%@-->%@, %s", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __PRETTY_FUNCTION__);
}

#pragma mark - Public Method

- (void)invalidateTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)pauseTimer {
    if (!_timer) return;
    self.timer.fireDate = [NSDate distantFuture];
}

- (void)resumeTimer {
    if (!_timer) return;
    self.timer.fireDate = [NSDate date];
}

+ (instancetype)scrollViewWithFrame:(CGRect)frame delegate:(id<ZDBannerScrollViewDelegate>)delegate placeholderImage:(UIImage *)placeholderImage {
    ZDBannerScrollView *view = [[self alloc] initWithFrame:frame];
    view.delegate = delegate;
    view.placeholderImage = placeholderImage;
    
    return view;
}

#pragma mark -

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) return;
    
    [self setupTimer];
}

#pragma mark -

- (void)setup {
    _innerDataSource = @[].mutableCopy;
    
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
}

- (void)setupTimer {
    [self invalidateTimer];
    __weak typeof(self)weakSelf = self;
    self.timer = [NSTimer zd_scheduledTimerWithTimeInterval:(self.interval > 0 ? self.interval : 3.5) repeats:YES block:^(NSTimer * _Nonnull timer) {
        __strong typeof(weakSelf)self = weakSelf;
        [self autoScroll];
    }];
}

- (void)autoScroll {
    CGFloat itemWidth = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize.width;
    
    NSUInteger currentIndex = (self.collectionView.contentOffset.x + itemWidth * 0.5) / itemWidth;
    NSUInteger targetIndex = currentIndex + 1;
    
    if (targetIndex >= self.innerDataSource.count) { // 越界的情况
        CGFloat contentOffsetY = self.collectionView.contentOffset.y;
        self.collectionView.contentOffset = CGPointMake(CGRectGetWidth(self.bounds), contentOffsetY);
        if (self.innerDataSource.count <= 2) return;
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
    else {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

#pragma mark - UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.innerDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZDImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZDImageCollectionViewCell class]) forIndexPath:indexPath];
    // 用自己外面的下载库下载
    if (self.delegate && [self.delegate respondsToSelector:@selector(customDownloadWithImageView:url:placeHolderImage:)]) {
        __weak typeof(self) weakTarget = self;
        cell.zdDownloadBlock = ^(UIImageView *imageView, NSString *urlString, UIImage *placeHolderImage) {
            __strong typeof(weakTarget) self = weakTarget;
            [self.delegate customDownloadWithImageView:imageView url:urlString placeHolderImage:placeHolderImage];
        };
    }
    cell.placeholderImage = self.placeholderImage;
    cell.urlString = [self.innerDataSource objectAtIndex:indexPath.item];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollView:didSelectItemAtIndex:)]) {
        if (self.innerDataSource.count == 3) { // 此时说明只有一条数据
            NSLog(@"点击了第%zd个", 0);
            [self.delegate scrollView:self didSelectItemAtIndex:0];
        }
        else {
            NSLog(@"点击了第%zd个", indexPath.item - 1);
            NSUInteger selectIndex = indexPath.item - 1;
            if (indexPath.item >= self.innerDataSource.count - 2) {
                selectIndex = self.innerDataSource.count - 2 - 1;
            } else if (indexPath.item < 0) {
                selectIndex = 0;
            }
            [self.delegate scrollView:self didSelectItemAtIndex:selectIndex];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat contentWidth = scrollView.contentSize.width;
    CGFloat boundsWidth = self.bounds.size.width;
    if (offsetX >= (contentWidth - boundsWidth)) {
        scrollView.contentOffset = CGPointMake(boundsWidth, scrollView.contentOffset.y);
    }
    else if (offsetX < boundsWidth) {
        // 乘以一个大于1小于1.5的数，可以利用pagingEnabled特性，使滑动更自然
        scrollView.contentOffset = CGPointMake(contentWidth - boundsWidth * 1.3, scrollView.contentOffset.y);
    }
    
    NSInteger currentPage = scrollView.contentOffset.x / boundsWidth - 1;
    if (currentPage < 0) {
        currentPage = self.innerDataSource.count - 2 - 1;
    } else if (currentPage > self.innerDataSource.count - 2 - 1) {
        currentPage = 0;
    }
    self.pageControl.currentPage = currentPage;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollView:didScrollToIndex:)]) {
        [self.delegate scrollView:self didScrollToIndex:currentPage];
    }
}

#pragma mark - Property

//MARK: Setter
- (void)setImageURLStrings:(NSArray<NSString *> *)imageURLStrings {
    if (!imageURLStrings || imageURLStrings.count == 0) return;
    _imageURLStrings = imageURLStrings;
    
    if (_innerDataSource.count > 0) {
        [_innerDataSource removeAllObjects];
    }
    
    // 1张图片时禁用定时器和滑动
    if (imageURLStrings.count == 1) {
        [_timer invalidate];
        _timer = nil;
    }
    self.collectionView.scrollEnabled = (imageURLStrings.count > 1);
    
    [_innerDataSource addObjectsFromArray:imageURLStrings];
    [_innerDataSource insertObject:imageURLStrings.lastObject atIndex:0];
    [_innerDataSource addObject:imageURLStrings.firstObject];
    
    self.pageControl.numberOfPages = imageURLStrings.count;
    
    [self.collectionView reloadData];
}

//MARK: Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = ({
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            flowLayout.minimumInteritemSpacing = 0;
            flowLayout.minimumLineSpacing = 0;
            flowLayout.itemSize = self.bounds.size;
            
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.scrollsToTop = NO;
            collectionView.pagingEnabled = YES;
            collectionView.showsHorizontalScrollIndicator = NO;
            collectionView.showsVerticalScrollIndicator = NO;
            [collectionView registerClass:[ZDImageCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ZDImageCollectionViewCell class])];
            collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            if (@available(iOS 11, *)) {
                collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
                        
            collectionView.contentOffset = CGPointMake(CGRectGetWidth(collectionView.frame), collectionView.contentOffset.y);
            
            collectionView;
        });
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:(CGRect){0, CGRectGetHeight(self.bounds) - 20, CGRectGetWidth(self.bounds), 20}];
        _pageControl.numberOfPages = self.imageURLStrings.count;
        _pageControl.currentPage = 0;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.57 green:0.45 blue:0.57 alpha:1.0];
    }
    return _pageControl;
}

@end

//======================================================

@interface ZDImageCollectionViewCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ZDImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor yellowColor];
    
    [self.contentView addSubview:self.imageView];
}

#pragma mark - Property
//MARK: Setter
- (void)setUrlString:(NSString *)urlString {
    if (!urlString || urlString.length == 0) return;
    
    _urlString = urlString;

#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:self.placeholderImage];
#else
        if (self.zdDownloadBlock) {
            self.zdDownloadBlock(self.imageView, urlString, self.placeholderImage);
        }
#endif
}

//MARK: Getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = ({
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            imageView.backgroundColor = [UIColor whiteColor];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            imageView;
        });
    }
    return _imageView;
}

@end


