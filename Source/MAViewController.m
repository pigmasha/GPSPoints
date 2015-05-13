//
//  ViewController.m
//  GPSPoints
//
//  Created by M on 24.03.15.
//
//

#import "MAViewController.h"
#import "MAController.h"
#import "MAAnnotation.h"
#import "MANewController.h"
#import "MANavController.h"

typedef enum
{
    MAModeNo,
    MAModeShow, /* show point */
    MAModePt /* navigate to point */
} MAModeType;

@interface MANavBarView : UIView
@end

//=================================================================================


@interface MAViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
{
    MAModeType _mode;
    UIView* _topView;
    UILabel* _ptName;
    UILabel* _ptDist;
    
    MKMapView* _map;
    CLLocationManager* _man;
    BOOL _locShown;
    BOOL _alerted;
    MAAnnotation* _ann;
    MKPolyline* _line;
    MKPolylineRenderer* _lineR;
    CLLocationCoordinate2D _tapC;
}
@end

//=================================================================================

@implementation MAViewController

//---------------------------------------------------------------------------------
- (void)loadView
{
    [super loadView];
    self.title = @"GPSPoints";
    self.view.backgroundColor = [UIColor whiteColor];
    _map = [[MKMapView alloc] initWithFrame: self.view.bounds];
    _map.autoresizingMask = SZ(Width) | SZ(Height);
    _map.delegate = self;
    if ([_map respondsToSelector: @selector(setPitchEnabled:)]) _map.pitchEnabled = NO;
    if ([_map respondsToSelector: @selector(setRotateEnabled:)]) _map.rotateEnabled = SETT_BOOL_VAL(SETT_ROT);
    [self reloadMapType];
    [self.view addSubview: _map];
    [_map release];
    
    UIImage* img = [UIImage imageNamed: @"button_my_geolocation"];
    CGRect r;
    r.size = img.size;
    r.origin.x =self.view.bounds.size.width - r.size.width - 15;
    r.origin.y = self.view.bounds.size.height - 150;
    UIButton* bt = [[UIButton alloc] initWithFrame: r];
    [bt setImage: img forState: UIControlStateNormal];
    [bt setImage: [UIImage imageNamed: @"button_my_geolocation_a"] forState: UIControlStateHighlighted];
    [bt addTarget: self action: @selector(onLoc) forControlEvents: UIControlEventTouchDown];
    bt.autoresizingMask = SZ_M(Left) | SZ_M(Top);
    [self.view addSubview: bt];
    [bt release];
    
    if ([MAController osVer] > 7 && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        _man = [[CLLocationManager alloc] init];
        [_man requestWhenInUseAuthorization];
    }
    
    _map.showsUserLocation = YES;
    [self reloadPt];
    
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_map addGestureRecognizer: longPress];
    [longPress release];
}

//---------------------------------------------------------------------------------
- (void)longPress: (UILongPressGestureRecognizer*)gesture
{
    if (gesture.state != UIGestureRecognizerStateBegan) return;
    
    CGPoint p = [gesture locationInView: _map];
    
    _tapC = [_map convertPoint: p toCoordinateFromView: _map];
    
    UIMenuItem* item = [[UIMenuItem alloc] initWithTitle: LSTR(@"V_Create") action: @selector(onSelNew)];
    NSArray* items = [[NSArray alloc] initWithObjects: item, nil];
    [item release];
    
    UIMenuController* menu = [UIMenuController sharedMenuController];
    menu.menuItems = items;
    [items release];
    
    [menu setTargetRect: CGRectMake(p.x - 5, p.y, 10, 10) inView: _map];
    [menu setMenuVisible: YES animated: YES];
}

//---------------------------------------------------------------------------------
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

//---------------------------------------------------------------------------------
- (void)onSelNew
{
    UIViewController* vc = [[MANewController alloc] initWithC: _tapC];
    UINavigationController* nav = [[MANavController alloc] initWithRootViewController: vc];
    [vc release];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController: nav animated: YES completion: nil];
    [nav release];
}

