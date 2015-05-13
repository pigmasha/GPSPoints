//
//  MAPointCell.m
//  GPSPoints
//
//  Created by M on 26.03.15.
//
//

#import "MAPointCell.h"

@interface MAPointCell ()
{
    UILabel* _name;
    UILabel* _coord;
    UIImageView* _img;
}

@end

//=================================================================================

@implementation MAPointCell

//---------------------------------------------------------------------------------
+ (NSString *)identifier
{
    static NSString* _s_identifier = @"P1";
    return _s_identifier;
}

//---------------------------------------------------------------------------------
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle: style reuseIdentifier: reuseIdentifier])
    {
        UIImage* i = [UIImage imageNamed: @"button_my_geolocation"];
        
        int w = self.contentView.bounds.size.width;
        ADD_LABEL(_name,  10, 5, w - 20 - i.size.width, 25, SZ(Width), 17, NO, self.contentView);
        ADD_LABEL(_coord, 10, 28, w - 20 - i.size.width, 20, SZ(Width), 15, NO, self.contentView);
        _img = [[UIImageView alloc] initWithImage: i];
        _img.frame = CGRectMake(w - i.size.width - 10, (POINT_ROW_H - i.size.height) / 2, i.size.width, i.size.height);
        _img.autoresizingMask = SZ_M(Left);
        [self.contentView addSubview: _img];
        [_img release];
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)setName: (NSString*)name andCoord: (NSString*)coord
{
    _name.text = name;
    _coord.text = coord;
    _img.image = ([coord length]) ? [UIImage imageNamed: @"button_my_geolocation"] : nil;
}

@end
