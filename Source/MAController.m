//
//  MAController.m
//  GPSPoints
//
//  Created by M on 24.03.15.
//
//

#import "MAController.h"
#import "MAViewController.h"
#import "MAPointsController.h"
#import "MANavController.h"
#import "MANewController.h"

#define FILE_POINTS @"%@/pt.plist"

#define CREATE_FOLDER(__path) if (![[NSFileManager defaultManager] fileExistsAtPath: __path]) [[NSFileManager defaultManager] createDirectoryAtPath: __path withIntermediateDirectories: NO attributes: nil error: nil]
#define DELETE_FILE(__path) if ([[NSFileManager defaultManager] fileExistsAtPath: __path]) [[NSFileManager defaultManager] removeItemAtPath: __path error: nil]

#define COORD_KOEF 1000000

@interface MAController ()
{
    NSString* _folder;
    int _fmt;
    MAMapType _type;
    
    MAViewController* _vc;
    NSMutableArray* _points;
    NSMutableArray* _ptStrs;
    
    CLLocationCoordinate2D _pt;
    NSString* _ptName;
    BOOL _ptShow;
    
    UIBarButtonItem* _item;
}
@end

@implementation MAController

static MAController* _s_inst = nil;

//---------------------------------------------------------------------------------
+ (void)initSharedInstance
{
    if (!_s_inst) _s_inst = [[MAController alloc] init];
}

