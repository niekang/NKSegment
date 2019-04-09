//
//  NKSegment.h
//  xiangshangV5
//
//  Created by niekang on 2019/2/27.
//  Copyright © 2019 zendaiUp. All rights reserved.
//

#import "NKSegment.h"


@interface NKSegment()<UIScrollViewDelegate>{
    BOOL _isDrag;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) NSMutableArray *btns;
@property (nonatomic, strong) NSMutableArray *itemsWidthArray;

@property (nonatomic, assign) BOOL isSetSelectedIndex;

@end

@implementation NKSegment

- (instancetype)initWithFrame:(CGRect)frame Titles:(NSArray *)titles{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        self.titles = titles;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];{
        [self initData];
    }
    return self;
}

- (void)initData {
    self.isSetSelectedIndex = NO;
    self.btns = [NSMutableArray array];
    self.itemsWidthArray = [NSMutableArray array];
    self.contentInset = UIEdgeInsetsZero;
    self.itemMargin = 10;
    self.progressViewSize = CGSizeMake(20, 3);
    self.normalTextFont = [UIFont systemFontOfSize:16];
    self.selectedTextFont = self.normalTextFont;
    self.normalTextColor = [UIColor lightGrayColor];
    self.selectedTextColor = [UIColor blackColor];
    self.progressTintColor = self.selectedTextColor;
    self.showProgressView = YES;

    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.progressView];
}

#pragma mark - Public
- (void)reloadData {
    if (self.titles.count == 0) {
        return;
    }
    
    if (_dataSource) {
        if ([_dataSource respondsToSelector:@selector(segmentContentInset:)]) {
            self.contentInset = [_dataSource segmentContentInset:self];
        }
        
        if ([_dataSource respondsToSelector:@selector(segmentItemMargin:)]) {
            self.itemMargin = [_dataSource segmentItemMargin:self];
        }
        
        if ([_dataSource respondsToSelector:@selector(sizeForProgressView:)]) {
            self.progressViewSize = [_dataSource sizeForProgressView:self];
        }
        
        if ([_dataSource respondsToSelector:@selector(showSegmentProgressView:)]) {
            self.showProgressView = [_dataSource showSegmentProgressView:self];
        }
        
    }
    
    [self.itemsWidthArray removeAllObjects];
    
    CGFloat x = 0;
    
    for (NSInteger i = 0; i < self.btns.count; i++) {
        UIButton *btn = self.btns[i];
        [btn setTitleColor:self.normalTextColor forState:UIControlStateNormal];
        [btn setTitleColor:self.selectedTextColor forState:UIControlStateSelected];
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        if (i == _selectedIndex) {
            btn.selected = YES;
            btn.titleLabel.font = self.selectedTextFont;
        }else{
            btn.selected = NO;
            btn.titleLabel.font = self.normalTextFont;
        }
        
        CGFloat itemWidth;

        if (_dataSource && [_dataSource respondsToSelector:@selector(widthForItem:atIndex:)]) {
            itemWidth = [_dataSource widthForItem:self atIndex:i];
        }else{
            NSString *title = self.titles[i];
            itemWidth = [title sizeWithAttributes:@{NSFontAttributeName:self.normalTextFont}].width;
            CGFloat selectedItemWidth = [title sizeWithAttributes:@{NSFontAttributeName:self.selectedTextFont}].width;
            if (selectedItemWidth > itemWidth) {
                itemWidth = selectedItemWidth;
            }
            
        }
        
        [self.itemsWidthArray addObject:@(itemWidth)];
        
        btn.frame = CGRectMake(x, 0, itemWidth, self.scrollView.frame.size.height);

        x += itemWidth;
        
        if (i != self.titles.count-1) {
            x += self.itemMargin;
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(x, self.scrollView.frame.size.height);
    
    CGRect frame = self.progressView.frame;
    frame.origin.x = [self progressViewXAtIndex:_selectedIndex];
    self.progressView.frame = frame;
    self.progressView.hidden = !self.showProgressView;

}

- (CGSize)contentSize {
    return self.scrollView.contentSize;
}

- (void)setSelecetdIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    
    if (self.titles.count == 0) {
        return;
    }
    
    if (_isSetSelectedIndex && _selectedIndex == selectedIndex) {
        return;
    }
    
    _isSetSelectedIndex = YES;
    
    UIButton *oldBtn = self.btns[_selectedIndex];
    oldBtn.selected = NO;
    oldBtn.titleLabel.font = self.normalTextFont;
    
    UIButton *newBtn = self.btns[selectedIndex];
    newBtn.selected = YES;
    newBtn.titleLabel.font = self.selectedTextFont;
    
    _selectedIndex = selectedIndex;

    CGRect frame = self.progressView.frame;
    frame.origin.x = [self progressViewXAtIndex:selectedIndex];
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.progressView.frame = frame;
        }];
    }else{
        self.progressView.frame = frame;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedItem:atIndex:)]){
        [_delegate didSelectedItem:self atIndex:selectedIndex];
    }
    
    if (self.contentScrollView.contentOffset.x != selectedIndex * self.contentScrollView.frame.size.width) {
        [self.contentScrollView setContentOffset:CGPointMake(selectedIndex * self.contentScrollView.frame.size.width, 0) animated:YES];
    }
}


