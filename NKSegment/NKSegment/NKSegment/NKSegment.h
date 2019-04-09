//
//  NKSegment.h
//  xiangshangV5
//
//  Created by niekang on 2019/2/27.
//  Copyright © 2019 zendaiUp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/**
 进度条的位置 居左 居中 居右

 - NKSegmentProgressTypeLeft: <#NKSegmentProgressTypeLeft description#>
 - NKSegmentProgressTypeCenter: <#NKSegmentProgressTypeCenter description#>
 - NKSegmentProgressTypeRight: <#NKSegmentProgressTypeRight description#>
 */
typedef NS_ENUM(NSInteger, NKSegmentProgressType){
    NKSegmentProgressTypeLeft,
    NKSegmentProgressTypeCenter,
    NKSegmentProgressTypeRight,
};

typedef NS_ENUM(NSInteger, NKSegmentSelectedAnimationStyle){
    NKSegmentSelectedAnimationStyleDefalut,//默认无样式
};

@class NKSegment;

@protocol NKSegmentDataSource <NSObject>


/**
 设置内容边距

 @param segment <#segment description#>
 @return <#return value description#>
 */
- (UIEdgeInsets)segmentContentInset:(NKSegment *)segment;


/**
 设置按钮之间的距离

 @param segment <#segment description#>
 @return <#return value description#>
 */
- (CGFloat)segmentItemMargin:(NKSegment *)segment;


/**
 是否显示进度条

 @param segment <#segment description#>
 @return <#return value description#>
 */
- (BOOL)showSegmentProgressView:(NKSegment *)segment;


/**
 进度条大小

 @param segment <#segment description#>
 @return <#return value description#>
 */
- (CGSize)sizeForProgressView:(NKSegment *)segment;


/**
 自定义大小

 @param segment <#segment description#>
 @param index <#index description#>
 @return <#return value description#>
 */
- (CGFloat)widthForItem:(NKSegment *)segment atIndex:(NSInteger)index;

@end


@protocol NKSegmentDelegate <NSObject>
@optional;
/**
 选中下标
 
 @param segment <#segmennt description#>
 @param index <#index description#>
 */
- (void)didSelectedItem:(NKSegment *)segment atIndex:(NSInteger)index;


/**
 <#Description#>

 @param segment <#segment description#>
 @param contentScrollView <#contentScrollView description#>
 */
- (void)segment:(NKSegment *)segment contentScrollViewDidScroll:(UIScrollView *)contentScrollView;

/**
 <#Description#>
 
 @param segment <#segment description#>
 @param contentScrollView <#contentScrollView description#>
 */
- (void)segment:(NKSegment *)segment contentScrollViewDidEndDecelerating:(UIScrollView *)contentScrollView;

@end

@interface NKSegment : UIView

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL scrollEnable;
@property (nonatomic, assign) BOOL showProgressView;
@property (nonatomic, assign) CGSize progressViewSize;
@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIFont *normalTextFont;
@property (nonatomic, strong) UIFont *selectedTextFont;

@property (nonatomic, assign) UIEdgeInsets contentInset;

@property (nonatomic, assign) CGFloat itemMargin;
@property (nonatomic, assign) CGFloat progressViewCorner;

@property (nonatomic, assign) NKSegmentProgressType progressType;
@property (nonatomic, assign) NKSegmentSelectedAnimationStyle selectedStyle;

@property (nonatomic, weak) id <NKSegmentDelegate> delegate;
@property (nonatomic, weak) id <NKSegmentDataSource> dataSource;

@property (nonatomic, weak) UIScrollView *contentScrollView;

- (instancetype)initWithFrame:(CGRect)frame Titles:(NSArray *)titles;

- (void)reloadData;

- (CGSize)contentSize;

- (void)setSelecetdIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
