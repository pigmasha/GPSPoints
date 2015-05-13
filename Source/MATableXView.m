//
//  MATableXView.m
//  GPSPoints
//
//  Created by M on 26.03.15.
//
//

#import "MATableXView.h"

@interface MATableXView ()
{
    CGFloat _lastX;
}
@end

//=================================================================================

@implementation MATableXView

//---------------------------------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _lastX = [[touches anyObject] locationInView: self].x;
    [super touchesEnded: touches withEvent: event];
}

//---------------------------------------------------------------------------------
- (CGFloat)lastX
{
    return _lastX;
}

@end
