//
//  MACoordCell.m
//  GPSPoints
//
//  Created by M on 26.03.15.
//
//

#import "MACoordCell.h"
#import "MAController.h"

@interface MACoordCell ()
{
    BOOL _isLat;
    UISegmentedControl* _segm;
    UITextField* _input[3];
    NSString* _lastStr[3];
}

@end

//=================================================================================

@implementation MACoordCell

static MACoordCell* _s_lon = nil;

- (instancetype)initIsLat: (BOOL)isLat val: (double)val
{
    if (self = [super initWithStyle: UITableViewCellStyleDefault reuseIdentifier: nil])
    {
        _isLat = isLat;
        if (!_isLat) _s_lon = self;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGSize sz = self.contentView.bounds.size;
        
        NSArray* items = (isLat) ? [[NSArray alloc] initWithObjects: @"N", @"S", nil] : [[NSArray alloc] initWithObjects: @"E", @"W", nil];
        _segm = [[UISegmentedControl alloc] initWithItems: items];
        [items release];
        _segm.selectedSegmentIndex = (isLat) ? ((SETT_BOOL_VAL(SETT_LAT_N)) ? 0 : 1) : ((SETT_BOOL_VAL(SETT_LON_E)) ? 0 : 1);
        CGRect r = _segm.bounds;
        r.size.width = 60;
        r.size.height = SEGM_H;
        r.origin.x = 10;
        r.origin.y = (sz.height - r.size.height) / 2;
        _segm.frame = r;
        _segm.autoresizingMask = SZ_M(Top) | SZ_M(Bottom);
        [self.contentView addSubview: _segm];
        [_segm release];
        
        if (val)
        {
            _segm.selectedSegmentIndex = (val > 0) ? 0 : 1;
            if (val < 0) val = -val;
        }
        [self loadCell: val];
    }
    return self;
}

#define COORD_H 30
#define COORD_W 50
#define COORD_FONT_SZ 20

//---------------------------------------------------------------------------------
- (void)loadCell: (double)val
{
    for (int i = 0; i < 3; i++)
    {
        _input[i] = nil;
        _lastStr[i] = nil;
    }
    BOOL hasVal = (val != 0);
    
    int f = [MA_CONTROLLER fmt];
    CGSize sz = self.contentView.bounds.size;
    CGRect r = _segm.frame;
    int y = (sz.height - COORD_H + 4) / 2;
    
    _input[0] = [[UITextField alloc] initWithFrame: CGRectMake(25 + r.size.width, y, (f == MACoorDegMin || f == MACoorDegMinSec) ? COORD_W : sz.width - 35 - r.size.width, COORD_H)];
    if (f != MACoorDegMin && f != MACoorDegMinSec) _input[0].autoresizingMask = SZ(Width);
    _input[0].font = [UIFont systemFontOfSize: COORD_FONT_SZ];
    _input[0].keyboardType = UIKeyboardTypeDecimalPad;
    _input[0].autoresizingMask = SZ_M(Top) | SZ_M(Bottom);
    [self.contentView addSubview: _input[0]];
    _input[0].placeholder = (f == MACoorDegMin || f == MACoorDegMinSec) ? @"__°" : @"__.______°";
    [_input[0] release];
    if (hasVal)
    {
        NSString* s = (f != MACoorDegMin && f != MACoorDegMinSec) ? [[NSString alloc] initWithFormat: @"%09.6f°", val] : [[NSString alloc] initWithFormat: @"%02d°", (int)val];
        _input[0].text = s;
        _lastStr[0] = s;
        val -= (int)val;
        val *= 60;
    }
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textChangedNotification:) name: UITextFieldTextDidChangeNotification object: _input[0]];
    if (f != MACoorDegMin && f != MACoorDegMinSec) return;
    
    _input[1] = [[UITextField alloc] initWithFrame: CGRectMake(25 + r.size.width + COORD_W, y, (f == MACoorDegMinSec) ? COORD_W : sz.width - 35 - COORD_W - r.size.width, COORD_H)];
    _input[1].font = [UIFont systemFontOfSize: COORD_FONT_SZ];
    _input[1].autoresizingMask = (f == MACoorDegMin) ? SZ(Width) | SZ_M(Top) | SZ_M(Bottom) : SZ_M(Top) | SZ_M(Bottom);
    _input[1].keyboardType = UIKeyboardTypeDecimalPad;
    [self.contentView addSubview: _input[1]];
    _input[1].placeholder = (f == MACoorDegMin) ? @"__.___'" : @"__'";
    [_input[1] release];
    if (hasVal)
    {
        NSString* s = (f == MACoorDegMin) ? [[NSString alloc] initWithFormat: @"%06.3f'", val] : [[NSString alloc] initWithFormat: @"%02d'", (int)val];
        _input[1].text = s;
        _lastStr[1] = s;
        val -= (int)val;
        val *= 60;
    }
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textChangedNotification:) name: UITextFieldTextDidChangeNotification object: _input[1]];
    if (f == MACoorDegMin) return;
    
    _input[2] = [[UITextField alloc] initWithFrame: CGRectMake(25 + r.size.width + 2 * COORD_W, y, sz.width - 35 - 2 * COORD_W - r.size.width, COORD_H)];
    _input[2].font = [UIFont systemFontOfSize: COORD_FONT_SZ];
    _input[2].autoresizingMask = SZ(Width) | SZ_M(Top) | SZ_M(Bottom);
    _input[2].keyboardType = UIKeyboardTypeDecimalPad;
    [self.contentView addSubview: _input[2]];
    _input[2].placeholder = @"__''";
    [_input[2] release];
    if (hasVal)
    {
        NSString* s = [[NSString alloc] initWithFormat: @"%02d''", (int)val];
        _input[2].text = s;
        _lastStr[2] = s;
    }
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textChangedNotification:) name: UITextFieldTextDidChangeNotification object: _input[2]];
}