#pragma mark - Private
- (CGFloat)progressViewXAtIndex:(NSInteger)index {
    if (self.itemsWidthArray.count == 0) {
        return 0;
    }
    CGFloat x = 0;
    if (self.progressType == NKSegmentProgressTypeLeft) {
        for (NSInteger i=0; i<index; i++) {
            x += [self.itemsWidthArray[i] doubleValue] + self.itemMargin;
        }
    }else if(self.progressType == NKSegmentProgressTypeCenter){
        for (NSInteger i=0; i<=index; i++) {
            if (i == index) {
                x += [self.itemsWidthArray[i] doubleValue]/2.f;
            }else{
                x += [self.itemsWidthArray[i] doubleValue] + self.itemMargin;
            }
        }
        x -= self.progressViewSize.width/2.f;
    }else if(self.progressType == NKSegmentProgressTypeRight){
        for (NSInteger i=0; i<=index; i++) {
            if (i == index) {
                x += [self.itemsWidthArray[i] doubleValue];
            }else{
                x += [self.itemsWidthArray[i] doubleValue] + self.itemMargin;
            }
        }
        x -= self.progressViewSize.width;
    }
    return x;
}

- (void)updatePogress:(UIScrollView *)scrollView {
    CGFloat progress = (scrollView.contentOffset.x - _selectedIndex * scrollView.frame.size.width)/scrollView.frame.size.width;
    CGFloat currentX = [self progressViewXAtIndex:_selectedIndex];
    CGRect frame = self.progressView.frame;
    if (_selectedIndex == 0) {
        if (progress >= 0) {
            CGFloat nextX = [self progressViewXAtIndex:_selectedIndex+1];
            frame.origin.x = currentX + (nextX - currentX) * progress;
        }else{
            frame.origin.x = currentX + (currentX - self.progressView.frame.size.width/2.f) * progress;
        }
    }else if (_selectedIndex == self.titles.count - 1){
        if (progress >= 0) {
            frame.origin.x = currentX + (currentX + self.progressView.frame.size.width/2.f) * progress;
        }else{
            CGFloat lastX = [self progressViewXAtIndex:_selectedIndex-1];
            frame.origin.x = currentX + (currentX - lastX) * progress;
        }
    }else{
        CGFloat lastX = [self progressViewXAtIndex:_selectedIndex-1];
        CGFloat nextX = [self progressViewXAtIndex:_selectedIndex+1];
        if (progress >= 0) {
            frame.origin.x = currentX + (nextX - currentX) * progress;
        }else{
            frame.origin.x = currentX + (currentX - lastX) * progress;
        }
    }
    self.progressView.frame = frame;
}

