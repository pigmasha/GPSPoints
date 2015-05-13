//
//  MANewController.h
//  GPSPoints
//
//  Created by M on 25.03.15.
//
//

@interface MANewController : UITableViewController

- (instancetype)initWithPt: (NSArray*)pt isNew: (BOOL)isNew;
- (instancetype)initWithC: (CLLocationCoordinate2D)c;

@end