//---------------------------------------------------------------------------------
- (void)dealloc
{
    if (_s_lon == self) _s_lon = nil;
    for (int i = 0; i < 3; i++) [_lastStr[i] release];
    [super dealloc];
}

//---------------------------------------------------------------------------------
- (double)val
{
    if (_isLat)
    {
        SETT_SET_BOOL_VAL(SETT_LAT_N, (_segm.selectedSegmentIndex == 0));
    } else {
        SETT_SET_BOOL_VAL(SETT_LON_E, (_segm.selectedSegmentIndex == 0));
    }
    
    double k = (_segm.selectedSegmentIndex > 0) ? -1 : 1;
    if (!_input[1]) return k * [_input[0].text doubleValue];
    if (!_input[2]) return k * [_input[0].text intValue] + k * [_input[1].text doubleValue] / 60;
    return k * [_input[0].text intValue] + k * (double)[_input[1].text intValue] / 60 + k * [_input[2].text doubleValue] / 3600;
}

//---------------------------------------------------------------------------------
// <UITextFieldTextDidChangeNotification>
//---------------------------------------------------------------------------------
- (void)textChangedNotification: (NSNotification*)notification
{
    UITextField* o = [notification object];
    int i = (o == _input[0]) ? 0 : ((o == _input[1]) ? 1 : 2);
    BOOL isInt = (i == 2 || _input[i + 1]);
    
    char n1[32];
    int p1 = 0;
    int dPos = -1;
    NSString* s = o.text;
    for (int i = 0; i < [s length]; i++)
    {
        unichar c = [s characterAtIndex: i];
        if (c >= '0' && c <= '9')
        {
            n1[p1] = c;
            p1++;
        }
        if (isInt) continue;
        if ((c == '.' || c == ',') && dPos < 0)
        {
            dPos = p1;
            n1[p1] = '.';
            p1++;
        }
        if (p1 > 8) break;
    }
    if (!p1) return;
    if (isInt && p1 > 2) p1 = 2;
    if (!isInt && i == 1 && p1 > 6) p1 = 6;
    
    n1[p1] = '\0';
    BOOL isDel = ([s length] < [_lastStr[i] length]);
    NSString* s2 = nil;
    if (isInt)
    {
        if (isDel) p1--;
        n1[p1] = '\0';
        if (p1)
        {
            s2 = [[NSString alloc] initWithFormat: (i == 0) ? @"%s°" : ((i == 1) ? @"%s'" : @"%s''"), n1];
        } else {
            s2 = [[NSString alloc] init];
        }
    } else {
        if ((i == 0 && p1 > 8) || (i == 1 && p1 > 5))
        {
            if (isDel)
            {
                p1--;
                n1[p1] = '\0';
                s2 = [[NSString alloc] initWithUTF8String: n1];
            } else {
                s2 = [[NSString alloc] initWithFormat: (i == 0) ? @"%s°" : @"%s'", n1];
            }
        } else {
            s2 = [[NSString alloc] initWithUTF8String: n1];
        }
    }
    if (![s2 isEqualToString: s]) _input[i].text = s2;
    [s2 release];
    
    [_lastStr[i] release];
    _lastStr[i] = [[NSString alloc] initWithString: _input[i].text];
    
    if (isDel) return;
    
    if (i == 0 && _input[1])
    {
        if ((p1 > 2) || (_isLat && p1 == 2) || (!_isLat && p1 == 2 && n1[0] > '1')) [_input[1] becomeFirstResponder];
    }
    if (i == 0 && !_input[1] && _isLat && p1 > 8) [_s_lon->_input[0] becomeFirstResponder];
    if (i == 1 && _input[2] && p1 > 1) [_input[2] becomeFirstResponder];
    if (i == 1 && !_input[2] && _isLat && p1 > 5) [_s_lon->_input[0] becomeFirstResponder];
    if (i == 2 && _isLat && p1 > 1) [_s_lon->_input[0] becomeFirstResponder];
}

@end
