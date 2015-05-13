//
//  MAAnnotation.h
//  GPSPoints
//
//  Created by M on 24.03.15.
//
//

//=================================================================================

@interface MAAnnotation : NSObject <MKAnnotation>

- (instancetype)initWithName: (NSString*)name txt: (NSString*)txt;
- (void)setTxt: (NSString*)txt;

@end
