//
//  MAController.h
//  GPSPoints
//
//  Created by M on 24.03.15.
//
//

#define MA_CONTROLLER [MAController sharedInstance]

typedef enum
{
    MACoorNone,
    MACoorDeg,
    MACoorDegMin,
    MACoorDegMinSec,
    MACoorLast
} MACoorFmt;

typedef enum
{
    MAMapDef,
    MAMapSat,
    MAMapHybrid
} MAMapType;

@interface MAController : NSObject

+ (void)initSharedInstance;
+ (instancetype)sharedInstance;

- (void)loadInWindow: (UIWindow*)window;

- (void)locChanged;
- (void)onPoints;

- (void)stringForC: (CLLocationCoordinate2D)c res: (NSString**)res;
- (void)stringForD: (double)d res: (NSString**)res;
- (void)stringForCurLocation: (NSString**)res;

- (int)fmt;
- (void)setFmt: (int)f;

- (MAMapType)mapType;
- (void)setMapType: (MAMapType)type;

- (void)settRotChanged;

// Add/edit point
// 0 - ok
// 1 - point exists
// setCur: 0 - no set, 1 - set current, 2 - set shows
- (int)editPoint: (NSArray*)pt name: (NSString*)name lat: (double)lat lon: (double)lon setCur: (int)setCur;
- (void)deletePoint: (int)idx;

// Current point
- (void)setPoint: (NSArray*)pt isShow: (BOOL)isShow;
- (BOOL)ptShow;
- (CLLocationCoordinate2D)pt;
- (NSString*)ptName;

- (void)setShowPoint;
- (void)editShowPoint;
- (void)delShowPoint;

- (NSArray*)points;
- (NSArray*)ptStrs;

- (void)pointsToStr: (NSMutableString*)str;

+ (UIColor*)btTextColor;
+ (int)osVer;

@end
