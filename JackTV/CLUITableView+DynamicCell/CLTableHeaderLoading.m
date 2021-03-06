
#import "CLTableHeaderLoading.h"

@interface CLTableHeaderLoading ()

@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;

@end

@implementation CLTableHeaderLoading

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.frame = CGRectMake(0, 0, 24, 24);
        
        [self addSubview:_indicatorView];
        self.indicatorView.center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.indicatorView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
}

- (void)setIsAnimating:(BOOL)isAnimating
{
    if (isAnimating) {
        [_indicatorView startAnimating];
    }
    else
    {
        [_indicatorView stopAnimating];
    }
    
}

- (BOOL)isAnimating
{
    return _indicatorView.isAnimating;
}

- (void)dealloc
{
    self.indicatorView = nil;
}



@end