//---------------------------------------------------------------------------------
+ (instancetype)sharedInstance
{
    return _s_inst;
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    if (_s_inst == self) _s_inst = nil;
    [_points release];
    [_ptStrs release];
    [_folder release];
    [_ptName release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (instancetype)init
{
    if (self = [super init])
    {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if (![paths count])
        {
            _folder = [[NSString alloc] init];
        } else {
            _folder = [[paths objectAtIndex: 0] retain];
        }
        CREATE_FOLDER(_folder);
        
        _fmt = (int)[[NSUserDefaults standardUserDefaults] integerForKey: SETT_FMT];
        if (_fmt <= MACoorNone || _fmt >= MACoorLast) _fmt = MACoorDeg;
        
        _points = [[NSMutableArray alloc] init];
        _ptStrs = [[NSMutableArray alloc] init];
        [self loadPoints];
        [self reloadPtStrs];
        
        if (SETT_BOOL_VAL(SETT_PT))
        {
            NSArray* pt = [self pointWithNLat: (int)[[NSUserDefaults standardUserDefaults] integerForKey: SETT_LAT]
                                         nLon: (int)[[NSUserDefaults standardUserDefaults] integerForKey: SETT_LON]];
            if (pt) [self setPoint: pt isShow: NO];
        }
        
        NSInteger i = [[NSUserDefaults standardUserDefaults] integerForKey: SETT_TYPE];
        _type = (i == 1) ? MAMapSat : ((i == 2) ? MAMapHybrid : MAMapDef);
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)loadInWindow: (UIWindow*)window
{
    _vc = [[MAViewController alloc] initWithNibName: nil bundle: nil];
    UINavigationController* nav = [[MANavController alloc] initWithRootViewController: _vc];
    [_vc release];
    nav.toolbarHidden = NO;
    
    _item = [[UIBarButtonItem alloc] initWithTitle: @"" style: UIBarButtonItemStylePlain target: nil action: 0];
    NSArray* items = [[NSArray alloc] initWithObjects: _item, nil];
    [_item release];
    _vc.toolbarItems = items;
    [items release];
    
    window.rootViewController = nav;
    [nav release];
}

//---------------------------------------------------------------------------------
- (void)locChanged
{
    if (![_vc curLocation].latitude && ![_vc curLocation].longitude) return;
    
    NSString* s = nil;
    [self stringForC: [_vc curLocation] res: &s];
    NSString* str = [[NSString alloc] initWithFormat: LSTR(@"V_Loc"), s];
    [s release];
    _item.title = str;
    [str release];
}

//---------------------------------------------------------------------------------
- (void)onPoints
{
    MAPointsController* vc = [[MAPointsController alloc] initWithNibName: nil bundle: nil];
    UINavigationController* nav = [[MANavController alloc] initWithRootViewController: vc];
    [vc release];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [_vc presentViewController: nav animated: YES completion: nil];
    [nav release];
}

//---------------------------------------------------------------------------------
- (void)stringForC: (CLLocationCoordinate2D)c res: (NSString**)res
{
    NSString* sLat = (c.latitude > 0)  ? @"N" : @"S";
    NSString* sLon = (c.longitude > 0) ? @"E" : @"W";
    
    if (c.latitude  < 0) c.latitude  = -c.latitude;
    if (c.longitude < 0) c.longitude = -c.longitude;
    
    int dLat = c.latitude;
    int dLon = c.longitude;
    
    switch (_fmt)
    {
        case MACoorDegMin:
            *res = [[NSString alloc] initWithFormat: @"%@ %02d°%06.3f' %@ %02d°%06.3f'",
                    sLat, dLat, 60 * (c.latitude  - dLat),
                    sLon, dLon, 60 * (c.longitude - dLon)];
            break;
            
        case MACoorDegMinSec:
        {
            int mLat = 60 * (c.latitude  - dLat);
            int mLon = 60 * (c.longitude - dLon);
            *res = [[NSString alloc] initWithFormat: @"%@ %02d°%02d'%02d'' %@ %02d°%02d'%02d''",
                    sLat, dLat, mLat, (int)(60.0 * 60.0 * (c.latitude  - dLat - (float)mLat / 60)),
                    sLon, dLon, mLon, (int)(60.0 * 60.0 * (c.longitude - dLon - (float)mLon / 60))];
            break;
        }
            
        default:
            *res = [[NSString alloc] initWithFormat: @"%@ %09.6f° %@ %09.6f°", sLat, c.latitude, sLon, c.longitude];
            break;
    }
}

//---------------------------------------------------------------------------------
- (void)stringForD: (double)d res: (NSString**)res
{
    if (d < 0) d = -d;
    int d1 = d;
    
    switch (_fmt)
    {
        case MACoorDegMin:
            *res = [[NSString alloc] initWithFormat: @"%02d°%06.3f'", d1, 60 * (d - d1)];
            break;
            
        case MACoorDegMinSec:
        {
            int m1 = 60 * (d - d1);
            *res = [[NSString alloc] initWithFormat: @"%02d°%02d'%02d''", d1, m1, (int)(60.0 * 60.0 * (d - d1 - (float)m1 / 60))];
            break;
        }
            
        default:
            *res = [[NSString alloc] initWithFormat: @"%09.6f°", d];
            break;
    }
}

//---------------------------------------------------------------------------------
- (void)stringForCurLocation: (NSString**)res
{
    [self stringForC: [_vc curLocation] res: res];
}

//---------------------------------------------------------------------------------
- (int)fmt
{
    return _fmt;
}

//---------------------------------------------------------------------------------
- (void)setFmt: (int)f
{
    _fmt = f;
    if (_fmt <= MACoorNone || _fmt >= MACoorLast) _fmt = MACoorDeg;
    [[NSUserDefaults standardUserDefaults] setInteger: _fmt forKey: SETT_FMT];
    [[MAPointsController sharedInstance] reloadData];
    [_vc reloadFmt];
    [self reloadPtStrs];
    [self locChanged];
}

//---------------------------------------------------------------------------------
- (MAMapType)mapType
{
    return _type;
}

//---------------------------------------------------------------------------------
- (void)setMapType: (MAMapType)type
{
    _type = type;
    [[NSUserDefaults standardUserDefaults] setInteger: type forKey: SETT_TYPE];
    [_vc reloadMapType];
}

//---------------------------------------------------------------------------------
- (void)settRotChanged
{
    [_vc reloadMapRot];
}

//---------------------------------------------------------------------------------
// Add/edit point
// 0 - ok
// 1 - point exists
//---------------------------------------------------------------------------------
- (int)editPoint: (NSArray*)pt name: (NSString*)name lat: (double)lat lon: (double)lon setCur: (int)setCur
{
    if (![name length]) name = LSTR(@"N_Name");
    
    if (pt)
    {
        int x1 = [[pt objectAtIndex: 1] doubleValue] * COORD_KOEF;
        int x2 = [[pt objectAtIndex: 2] doubleValue] * COORD_KOEF;
        if (x1 != (int)(lat * COORD_KOEF) || x2 != (int)(lon * COORD_KOEF))
        {
            if ([self pointWithNLat: lat * COORD_KOEF nLon: lon * COORD_KOEF]) return 1;
        }
    } else {
        if ([self pointWithNLat: lat * COORD_KOEF nLon: lon * COORD_KOEF]) return 1;
    }
    
    NSNumber* latN = [[NSNumber alloc] initWithDouble: lat];
    NSNumber* lonN = [[NSNumber alloc] initWithDouble: lon];
    NSArray* pt2 = [[NSArray alloc] initWithObjects: name, latN, lonN, nil];
    [latN release];
    [lonN release];
    
    if (pt)
    {
        NSUInteger i = [_points indexOfObject: pt];
        if (i != NSNotFound) [_points replaceObjectAtIndex: i withObject: pt2];
    } else {
        [_points addObject: pt2];
    }
    [pt2 release];
    [self savePoints];
    [[MAPointsController sharedInstance] reloadData];
    
    if (setCur) [self setPoint: pt2 isShow: (setCur == 2)];
    return 0;
}

//---------------------------------------------------------------------------------
- (void)setShowPoint
{
    NSArray* pt = [self pointWithNLat: _pt.latitude * COORD_KOEF nLon: _pt.longitude * COORD_KOEF];
    if (pt) [self setPoint: pt isShow: NO];
}

//---------------------------------------------------------------------------------
- (void)editShowPoint
{
    NSArray* pt = [self pointWithNLat: _pt.latitude * COORD_KOEF nLon: _pt.longitude * COORD_KOEF];
    if (!pt) return;
    
    UIViewController* vc = [[MANewController alloc] initWithPt: pt isNew: NO];
    UINavigationController* nav = [[MANavController alloc] initWithRootViewController: vc];
    [vc release];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [_vc presentViewController: nav animated: YES completion: nil];
    [nav release];
}

//---------------------------------------------------------------------------------
- (void)delShowPoint
{
    NSArray* pt = [self pointWithNLat: _pt.latitude * COORD_KOEF nLon: _pt.longitude * COORD_KOEF];
    [self setPoint: nil isShow: NO];
    if (pt) [self deletePoint: (int)[_points indexOfObject: pt]];
}

//---------------------------------------------------------------------------------
- (NSArray*)pointWithNLat: (int)lat nLon: (int)lon
{
    for (NSArray* pt in _points)
    {
        int x1 = [[pt objectAtIndex: 1] doubleValue] * COORD_KOEF;
        int x2 = [[pt objectAtIndex: 2] doubleValue] * COORD_KOEF;
        if (lat == x1 && lon == x2) return pt;
    }
    return nil;
}

//---------------------------------------------------------------------------------
- (void)deletePoint: (int)idx
{
    if (idx < 0 || idx >= [_points count]) return;
    NSArray* pt = [_points objectAtIndex: idx];
    if (_ptName)
    {
        int x1 = [[pt objectAtIndex: 1] doubleValue] * COORD_KOEF;
        int x2 = [[pt objectAtIndex: 2] doubleValue] * COORD_KOEF;
        int y1 = _pt.latitude * COORD_KOEF;
        int y2 = _pt.longitude * COORD_KOEF;
        if (x1 == y1 && x2 == y2) [self setPoint: nil isShow: NO];
    }
    [_points removeObjectAtIndex: idx];
    [self savePoints];
}

//---------------------------------------------------------------------------------
- (void)setPoint: (NSArray*)pt isShow: (BOOL)isShow
{
    _ptShow = isShow;
    [_ptName release];
    if (!pt)
    {
        if (!isShow)
        {
            SETT_SET_BOOL_VAL(SETT_PT, NO);
            [[NSUserDefaults standardUserDefaults] removeObjectForKey: SETT_LAT];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey: SETT_LON];
        }
        _ptName = nil;
        [_vc reloadPt];
        return;
    }
    _ptName = [[NSString alloc] initWithString: [pt firstObject]];
    _pt.latitude  = [[pt objectAtIndex: 1] doubleValue];
    _pt.longitude = [[pt objectAtIndex: 2] doubleValue];
    
    if (isShow)
    {
        SETT_SET_BOOL_VAL(SETT_PT, YES);
        [[NSUserDefaults standardUserDefaults] setInteger: _pt.latitude  * COORD_KOEF forKey: SETT_LAT];
        [[NSUserDefaults standardUserDefaults] setInteger: _pt.longitude * COORD_KOEF forKey: SETT_LON];
    }
    
    [_vc reloadPt];
}

//---------------------------------------------------------------------------------
- (BOOL)ptShow
{
    return _ptShow;
}

//---------------------------------------------------------------------------------
- (CLLocationCoordinate2D)pt
{
    return _pt;
}

//---------------------------------------------------------------------------------
- (NSString*)ptName
{
    return _ptName;
}

//---------------------------------------------------------------------------------
- (NSArray*)points
{
    return _points;
}

//---------------------------------------------------------------------------------
- (NSArray*)ptStrs
{
    return _ptStrs;
}

//---------------------------------------------------------------------------------
- (void)pointsToStr: (NSMutableString*)str
{
    for (int i = 0; i < [_points count]; i++)
    {
        [str appendFormat: (i == 0) ? @"%@\n%@" : @"\n\n%@\n%@", [[_points objectAtIndex: i] firstObject], [_ptStrs objectAtIndex: i]];
    }
}

//---------------------------------------------------------------------------------
- (void)reloadPtStrs
{
    [_ptStrs removeAllObjects];
    CLLocationCoordinate2D c;
    for (NSArray* pt in _points)
    {
        c.latitude  = [[pt objectAtIndex: 1] doubleValue];
        c.longitude = [[pt objectAtIndex: 2] doubleValue];
        NSString* s = nil;
        [self stringForC: c res: &s];
        [_ptStrs addObject: s];
        [s release];
    }
}

//---------------------------------------------------------------------------------
- (void)loadPoints
{
    NSString* path = [[NSString alloc] initWithFormat: FILE_POINTS, _folder];
    if (![[NSFileManager defaultManager] fileExistsAtPath: path])
    {
        [path release];
        return;
    }
    NSArray* items = [[NSArray alloc] initWithContentsOfFile: path];
    [path release];
    [_points addObjectsFromArray: items];
    [items release];
}

//---------------------------------------------------------------------------------
- (void)savePoints
{
    [self reloadPtStrs];
    
    NSString* path = [[NSString alloc] initWithFormat: FILE_POINTS, _folder];
    [_points writeToFile: path atomically: YES];
    [path release];
}

//---------------------------------------------------------------------------------
// static
//---------------------------------------------------------------------------------
+ (UIColor*)btTextColor
{
    static UIColor* _s_color = nil;
    if (!_s_color) _s_color = [[UIColor colorWithRed: 0.2 green: 0.4 blue: 0.6 alpha: 1] retain];
    return _s_color;
}

//---------------------------------------------------------------------------------
+ (int)osVer
{
    static int _s_n = 0;
    if (!_s_n)
    {
        NSString* v = [[UIDevice currentDevice] systemVersion];
        unichar c = ([v length]) ? [v characterAtIndex: 0] : 0;
        if (c > '0') _s_n = c - '0';
    }
    return _s_n;
}

//---------------------------------------------------------------------------------
+ (double)coordForStr: (NSString*)str
{
    NSRange r = [str rangeOfString: @"°"];
    if (!r.length) return atof([str UTF8String]);
    
    double d = atof([[str substringToIndex: r.location] UTF8String]);
    str = [str substringFromIndex: r.location + 1];
    if (![str length]) return d;
    
    char n1[32];
    strcpy(n1, [str UTF8String]);
    
    char* p1 = strchr(n1, '\'');
    if (p1) p1[0] = '\0';
    d += atof(n1) / 60;
    if (!p1) return d;
    p1 = p1 + 1;
    if (!p1[0]) return d;
    
    char* p2 = strchr(p1, '\'');
    if (p2) p2[0] = '\0';
    d += atof(p1) / 3600;
    
    return d;
}

@end
