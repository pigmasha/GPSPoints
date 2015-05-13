//
//  MAConstants.h
//
//  Created by M on 10.02.14.
//  Copyright (c) 2014. All rights reserved.
//

#import <MapKit/MapKit.h>

#define INPUT_H 24
#define SEGM_H 30

//---------------------------------------------------------------------------------

#define SZ(__s) UIViewAutoresizingFlexible ## __s
#define SZ_M(__s) UIViewAutoresizingFlexible ## __s ## Margin

#define LSTR(__str) NSLocalizedString(__str, nil)

#define CELL_SEL_DEF (([MAController osVer] > 6) ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleBlue)

//---------------------------------------------------------------------------------

#define SHOW_ALERT(__title, __msg) \
{ \
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: __title message: __msg delegate: nil cancelButtonTitle: LSTR(@"OK") otherButtonTitles:nil]; \
    [alert show]; \
    [alert release]; \
}

#define ADD_LABEL(__val, __x, __y, __w, __h, __mask, __fontSz, __isBold, __superview) \
    __val = [[UILabel alloc] initWithFrame: CGRectMake(__x, __y, __w, __h)]; \
    __val.autoresizingMask = __mask; \
    __val.backgroundColor = [UIColor clearColor]; \
    __val.font = (__isBold) ? [UIFont boldSystemFontOfSize: __fontSz] : [UIFont systemFontOfSize: __fontSz]; \
    [__superview addSubview: __val]; \
    [__val release];

#define SETT_BOOL_VAL(__name) (([[NSUserDefaults standardUserDefaults] integerForKey: __name]) ? ([[NSUserDefaults standardUserDefaults] integerForKey: __name] == 1) : (__name ## _DEF == 1))
#define SETT_SET_BOOL_VAL(__name, __val) [[NSUserDefaults standardUserDefaults] setInteger: (__val) ? 1 : 2 forKey: __name]

/* settings */
#define SETT_FMT  @"F"
#define SETT_LAT  @"Lat"
#define SETT_LON  @"Lon"
#define SETT_TYPE @"T"

/* Bool settings stored as int: 0 - default, 1 - on, 2 - off */
#define SETT_LAT_N     @"LatN"
#define SETT_LAT_N_DEF 1
#define SETT_LON_E     @"LonE"
#define SETT_LON_E_DEF 1
#define SETT_PT        @"Pt"
#define SETT_PT_DEF    0
#define SETT_ROT       @"Rot"
#define SETT_ROT_DEF   1