#pragma mark - Action
- (void)btnClick:(UIButton *)btn {
    [self setSelecetdIndex:btn.tag animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"%s",__FUNCTION__);
    _isDrag = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_isDrag) {
        [self updatePogress:scrollView];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(segment:contentScrollViewDidScroll:)]) {
        [self.delegate segment:self contentScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _isDrag = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentPage = scrollView.contentOffset.x/scrollView.frame.size.width;
    self.selectedIndex = currentPage;
    if (self.delegate && [self.delegate respondsToSelector:@selector(segment:contentScrollViewDidEndDecelerating:)]) {
        [self.delegate segment:self contentScrollViewDidEndDecelerating:scrollView];
    }
    _isDrag = NO;
}

#pragma mark - Setter
- (void)setTitles:(NSArray *)titles {
    if (titles.count == 0) {
        return;
    }
    _titles = titles;
    
    for (UIButton *btn in self.btns) {
        [btn removeFromSuperview];
    }
    
    [self.btns removeAllObjects];
    
    for (NSInteger i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [self.scrollView addSubview:btn];
        [self.btns addObject:btn];
    }
    self.scrollView.contentSize = CGSizeMake(0, 0);
    
    self.selectedIndex = 0;
    
    [self.scrollView bringSubviewToFront:self.progressView];

    [self reloadData];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self setSelecetdIndex:selectedIndex animated:NO];
}

- (void)setScrollEnable:(BOOL)scrollEnable {
    self.scrollView.scrollEnabled = scrollEnable;
}

- (void)setProgressType:(NKSegmentProgressType)progressType {
    _progressType = progressType;
    self.progressView.frame = CGRectMake([self progressViewXAtIndex:_selectedIndex], self.progressView.frame.origin.y, self.progressView.frame.size.width, self.progressView.frame.size.height);
}

- (void)setShowProgressView:(BOOL)showProgressView {
    _showProgressView = showProgressView;
    self.progressView.hidden = !showProgressView;
}

- (void)setProgressViewSize:(CGSize)progressViewSize {
    _progressViewSize = progressViewSize;
    self.progressView.frame = CGRectMake(self.progressView.frame.origin.x, self.scrollView.frame.size.height - progressViewSize.height, progressViewSize.width, progressViewSize.height);
    
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    _progressTintColor = progressTintColor;
    self.progressView.backgroundColor = progressTintColor;
}

- (void)setContentScrollView:(UIScrollView *)contentScrollView {
    _contentScrollView = contentScrollView;
    _contentScrollView.delegate = self;
    [self.contentScrollView setContentOffset:CGPointMake(_selectedIndex * self.contentScrollView.frame.size.width, 0)];
}


- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    self.scrollView.frame = CGRectMake(self.contentInset.left, self.contentInset.top, self.frame.size.width - self.contentInset.left - self.contentInset.right, self.frame.size.height - self.contentInset.top - self.contentInset.bottom);
}


- (void)setProgressViewCorner:(CGFloat)progressViewCorner {
    _progressViewCorner = progressViewCorner;
    self.progressView.layer.cornerRadius = progressViewCorner;
    self.progressView.layer.masksToBounds = YES;
}

#pragma mark - Ovveride
- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = CGRectMake(self.contentInset.left, self.contentInset.top, self.frame.size.width - self.contentInset.left - self.contentInset.right, self.frame.size.height - self.contentInset.top - self.contentInset.bottom);
    self.progressView.frame = CGRectMake(self.progressView.frame.origin.x, self.scrollView.frame.size.height - self.progressViewSize.height, self.progressViewSize.width, self.progressViewSize.height);
}

#pragma mark - Getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.contentInset.left, self.contentInset.top, self.frame.size.width - self.contentInset.left - self.contentInset.right, self.frame.size.height - self.contentInset.top - self.contentInset.bottom)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, self.scrollView.frame.size.height - self.progressViewSize.height, self.progressViewSize.width, self.progressViewSize.height)];
        _progressView.backgroundColor = self.progressTintColor;
        _progressView.hidden = YES;
    }
    return _progressView;
}

@end
