//
//  MASegmCell.m
//  GPSPoints
//
//  Created by M on 27.03.15.
//
//

#import "MASegmCell.h"
#import "MAController.h"

@interface MASegmCell ()
{
    UISegmentedControl* _segm;
}
@end

//=================================================================================

@implementation MASegmCell

//---------------------------------------------------------------------------------
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle: style reuseIdentifier: reuseIdentifier])
    {
        CGFloat w = self.contentView.bounds.size.width;
        
        UILabel* l;
        ADD_LABEL(l, 10, 10, w - 20, 20, SZ(Width), 16, NO, self.contentView);
        l.text = LSTR(@"P_Type");
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSArray* items = [[NSArray alloc] initWithObjects: LSTR(@"P_Type1"), LSTR(@"P_Type2"), LSTR(@"P_Type3"), nil];
        _segm = [[UISegmentedControl alloc] initWithItems: items];
        [items release];
        _segm.selectedSegmentIndex = [MA_CONTROLLER mapType];
        _segm.frame = CGRectMake(10, 35, w - 20, SEGM_H);
        _segm.autoresizingMask = SZ(Width);
        [self.contentView addSubview: _segm];
        [_segm addTarget: self action: @selector(onSegment) forControlEvents: UIControlEventValueChanged];
        [_segm release];
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)onSegment
{
    [MA_CONTROLLER setMapType: (MAMapType)_segm.selectedSegmentIndex];
}

@end
