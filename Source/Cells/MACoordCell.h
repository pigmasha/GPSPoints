//
//  MACoordCell.h
//  GPSPoints
//
//  Created by M on 26.03.15.
//
//

#import "MACells.h"

// latitude/longitude input cell

@interface MACoordCell : MAZeroCell

- (instancetype)initIsLat: (BOOL)isLat val: (double)val;
- (double)val;

@end
