//
//  MAAnnotation.m
//  GPSPoints
//
//  Created by M on 24.03.15.
//
//

#import "MAAnnotation.h"

@interface MAAnnotation ()
{
    CLLocationCoordinate2D _c;
    NSString* _txt;
    NSString* _name;
}
@end

//=================================================================================

@implementation MAAnnotation

//---------------------------------------------------------------------------------
- (instancetype)initWithName: (NSString*)name txt: (NSString*)txt
{
    if (self = [super init])
    {
        _name = [name retain];
        _txt  = [txt  retain];
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [_name release];
    [_txt  release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (CLLocationCoordinate2D)coordinate
{
    return _c;
}

//---------------------------------------------------------------------------------
- (void)setCoordinate: (CLLocationCoordinate2D)newCoordinate
{
    _c = newCoordinate;
}

//---------------------------------------------------------------------------------
- (NSString *)title
{
    return _name;
}

//---------------------------------------------------------------------------------
- (NSString *)subtitle
{
    return _txt;
}

//---------------------------------------------------------------------------------
- (void)setTxt: (NSString*)txt
{
    [txt retain];
    [_txt release];
    _txt = txt;
}

@end
