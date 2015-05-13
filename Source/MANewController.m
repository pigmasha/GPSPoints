//
//  MANewController.m
//  GPSPoints
//
//  Created by M on 25.03.15.
//
//

#import "MANewController.h"
#import "MAController.h"
#import "MACoordCell.h"

@interface MANewController ()
{
    MAInputCell* _cellN;
    MACoordCell* _cellLat;
    MACoordCell* _cellLon;
    NSString* _footer;
    NSArray* _pt;
    BOOL _isNew;
    CLLocationCoordinate2D _c;
    BOOL _isC;
}

@end

//=================================================================================

@implementation MANewController

- (instancetype)initWithPt: (NSArray*)pt isNew: (BOOL)isNew
{
    if (self = [super initWithStyle: UITableViewStyleGrouped])
    {
        _pt = pt;
        _isNew = isNew;
    }
    return self;
}

//---------------------------------------------------------------------------------
- (instancetype)initWithC: (CLLocationCoordinate2D)c
{
    if (self = [super initWithStyle: UITableViewStyleGrouped])
    {
        _isC = YES;
        _c = c;
    }
    return self;
}

//---------------------------------------------------------------------------------
- (void)loadView
{
    [super loadView];
    self.title = (_pt) ? LSTR(@"N_Title2") : LSTR(@"N_Title");
    _cellN = [[MAInputCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: nil];
    [_cellN input].placeholder = LSTR(@"N_Holder");
    if (_pt) [_cellN input].text = [_pt firstObject];
    
    if (_isC)
    {
        _cellLat = [[MACoordCell alloc] initIsLat: YES val: _c.latitude];
        _cellLon = [[MACoordCell alloc] initIsLat: NO  val: _c.longitude];
    } else {
        _cellLat = [[MACoordCell alloc] initIsLat: YES val: (_pt) ? [[_pt objectAtIndex: 1] doubleValue] : 0];
        _cellLon = [[MACoordCell alloc] initIsLat: NO  val: (_pt) ? [[_pt objectAtIndex: 2] doubleValue] : 0];
    }
    
    NSString* str = nil;
    [MA_CONTROLLER stringForCurLocation: &str];
    _footer = [[NSString alloc] initWithFormat: LSTR(@"N_Footer"), str];
    [str release];
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    [_cellN   release];
    [_cellLat release];
    [_cellLon release];
    [_footer  release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target: self action: @selector(onOk)];
    self.navigationItem.rightBarButtonItem = b;
    [b release];
    
    if (_isC || !_isNew)
    {
        UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"icon_navbar_cancel"] style: UIBarButtonItemStylePlain target: self action: @selector(onCancel)];
        self.navigationItem.leftBarButtonItem = b;
        [b release];
    }
}

//---------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [[_cellN input] becomeFirstResponder];
}

//---------------------------------------------------------------------------------
- (void)onCancel
{
    [self.presentingViewController dismissViewControllerAnimated: YES completion: NULL];
}

//---------------------------------------------------------------------------------
- (void)onOk
{
    int err = [MA_CONTROLLER editPoint: _pt name: [_cellN input].text lat: [_cellLat val] lon: [_cellLon val] setCur: (_isC) ? 1 : ((_isNew) ? 0 : 2)];
    if (err == 1)
    {
        SHOW_ALERT(nil, LSTR(@"N_Ex"));
    } else {
        if (_isC || !_isNew)
        {
            [self onCancel];
        } else {
            [self.navigationController popViewControllerAnimated: YES];
        }
    }
}

//---------------------------------------------------------------------------------
// <UITableViewDataSource>
//---------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

//---------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) return _cellLat;
    if (indexPath.row == 2) return _cellLon;
    
    return _cellN;
}

//---------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return _footer;
}

@end