//---------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"icon_navbar_view_2"] style: UIBarButtonItemStylePlain target: MA_CONTROLLER action: @selector(onPoints)];
    self.navigationItem.leftBarButtonItem = b;
    [b release];
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [_man   release];
    [_line  release];
    [_lineR release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (void)onLoc
{
    [self showPoint: _map.userLocation.location.coordinate];
}

//---------------------------------------------------------------------------------
- (void)reloadFmt
{
    if (_ann)
    {
        NSString* str = nil;
        [MA_CONTROLLER stringForC: [MA_CONTROLLER pt] res: &str];
        [_ann setTxt: str];
        [str release];
    }
}

//---------------------------------------------------------------------------------
- (void)reloadMapType
{
    _map.mapType = ([MA_CONTROLLER mapType] == MAMapHybrid) ? MKMapTypeHybrid : (([MA_CONTROLLER mapType] == MAMapSat) ? MKMapTypeSatellite : MKMapTypeStandard);
}

//---------------------------------------------------------------------------------
- (void)reloadMapRot
{
    if ([_map respondsToSelector: @selector(setRotateEnabled:)]) _map.rotateEnabled = SETT_BOOL_VAL(SETT_ROT);
}

//---------------------------------------------------------------------------------
- (void)reloadPt
{
    [self setMode: ([MA_CONTROLLER ptName]) ? (([MA_CONTROLLER ptShow]) ? MAModeShow : MAModePt) : MAModeNo];
    
    if (_ann)
    {
        [_map removeAnnotation: _ann];
        _ann = nil;
        [_map removeOverlay: _line];
        _line = nil;
        [_lineR release];
        _lineR = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    if (![MA_CONTROLLER ptName]) return;
    
    NSString* str = nil;
    [MA_CONTROLLER stringForC: [MA_CONTROLLER pt] res: &str];
    _ann = [[MAAnnotation alloc] initWithName: [MA_CONTROLLER ptName] txt: str];
    [_ann setCoordinate: [MA_CONTROLLER pt]];
    [str release];
    [_map addAnnotation: _ann];
    if ([MA_CONTROLLER ptShow]) [_map selectAnnotation: _ann animated: YES];
    [_ann release];
    
    UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target: self action: @selector(onCancel)];
    self.navigationItem.rightBarButtonItem = b;
    [b release];
    
    [self reloadLine];
    
    if (_mode == MAModeShow) [self showPoint: [MA_CONTROLLER pt]];
}

// ----------------------------------------------------------------------------
- (void)setMode: (int)mode
{
    if (mode == _mode) return;
    
    BOOL withV = (mode != MAModeNo);
    CGFloat w = self.view.bounds.size.width;
    
    if (withV != (_mode != MAModeNo))
    {
        self.navigationController.navigationBar.translucent = !withV;
        
        if ([self.navigationController.navigationBar respondsToSelector: @selector(shadowImage)])
        {
            self.navigationController.navigationBar.shadowImage = (withV) ? [UIImage imageNamed: @"pixel_transp"] : nil;
        }
        [self.navigationController.navigationBar setBackgroundImage: (withV) ? [UIImage imageNamed: @"pixel"] : nil forBarMetrics: UIBarMetricsDefault];
        
        if (withV)
        {
            _topView = [[MANavBarView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, 40)];
            _topView.autoresizingMask = SZ(Width);
            [self.view addSubview: _topView];
            [_topView release];
            _map.frame = CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height - 40);
        } else {
            [_topView removeFromSuperview];
            _topView = nil;
            _map.frame = self.view.bounds;
            _ptName = nil;
            _ptDist = nil;
        }
    }
    
    if (mode == MAModePt)
    {
        [[_topView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
        ADD_LABEL(_ptName, 10, 0, w - 120, 30, SZ(Width), 17, YES, _topView);
        _ptName.minimumFontSize = 9;
        _ptName.numberOfLines = 0;
        _ptName.adjustsFontSizeToFitWidth = YES;
        ADD_LABEL(_ptDist, w - 120, 0, 110, 30, SZ_M(Left), 20, YES, _topView);
        _ptDist.textAlignment = UITextAlignmentRight;
    } else {
        if (_ptName)
        {
            [_ptName removeFromSuperview];
            _ptName = nil;
        }
        if (_ptDist)
        {
            [_ptDist removeFromSuperview];
            _ptDist = nil;
        }
    }
    
    if (mode == MAModeShow)
    {
        UIColor* c = [[UIColor alloc] initWithRed: 71.0 / 255 green: 108.0 / 255 blue: 1 alpha: 1];
        
        CGFloat w2 = (w < self.view.bounds.size.height) ? w : self.view.bounds.size.height;
        w2 = (w2 - 40) / 3;
        UIButton* b = [[UIButton alloc] initWithFrame: CGRectMake(10, 0, w2, 30)];
        [b addTarget: MA_CONTROLLER action: @selector(setShowPoint) forControlEvents: UIControlEventTouchDown];
        [b setTitle: LSTR(@"V_Go") forState: UIControlStateNormal];
        [b setTitleColor: c forState: UIControlStateNormal];
        [_topView addSubview: b];
        [b release];
        
        b = [[UIButton alloc] initWithFrame: CGRectMake((w - w2) / 2, 0, w2, 30)];
        b.autoresizingMask = SZ_M(Left) | SZ_M(Right);
        [b addTarget: MA_CONTROLLER action: @selector(editShowPoint) forControlEvents: UIControlEventTouchDown];
        [b setTitle: LSTR(@"V_Edit") forState: UIControlStateNormal];
        [b setTitleColor: c forState: UIControlStateNormal];
        [_topView addSubview: b];
        [b release];
        
        b = [[UIButton alloc] initWithFrame: CGRectMake(w - w2 - 10, 0, w2, 30)];
        b.autoresizingMask = SZ_M(Left) | SZ_M(Right);
        [b addTarget: MA_CONTROLLER action: @selector(delShowPoint) forControlEvents: UIControlEventTouchDown];
        [b setTitle: LSTR(@"V_Del") forState: UIControlStateNormal];
        [b setTitleColor: c forState: UIControlStateNormal];
        [_topView addSubview: b];
        [b release];
        
        [c release];
    }
    
    _mode = mode;
}

//---------------------------------------------------------------------------------
- (void)onCancel
{
    [MA_CONTROLLER setPoint: nil isShow: NO];
}

//---------------------------------------------------------------------------------
- (void)reloadLine
{
    if (_mode != MAModePt) return;
    
    CLLocationCoordinate2D c = _map.userLocation.location.coordinate;
    if (!c.latitude && !c.longitude) return;
    
   if (_line) [_map removeOverlay: _line];
    
    MKMapPoint arr[2];
    arr[0] = MKMapPointForCoordinate(c);
    arr[1] = MKMapPointForCoordinate([MA_CONTROLLER pt]);
    _line = [MKPolyline polylineWithPoints: arr count: 2];
    [_lineR release];
    _lineR = [[MKPolylineRenderer alloc] initWithPolyline: _line];
    _lineR.strokeColor =  [UIColor blueColor];
    _lineR.lineWidth = 2.0;
    [_map addOverlay: _line];
    
    CLLocation* loc1 = [[CLLocation alloc] initWithLatitude: [MA_CONTROLLER pt].latitude longitude: [MA_CONTROLLER pt].longitude];
    CLLocation* loc2 = [[CLLocation alloc] initWithLatitude: c.latitude longitude: c.longitude];
    
    CLLocationDistance d = [loc1 distanceFromLocation: loc2];
    [loc1 release];
    [loc2 release];
    
    _ptName.text = [MA_CONTROLLER ptName];
    
    NSString* str = (d > 2000) ? [[NSString alloc] initWithFormat: LSTR(@"V_Fmt2"), d / 1000] : [[NSString alloc] initWithFormat: LSTR(@"V_Fmt1"), d];
    _ptDist.text = str;
    [str release];
}

//---------------------------------------------------------------------------------
- (MKPolylineRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    return _lineR;
}

//---------------------------------------------------------------------------------
- (CLLocationCoordinate2D)curLocation
{
    return _map.userLocation.location.coordinate;
}

//---------------------------------------------------------------------------------
- (void)showPoint: (CLLocationCoordinate2D)c
{
    double sz = 0.005; // miles / 69
    double scalingFactor = ABS(cos(2 * M_PI * c.latitude / 360.0));
    
    MKCoordinateSpan span;
    span.latitudeDelta = sz;
    span.longitudeDelta = sz / scalingFactor;
    
    MKCoordinateRegion region;
    region.span = span;
    region.center = c;
    
    [_map setRegion: region animated: NO];
}

//---------------------------------------------------------------------------------
// <MKMapViewDelegate>
//---------------------------------------------------------------------------------
- (void)mapView: (MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [MA_CONTROLLER locChanged];
    [self reloadLine];
    
    CLLocationCoordinate2D c = _map.userLocation.location.coordinate;
    if (c.longitude && c.latitude && !_locShown)
    {
        _locShown = YES;
        [self showPoint: c];
    }
}

//---------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    if (!_alerted && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        _alerted = YES;
        
        if ([MAController osVer] > 7)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle: nil message: LSTR(@"V_Denied2") preferredStyle: UIAlertControllerStyleAlert];
            [alert addAction: [UIAlertAction actionWithTitle: LSTR(@"Ask_Later")  style: UIAlertActionStyleCancel  handler: nil]];
            [alert addAction: [UIAlertAction actionWithTitle: LSTR(@"Ask_Sett") style: UIAlertActionStyleDefault handler: ^(UIAlertAction *action)
                               {
                                   NSURL* url = [[NSURL alloc] initWithString: UIApplicationOpenSettingsURLString];
                                   if (url) [[UIApplication sharedApplication] openURL: url];
                                   [url release];
                               }]];
            [self presentViewController: alert animated: YES completion: nil];
        } else {
            SHOW_ALERT(nil, LSTR(@"V_Denied"));
        }
    }
}

@end

//=================================================================================

@implementation MANavBarView

// ----------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame: frame])
    {
        self.backgroundColor = [UIColor colorWithWhite: 0.968 alpha: 1];
    }
    return self;
}

// ----------------------------------------------------------------------------
- (void)willMoveToWindow: (UIWindow *)newWindow
{
    self.layer.shadowOffset = CGSizeMake(0, 1.0f/UIScreen.mainScreen.scale);
    self.layer.shadowRadius = 0;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.35f;
}

@end
