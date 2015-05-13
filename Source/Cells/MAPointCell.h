//
//  MAPointCell.h
//  GPSPoints
//
//  Created by M on 26.03.15.
//
//

#import "MACells.h"

#define POINT_ROW_H 54

@interface MAPointCell : MAZeroCell

+ (NSString *)identifier;
- (void)setName: (NSString*)name andCoord: (NSString*)coord;

@end
