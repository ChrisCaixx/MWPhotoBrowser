//
//  MWCaptionView.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 30/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MWCommon.h"
#import "MWCaptionView.h"
#import "MWPhoto.h"

static const CGFloat   labelPadding = 4;
static const NSInteger numberOfLinesToShow = 4;

// Private
@interface MWCaptionView () {
    id <MWPhoto> _photo;
    UILabel *_label;
    UILabel *_timeAdressLabel;
    UIScrollView *_containScrollView;
}
@end

@implementation MWCaptionView

- (id)initWithPhoto:(id<MWPhoto>)photo {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)]; // Random initial frame
    if (self) {
        self.userInteractionEnabled = YES;
        _photo = photo;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            // Use iOS 7 blurry goodness
            self.barStyle = UIBarStyleBlackTranslucent;
            self.tintColor = nil;
            self.barTintColor = nil;
            self.barStyle = UIBarStyleBlackTranslucent;
            [self setBackgroundImage:nil forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        } else {
            // Transparent black with no gloss
            CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
            UIGraphicsBeginImageContext(rect.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:0 alpha:0.6] CGColor]);
            CGContextFillRect(context, rect);
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [self setBackgroundImage:image forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        }
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self setupCaption];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
//    CGFloat maxHeight = 9999;
//    if (_label.numberOfLines > 0) maxHeight = _label.font.leading*_label.numberOfLines;
    CGFloat maxHeight = numberOfLinesToShow * _label.font.leading;

    CGSize timeAddressSize;
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        timeAddressSize = [_timeAdressLabel.text boundingRectWithSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:_timeAdressLabel.font}
                                             context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        timeAddressSize = [_timeAdressLabel.text sizeWithFont:_timeAdressLabel.font
                           constrainedToSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
                               lineBreakMode:_timeAdressLabel.lineBreakMode];
#pragma clang diagnostic pop
    }
    
    
    CGSize textSize;
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        textSize = [_label.text boundingRectWithSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:_label.font}
                                             context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        textSize = [_label.text sizeWithFont:_label.font
                           constrainedToSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
                               lineBreakMode:_label.lineBreakMode];
#pragma clang diagnostic pop
    }
    
    CGFloat height = timeAddressSize.height > 0 ? (labelPadding + timeAddressSize.height) : 0;
    height += textSize.height ? textSize.height + labelPadding : 0;
    height += height == 0 ? 0 : labelPadding;
    
    return CGSizeMake(size.width, height);
}

- (void)setupCaption {
    
    _timeAdressLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelPadding, labelPadding,
                                                                               self.bounds.size.width-labelPadding*2,
                                                                                [UIFont systemFontOfSize:12].pointSize)];
    _timeAdressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _timeAdressLabel.opaque = NO;
    _timeAdressLabel.backgroundColor = [UIColor clearColor];
    if (SYSTEM_VERSION_LESS_THAN(@"6")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _timeAdressLabel.textAlignment = UITextAlignmentLeft;
        _timeAdressLabel.lineBreakMode = UILineBreakModeWordWrap;
#pragma clang diagnostic pop
    } else {
        _timeAdressLabel.textAlignment = NSTextAlignmentLeft;
        _timeAdressLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    
    _timeAdressLabel.numberOfLines = 1;
    _timeAdressLabel.textColor = [UIColor whiteColor];
    if (SYSTEM_VERSION_LESS_THAN(@"7")) {
        // Shadow on 6 and below
        _timeAdressLabel.shadowColor = [UIColor blackColor];
        _timeAdressLabel.shadowOffset = CGSizeMake(1, 1);
    }
    _timeAdressLabel.font = [UIFont systemFontOfSize:12];
    
    NSMutableString *timeAddress = [NSMutableString stringWithString:(_photo.timeString.length ? [NSString stringWithFormat:@"🕒%@", _photo.timeString] : @"")];
    
    if (_photo.address.length) {
        [timeAddress appendString:[NSString stringWithFormat:@"    📍%@", _photo.address]];
    }
    
    _timeAdressLabel.text = timeAddress;
//    [self addSubview:_timeAdressLabel];
    [_timeAdressLabel sizeToFit];
    
    if (timeAddress.length) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(labelPadding, CGRectGetMaxY(_timeAdressLabel.frame) +labelPadding,
                                                           self.bounds.size.width-labelPadding*2,
                                                           self.bounds.size.height)];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    } else {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(labelPadding, labelPadding,
                                                           self.bounds.size.width-labelPadding*2,
                                                           self.bounds.size.height)];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    _label.opaque = NO;
    _label.backgroundColor = [UIColor clearColor];
    if (SYSTEM_VERSION_LESS_THAN(@"6")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _label.textAlignment = UITextAlignmentLeft;
        _label.lineBreakMode = UILineBreakModeTailTruncation;
#pragma clang diagnostic pop
    } else {
        _label.textAlignment = NSTextAlignmentLeft;
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
    }

    _label.numberOfLines = 0;
    _label.textColor = [UIColor whiteColor];
    if (SYSTEM_VERSION_LESS_THAN(@"7")) {
        // Shadow on 6 and below
        _label.shadowColor = [UIColor blackColor];
        _label.shadowOffset = CGSizeMake(1, 1);
    }
    _label.font = [UIFont systemFontOfSize:15];
    if ([_photo respondsToSelector:@selector(caption)]) {
        _label.text = [_photo caption];
    }
    [_label sizeToFit];
//    [self addSubview:_label];
    
    _containScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _containScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_containScrollView];
    
    [_containScrollView addSubview:_timeAdressLabel];
    [_containScrollView addSubview:_label];
    [_containScrollView setContentSize:CGSizeMake(0, CGRectGetMaxY(_label.frame))];
}

@end
